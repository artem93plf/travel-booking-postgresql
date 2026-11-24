-- d03. Удаление отзывов без проживания
--
-- Удалите отзывы пользователей, которые ни разу не жили в отеле, о котором
-- оставили отзыв (используйте DELETE с подзапросом). Заказы учитываются в
-- любом статусе заказа.
--
-- Ваш SQL код здесь

DELETE FROM review AS r
WHERE NOT EXISTS (
    SELECT 1
    FROM orders AS o
    JOIN stay AS s ON s.order_id = o.id
    AND o.user_id = r.user_id 
    AND s.hotel_id = r.hotel_id
);
