-- d01. Отмена неоплаченных заказов
--
-- Переведите в статус cancelled все заказы в статусе created без оплаты,
-- созданные раньше 2026-10-01. Оплаченные и более новые заказы затрагивать
-- нельзя.
--
-- Ваш SQL код здесь

UPDATE orders AS o
SET status = 'cancelled'
WHERE NOT EXISTS (
    SELECT 1
    FROM payment AS p
    WHERE p.order_id = o.id)
AND created_at < '2026-10-01'
AND o.status = 'created'; 