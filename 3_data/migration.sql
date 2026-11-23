-- Перенесите данные из таблиц raw_* в ваши таблицы запросами INSERT ... SELECT.
-- Правила (подробно — PROJECT.md, раздел 8):
--   - никаких данных руками: ни email, ни номеров заказов, ни id в VALUES;
--     вручную можно задать только справочные значения (например, статусы);
--   - каждая сущность — ровно одна строка (DISTINCT);
--   - внешние ключи — через JOIN по натуральному ключу, а не числами 1, 2, 3;
--   - порядок вставки — по внешним ключам: сначала родители, потом дети;
--   - ничего не потерять: перенесите каждую строку выгрузки, NULL оставьте NULL;
--   - значения натуральных ключей (email, паспорт, номер рейса, IATA, названия) — как есть;
--   - таблицы raw_* не изменяйте и не удаляйте;
--   - файл выполняется целиком на чистой базе сразу после ddl.sql, без ошибок.
--
-- Ваш SQL код здесь

-- Страны и города из полного расписания и каталога отелей
INSERT INTO country (name)
SELECT from_country FROM raw_flights
UNION
SELECT to_country FROM raw_flights
UNION
SELECT country FROM raw_hotels;

INSERT INTO city (country_id, name)
SELECT c.id, r.city_name
FROM (
    SELECT from_city AS city_name, from_country AS country_name FROM raw_flights
    UNION
    SELECT to_city, to_country FROM raw_flights
    UNION
    SELECT city, country FROM raw_hotels
) AS r
JOIN country AS c ON c.name = r.country_name;

INSERT INTO airports (iata, name, city_id)
SELECT r.iata, r.airport_name, ci.id
FROM (
    SELECT from_iata AS iata, from_airport AS airport_name,
           from_city AS city_name, from_country AS country_name
    FROM raw_flights
    UNION
    SELECT to_iata, to_airport, to_city, to_country FROM raw_flights
) AS r
JOIN country AS c ON c.name = r.country_name
JOIN city AS ci ON ci.country_id = c.id AND ci.name = r.city_name;

INSERT INTO airline (name)
SELECT DISTINCT airline_name FROM raw_flights;

-- Сохраняем также вылеты без билетов и отели без проживаний
INSERT INTO flights (
    flight_no, airline_id, from_airport_id, to_airport_id,
    departure_at, arrival_at, base_price
)
SELECT r.flight_no, a.id, af.id, at.id,
       r.departure_at, r.arrival_at, r.base_price
FROM raw_flights AS r
JOIN airline AS a ON a.name = r.airline_name
JOIN airports AS af ON af.iata = r.from_iata
JOIN airports AS at ON at.iata = r.to_iata;

INSERT INTO hotel (name, city_id, stars, price_per_night)
SELECT r.hotel_name, ci.id, r.stars, r.price_per_night
FROM raw_hotels AS r
JOIN country AS c ON c.name = r.country
JOIN city AS ci ON ci.country_id = c.id AND ci.name = r.city;

-- Контакты берём из заказов; пользователей только с отзывами добавляем без телефонов
INSERT INTO users (email, full_name, phone_main, phone_extra)
SELECT user_email, user_full_name, user_phone_main, user_phone_extra
FROM raw_flight_orders
UNION
SELECT user_email, user_full_name, user_phone_main, user_phone_extra
FROM raw_hotel_orders
UNION
SELECT r.user_email, r.user_full_name, NULL, NULL
FROM raw_reviews AS r
WHERE NOT EXISTS (
    SELECT 1 FROM raw_flight_orders AS f WHERE f.user_email = r.user_email
)
AND NOT EXISTS (
    SELECT 1 FROM raw_hotel_orders AS h WHERE h.user_email = r.user_email
);

INSERT INTO passengers (passport, full_name, birth_date)
SELECT DISTINCT passenger_passport, passenger_full_name, passenger_birth_date
FROM raw_flight_orders;

-- Общие сведения заказа и оплаты объединяем из обоих типов позиций
INSERT INTO orders (order_number, user_id, created_at, status)
SELECT r.order_number, u.id, r.order_created_at, r.order_status
FROM (
    SELECT order_number, user_email, order_created_at, order_status
    FROM raw_flight_orders
    UNION
    SELECT order_number, user_email, order_created_at, order_status
    FROM raw_hotel_orders
) AS r
JOIN users AS u ON u.email = r.user_email;

INSERT INTO payment (external_payment_id, order_id, method, paid_at, amount)
SELECT r.payment_id, o.id, r.payment_method, r.paid_at, r.payment_amount
FROM (
    SELECT order_number, payment_id, payment_method, paid_at, payment_amount
    FROM raw_flight_orders
    WHERE payment_id IS NOT NULL
    UNION
    SELECT order_number, payment_id, payment_method, paid_at, payment_amount
    FROM raw_hotel_orders
    WHERE payment_id IS NOT NULL
) AS r
JOIN orders AS o ON o.order_number = r.order_number;

-- Каждая исходная позиция и каждый отзыв сохраняются отдельной строкой
INSERT INTO ticket (order_id, passenger_id, flight_id, ticket_class, price)
SELECT o.id, p.id, f.id, r.ticket_class, r.ticket_price
FROM raw_flight_orders AS r
JOIN orders AS o ON o.order_number = r.order_number
JOIN passengers AS p ON p.passport = r.passenger_passport
JOIN flights AS f ON f.flight_no = r.flight_no AND f.departure_at = r.departure_at;

INSERT INTO stay (order_id, hotel_id, check_in, check_out, guests_count)
SELECT o.id, h.id, r.check_in, r.check_out, r.guests
FROM raw_hotel_orders AS r
JOIN orders AS o ON o.order_number = r.order_number
JOIN country AS c ON c.name = r.hotel_country
JOIN city AS ci ON ci.country_id = c.id AND ci.name = r.hotel_city
JOIN hotel AS h ON h.city_id = ci.id AND h.name = r.hotel_name;

-- В отзывах страна не указана: отель определяется исходными названием и городом
INSERT INTO review (user_id, hotel_id, rating, text, created_at)
SELECT u.id, h.id, r.rating, r.review_text, r.reviewed_at
FROM raw_reviews AS r
JOIN users AS u ON u.email = r.user_email
JOIN city AS ci ON ci.name = r.hotel_city
JOIN hotel AS h ON h.city_id = ci.id AND h.name = r.hotel_name;
