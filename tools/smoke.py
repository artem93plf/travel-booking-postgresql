"""Самопроверка проекта: python tools/smoke.py --dsn DSN [--root PATH].

Создаёт временную БД, выполняет SQL-файлы студента в порядке из contracts.json
и сообщает OK/FAIL/WARN по каждому файлу. Правильность результатов НЕ проверяется:
только что файлы выполняются, число колонок совпадает с контрактом, а негативные
тесты падают с нарушением целостности (SQLSTATE класса 23).
"""
import argparse
import json
import re
import sys
import uuid
from dataclasses import dataclass
from pathlib import Path
from typing import Literal

sys.path.insert(0, str(Path(__file__).resolve().parent))

import psycopg  # noqa: E402
from psycopg.conninfo import make_conninfo  # noqa: E402

import sqltext  # noqa: E402

NEGATIVE_FILE = "2_ddl/negative_tests.sql"
EXTRA_FILE = "3_data/extra.sql"
STATEMENT_TIMEOUT_MS = 5000
ENCODING_MSG = "файл не в кодировке UTF-8, пересохраните как UTF-8"
NO_STATEMENT_MSG = "нет SQL-оператора"
OPTIONAL_EMPTY_MSG = "необязательное правило не заполнено"

_KIND_RE = re.compile(r"^(q|e|d|own)\d\d")


@dataclass
class Check:
    step: str
    file: str
    status: Literal["OK", "FAIL", "WARN"]
    message: str


class SmokeError(Exception):
    """Нельзя начать проверку (БД недоступна, битый contracts.json)."""


def _kind(rel: str) -> str:
    m = _KIND_RE.match(Path(rel).name)
    return m.group(1) if m else ""


def _err_text(e: Exception) -> str:
    code = getattr(e, "sqlstate", None)
    diag = getattr(e, "diag", None)
    msg = (diag.message_primary if diag is not None else None) or str(e).strip()
    msg = msg.splitlines()[0] if msg else type(e).__name__
    return f"{code}: {msg}" if code else msg


def _load_contract(root: Path) -> dict:
    path = root / "tools" / "contracts.json"
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError) as e:
        raise SmokeError(f"Не удалось прочитать {path}: {e}")


def _static(root: Path, rel: str) -> tuple[list[Check], str | None]:
    """Статические проверки файла. Возвращает (checks, text|None если исполнять нельзя)."""
    path = root / rel
    if not path.is_file():
        return [Check("static", rel, "FAIL", "файл не найден")], None
    if not rel.endswith(".sql"):
        return [Check("static", rel, "OK", "файл на месте")], None
    try:
        text = sqltext.read_sql(path)
    except UnicodeDecodeError:
        return [Check("static", rel, "FAIL", ENCODING_MSG)], None
    n = sqltext.count_statements(text)
    problems, runnable = [], True
    if n == 0:
        if rel == EXTRA_FILE:
            return [Check("static", rel, "WARN", "файл пуст (необязательный)")], None
        problems.append(NO_STATEMENT_MSG)
        runnable = False
    forbidden = sorted(set(sqltext.find_forbidden(text)))
    if forbidden:
        problems.append("запрещено использовать: " + ", ".join(forbidden))
    if _kind(rel) in ("q", "e", "own") and n > 1:
        problems.append(f"должен быть ровно один оператор, найдено {n}")
    if problems:
        return [Check("static", rel, "FAIL", "; ".join(problems))], text if runnable else None
    return [Check("static", rel, "OK", f"операторов: {n}")], text


def _reset(conn) -> None:
    try:
        conn.rollback()
    except Exception:
        pass


def _run_file(conn, rel: str, text: str, columns: list | None, step: str,
              warn_empty: bool) -> Check:
    kind = _kind(rel)
    try:
        cur = conn.execute(text)
        total, desc, rows = 0, None, None
        while True:
            if cur.description is None:
                desc, rows = None, None
                total += max(cur.rowcount, 0)
            else:
                desc = len(cur.description)
                rows = cur.fetchall() if (warn_empty and kind in ("q", "own")) else None
            if not cur.nextset():
                break
        rowcount = total
    except psycopg.Error as e:
        _reset(conn)
        return Check(step, rel, "FAIL", _err_text(e))
    if columns is not None and desc != len(columns):
        return Check(step, rel, "FAIL",
                     f"ожидалось {len(columns)} колонок, получено {desc if desc is not None else 0}")
    if rows is not None and not rows:
        return Check(step, rel, "WARN", "запрос выполнен, но не вернул строк")
    if kind == "d":
        return Check(step, rel, "OK", f"выполнен, затронуто строк: {rowcount}")
    if desc is not None:
        return Check(step, rel, "OK", f"выполнен, колонок: {desc}")
    return Check(step, rel, "OK", "выполнен")


