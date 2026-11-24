-- e02. Просроченные промокоды
--
-- Выведите заказы, в которых промокод применён после окончания срока его
-- действия: номер заказа, код, дата и время создания заказа и дата окончания
-- действия. valid_until — дата (DATE); промокод действует до конца дня
-- valid_until включительно, поэтому заказ, созданный в день valid_until в
-- любое время, не просрочен, а созданный на следующий день или позже —
-- просрочен.
--
-- Вывод (колонки строго в этом порядке): order_number, promo_code, created_at,
-- valid_until
-- Сортировка: order_number
--
-- Ваш SQL код здесь

SELECT 
    o.order_number,
    p.code AS promo_code,
    o.created_at,
    p.valid_until
FROM orders AS o
JOIN promo AS p ON p.id = o.promo_id
WHERE o.created_at >= p.valid_untill + 1
ORDER BY order_number;