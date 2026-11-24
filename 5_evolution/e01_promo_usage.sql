-- e01. Использование промокодов
--
-- Для каждого промокода выведите код, скидку в процентах, число заказов с этим
-- промокодом (независимо от оплаты и статуса заказа) и суммарную скидку:
-- ROUND(сумма по оплаченным заказам (сумма оплаты × процент / 100), 2);
-- оплаченный заказ — заказ со статусом paid, у него есть оплата. У
-- неиспользованного промокода число применений равно 0, суммарная скидка — 0;
-- если промокод применён только к неоплаченным заказам, суммарная скидка — 0.
--
-- Вывод (колонки строго в этом порядке): promo_code, discount_percent,
-- uses_count, total_discount
-- Сортировка: promo_code
-- Колонки с нулём: total_discount. Если значения нет, выведите 0 (NULL тоже
-- допустим).
--
-- Ваш SQL код здесь

SELECT
    p.code AS promo_code,
    p.discount_percent,
    COUNT(o.id) AS uses_count,
    COALESCE(
        ROUND(SUM(pay.amount * p.discount_percent / 100), 2),
        0
    ) AS total_discount
FROM promo AS p
LEFT JOIN orders AS o ON o.promo_id = p.id
LEFT JOIN payment AS pay ON pay.order_id = o.id AND o.status = 'paid'
GROUP BY p.id
ORDER BY promo_code;
