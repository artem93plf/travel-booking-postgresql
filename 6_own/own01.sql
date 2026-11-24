-- Вопрос: сколько заказов в каждом статусе оформил каждый пользователь
--
-- Требование: запрос должен использовать JOIN.
-- Свои запросы не должны использовать таблицы и колонки промокодов: во втором прогоне smoke alter.sql не выполняется.
--
-- Ваш SQL код здесь

SELECT 
    u.email AS user_email,
    o.status AS order_status,
    COUNT(o.id) AS order_count
FROM orders AS o
JOIN users AS u ON o.user_id = u.id
GROUP BY u.email, o.status
ORDER BY u.email, o.status;