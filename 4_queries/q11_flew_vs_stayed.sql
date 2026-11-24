-- q11. Летал и жил
--
-- Для пользователя с email anna.volkova@tmail.test выведите города, куда он
-- летал (город прилёта билетов его заказов) и где при этом жил
-- (flew_and_stayed), и города, куда летал, но не жил (flew_only). Заказы
-- учитываются в любом статусе заказа.
--
-- Параметры:
--   user_email = anna.volkova@tmail.test
--   categories = flew_and_stayed, flew_only
--
-- Вывод (колонки строго в этом порядке): city_name, category
-- Сортировка: category, city_name
-- Баллы: 10
--
-- Ваш SQL код здесь

SELECT
    destinations.city_name,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM orders AS o
            JOIN stay AS s ON s.order_id = o.id
            JOIN hotel AS h ON h.id = s.hotel_id
            WHERE o.user_id = destinations.user_id
              AND h.city_id = destinations.city_id
        ) THEN 'flew_and_stayed'
        ELSE 'flew_only'
    END AS category
FROM (
    SELECT DISTINCT
        u.id AS user_id,
        c.id AS city_id,
        c.name AS city_name
    FROM users AS u
    JOIN orders AS o ON o.user_id = u.id
    JOIN ticket AS t ON t.order_id = o.id
    JOIN flights AS f ON f.id = t.flight_id
    JOIN airports AS a ON a.id = f.to_airport_id
    JOIN city AS c ON c.id = a.city_id
    WHERE u.email = 'anna.volkova@tmail.test'
) AS destinations
ORDER BY category, city_name;


