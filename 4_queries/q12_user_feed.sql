-- q12. Лента активностей
--
-- Для пользователя с email ivan.sokolov@mail.test выведите единую ленту
-- активностей по дате: перелёты (дата вылета, номер рейса, цена билета) и
-- проживания (дата заезда, название отеля, стоимость). В колонке kind укажите
-- flight или hotel. Каждый билет и каждое проживание — отдельная строка ленты.
-- activity_at — дата и время; для проживания — полночь дня заезда.
--
-- Параметры:
--   user_email = ivan.sokolov@mail.test
--   kinds = flight, hotel
--
-- Вывод (колонки строго в этом порядке): activity_at, kind, title, amount
-- Сортировка: activity_at, kind, title, amount
-- Баллы: 10
--
-- Ваш SQL код здесь

SELECT
    f.departure_at AS activity_at,
    'flight' AS kind,
    f.flight_no AS title,
    t.price AS amount
FROM users AS u
JOIN orders AS o ON o.user_id = u.id
JOIN ticket AS t ON t.order_id = o.id
JOIN flights AS f ON f.id = t.flight_id
WHERE u.email = 'ivan.sokolov@mail.test'

UNION ALL

SELECT
    CAST(s.check_in AS TIMESTAMP) AS activity_at,
    'hotel' AS kind,
    h.name AS title,
    (s.check_out - s.check_in) * h.price_per_night AS amount
FROM users AS u
JOIN orders AS o ON o.user_id = u.id
JOIN stay AS s ON s.order_id = o.id
JOIN hotel AS h ON h.id = s.hotel_id
WHERE u.email = 'ivan.sokolov@mail.test'
ORDER BY activity_at, kind, title, amount;
