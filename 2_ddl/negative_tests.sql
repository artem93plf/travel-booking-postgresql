-- Негативные тесты: для каждого правила напишите оператор (INSERT/UPDATE/DELETE),
-- который нарушает правило; база должна отклонить его с указанным SQLSTATE.
-- Оператор пишите под маркером «-- test: ...».
-- Правила S1 и S2 обязательны, S3 — по желанию.

-- test: R01
-- Два пассажира с одним номером паспорта
-- Ожидаемый SQLSTATE: 23505
-- Ваш SQL код здесь

INSERT INTO passengers (passport, full_name, birth_date)
SELECT passport, full_name, birth_date
FROM passengers
ORDER BY id
LIMIT 1;

-- test: R02
-- Два пользователя с одним email
-- Ожидаемый SQLSTATE: 23505
-- Ваш SQL код здесь

INSERT INTO users (email, full_name, phone_main, phone_extra)
SELECT email, full_name, phone_main, phone_extra
FROM users
ORDER BY id
LIMIT 1;

-- test: R03
-- Билет на несуществующий рейс
-- Ожидаемый SQLSTATE: 23503
-- Ваш SQL код здесь

UPDATE ticket
SET flight_id = (SELECT MAX(id)+1 FROM flights)
WHERE id = (SELECT id FROM ticket ORDER BY id LIMIT 1);

-- test: R04
-- Прилёт не позже вылета
-- Ожидаемый SQLSTATE: 23514
-- Ваш SQL код здесь

UPDATE flights 
SET arrival_at = departure_at
WHERE id = (SELECT id FROM flights ORDER BY id LIMIT 1);

-- test: R05
-- Выезд из отеля не позже заезда
-- Ожидаемый SQLSTATE: 23514
-- Ваш SQL код здесь

UPDATE stay
SET check_out = check_in 
WHERE id = (SELECT id FROM stay ORDER BY id LIMIT 1);

-- test: R06
-- Звёзды отеля вне 1..5
-- Ожидаемый SQLSTATE: 23514
-- Ваш SQL код здесь

UPDATE hotel
SET stars = 6
WHERE id = (SELECT id FROM hotel ORDER BY id LIMIT 1);

-- test: R07
-- Оценка отзыва вне 1..5
-- Ожидаемый SQLSTATE: 23514
-- Ваш SQL код здесь

UPDATE review
SET rating = 6
WHERE id = (SELECT id FROM review ORDER BY id LIMIT 1);

-- test: R08
-- Отрицательная или нулевая цена билета
-- Ожидаемый SQLSTATE: 23514
-- Ваш SQL код здесь

UPDATE ticket
SET price = 0
WHERE id = (SELECT id FROM ticket ORDER BY id LIMIT 1);

-- test: R09
-- Вторая оплата одного и того же заказа
-- Ожидаемый SQLSTATE: 23505
-- Ваш SQL код здесь

-- test: R10
-- Заказ без пользователя
-- Ожидаемый SQLSTATE: 23502
-- Ваш SQL код здесь

-- test: R11
-- Статус заказа не из списка (created, paid, cancelled)
-- Ожидаемый SQLSTATE: 23514
-- Ваш SQL код здесь

-- test: R12
-- Удаление рейса, на который проданы билеты
-- Ожидаемый SQLSTATE: 23503
-- Ваш SQL код здесь

-- test: S1
-- Сформулируйте своё правило:
-- <текст правила>
-- Ожидаемый SQLSTATE: <код>
-- Ваш SQL код здесь

-- test: S2
-- Сформулируйте своё правило:
-- <текст правила>
-- Ожидаемый SQLSTATE: <код>
-- Ваш SQL код здесь

-- test: S3
-- Сформулируйте своё правило (S3 — по желанию):
-- <текст правила>
-- Ожидаемый SQLSTATE: <код>
-- Ваш SQL код здесь
