-- q13. Первые заказы
--
-- Для каждого пользователя, сделавшего заказы, выведите его самый первый
-- заказ: email, номер заказа, дата создания. При равенстве created_at берите
-- заказ с меньшим номером.
--
-- Вывод (колонки строго в этом порядке): user_email, order_number, created_at
-- Сортировка: user_email
-- Баллы: 10
--
-- Ваш SQL код здесь

SELECT
    ranked.user_email,
    ranked.order_number,
    ranked.created_at
FROM (
    SELECT
        u.email AS user_email,
        o.order_number,
        o.created_at,
        ROW_NUMBER() OVER (
            PARTITION BY u.id
            ORDER BY o.created_at, o.order_number
        ) AS rn
    FROM users AS u
    JOIN orders AS o ON o.user_id = u.id
) AS ranked
WHERE ranked.rn = 1
ORDER BY user_email;