def _run_negative(conn, rel: str, text: str, contract: dict) -> list[Check]:
    blocks = sqltext.split_tests(text)
    required = [r["code"] for r in contract.get("rules", [])]
    required += contract.get("own_rules", {}).get("required", [])
    optional = set(contract.get("own_rules", {}).get("optional", []))
    checks = []
    for code in required:
        if code not in blocks:
            checks.append(Check("negative", f"{rel}#{code}", "FAIL",
                                f"тест {code} отсутствует (нужен маркер «-- test: {code}»)"))
    for code, block in blocks.items():
        name = f"{rel}#{code}"
        if sqltext.count_statements(block) == 0:
            if code in optional:
                checks.append(Check("negative", name, "WARN", OPTIONAL_EMPTY_MSG))
            else:
                checks.append(Check("negative", name, "FAIL", NO_STATEMENT_MSG))
            continue
        if sqltext.count_statements(block) > 1:
            checks.append(Check("negative", name, "FAIL",
                                "под маркером должен быть один оператор"))
            continue
        try:
            with conn.transaction(force_rollback=True):
                conn.execute(block)
        except psycopg.Error as e:
            _reset(conn)
            state = getattr(e, "sqlstate", None) or ""
            if state.startswith("23"):
                checks.append(Check("negative", name, "OK", f"отклонено: {_err_text(e)}"))
            else:
                checks.append(Check("negative", name, "FAIL",
                                    f"ожидалось нарушение целостности (класс 23), получено {_err_text(e)}"))
        else:
            checks.append(Check("negative", name, "FAIL",
                                "должно было упасть, но выполнилось (изменения откатаны)"))
    return checks


def _guard(step: str, rel: str, fn) -> list[Check]:
    try:
        return fn()
    except UnicodeDecodeError:
        return [Check(step, rel, "FAIL", ENCODING_MSG)]
    except Exception as e:  # студент не должен видеть трейсбек
        return [Check(step, rel, "FAIL", f"внутренняя ошибка проверки: {type(e).__name__}: {e}")]


def _run_order(conn, root: Path, contract: dict, order: list[str], texts: dict,
               step: str, extra: bool) -> list[Check]:
    by_file = {q["file"]: q for q in contract.get("queries", {}).values()}
    checks = []
    for rel in order:
        if not rel.endswith(".sql") or not (root / rel).is_file():
            continue

        def one(rel=rel):
            text = texts.get(rel)
            if text is None:
                text = sqltext.read_sql(root / rel)
                if sqltext.count_statements(text) == 0:
                    return []
            if rel == NEGATIVE_FILE and not extra:
                return _run_negative(conn, rel, text, contract)
            cols = by_file.get(rel, {}).get("columns") if not extra else None
            return [_run_file(conn, rel, text, cols, step, warn_empty=extra)]

        checks += _guard(step, rel, one)
    return checks


def _with_temp_db(admin_dsn: str, fn):
    name = f"smoke_{uuid.uuid4().hex[:8]}"
    try:
        admin = psycopg.connect(admin_dsn, autocommit=True, connect_timeout=10)
    except psycopg.Error as e:
        raise SmokeError(f"Не удалось подключиться к PostgreSQL: {_err_text(e)}")
    try:
        try:
            admin.execute(f'CREATE DATABASE "{name}"')
        except psycopg.Error as e:
            raise SmokeError(f"Не удалось создать временную БД: {_err_text(e)}")
        try:
            dsn = make_conninfo(admin_dsn, dbname=name,
                                options=f"-c statement_timeout={STATEMENT_TIMEOUT_MS}")
            with psycopg.connect(dsn, autocommit=True) as conn:
                return fn(conn)
        finally:
            try:
                admin.execute(f'DROP DATABASE IF EXISTS "{name}" WITH (FORCE)')
            except psycopg.Error:
                pass
    finally:
        admin.close()


def run_smoke(root: Path, admin_dsn: str) -> list[Check]:
    root = Path(root)
    contract = _load_contract(root)
    checks: list[Check] = []
    texts: dict[str, str] = {}
    for rel in contract["files"]:
        res = _guard("static", rel, lambda rel=rel: _static(root, rel))
        if isinstance(res, tuple):
            res, text = res
            if text is not None:
                texts[rel] = text
        checks += res
    checks += _with_temp_db(
        admin_dsn,
        lambda c: _run_order(c, root, contract, contract["run_order"], texts, "run", False),
    )
    extra_checks = _with_temp_db(
        admin_dsn,
        lambda c: _run_order(c, root, contract, contract["run_order_extra"], texts, "extra", True),
    )
    return checks + extra_checks


def format_report(checks: list[Check]) -> str:
    lines = [f"[{c.status}] {c.step}  {c.file or '-'}  {c.message}" for c in checks]
    n = {s: sum(1 for c in checks if c.status == s) for s in ("OK", "FAIL", "WARN")}
    lines.append(f"Итого: {n['OK']} OK, {n['FAIL']} FAIL, {n['WARN']} WARN")
    return "\n".join(lines)


def main(argv=None) -> int:
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(encoding="utf-8")
        except Exception:
            pass
    p = argparse.ArgumentParser(description="Самопроверка SQL-проекта")
    p.add_argument("--dsn", required=True, help="DSN администратора PostgreSQL")
    p.add_argument("--root", type=Path, default=Path(__file__).resolve().parent.parent,
                   help="корень проекта (по умолчанию родитель каталога tools/)")
    args = p.parse_args(argv)
    try:
        checks = run_smoke(args.root, args.dsn)
    except SmokeError as e:
        print(f"Ошибка: {e}", file=sys.stderr)
        return 2
    print(format_report(checks))
    return 1 if any(c.status == "FAIL" for c in checks) else 0


if __name__ == "__main__":
    sys.exit(main())
