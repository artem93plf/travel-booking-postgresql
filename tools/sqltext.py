"""Pure-Python SQL text utilities (stdlib only)."""
import re
from pathlib import Path

_FORBIDDEN_RE = re.compile(
    r"(?<![A-Za-z0-9_$])(CURRENT_DATE|CURRENT_TIMESTAMP|NOW(?=\s*\())(?![A-Za-z0-9_$])",
    re.IGNORECASE,
)
_MARKER_RE = re.compile(r"^[ \t]*--[ \t]*test:[ \t]*(\S+)[^\n]*\n?", re.MULTILINE)
_DOLLAR_RE = re.compile(r"\$(?:[A-Za-z_][A-Za-z0-9_]*)?\$")


def read_sql(path: Path) -> str:
    text = Path(path).read_bytes().decode("utf-8-sig")
    return text.replace("\r\n", "\n").replace("\r", "\n")


def _blank(s: str) -> str:
    return "".join(c if c == "\n" else " " for c in s)


def strip_comments_and_strings(sql: str) -> str:
    out = []
    i, n = 0, len(sql)
    while i < n:
        c = sql[i]
        if sql.startswith("--", i):
            j = sql.find("\n", i)
            j = n if j < 0 else j
        elif sql.startswith("/*", i):
            depth, j = 1, i + 2
            while j < n and depth:
                if sql.startswith("/*", j):
                    depth += 1
                    j += 2
                elif sql.startswith("*/", j):
                    depth -= 1
                    j += 2
                else:
                    j += 1
        elif c in ("'", '"'):
            j = i + 1
            while j < n:
                if sql[j] == c:
                    if j + 1 < n and sql[j + 1] == c:
                        j += 2
                        continue
                    j += 1
                    break
                j += 1
        elif c == "$" and (m := _DOLLAR_RE.match(sql, i)) and (
            i == 0 or not (sql[i - 1].isalnum() or sql[i - 1] == "_")
        ):
            tag = m.group(0)
            j = sql.find(tag, m.end())
            j = n if j < 0 else j + len(tag)
        else:
            out.append(c)
            i += 1
            continue
        out.append(_blank(sql[i:j]))
        i = j
    return "".join(out)


def count_statements(sql: str) -> int:
    return sum(1 for part in strip_comments_and_strings(sql).split(";") if part.strip())


def find_forbidden(sql: str) -> list[str]:
    found = []
    for m in _FORBIDDEN_RE.finditer(strip_comments_and_strings(sql)):
        tok = m.group(1).upper()
        found.append("NOW(" if tok == "NOW" else tok)
    return found


def split_tests(sql: str) -> dict[str, str]:
    marks = list(_MARKER_RE.finditer(sql))
    blocks = {}
    for k, m in enumerate(marks):
        end = marks[k + 1].start() if k + 1 < len(marks) else len(sql)
        blocks[m.group(1)] = sql[m.end():end]
    return blocks
