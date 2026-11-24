-- q08. Матрица авиакомпания × класс
--
-- Постройте матрицу «авиакомпания × класс билета» (economy, comfort,
-- business): для каждой пары выведите число проданных билетов, включая нули.
-- Учитываются все билеты независимо от статуса заказа.
--
-- Параметры:
--   classes = economy, comfort, business
--
-- Вывод (колонки строго в этом порядке): airline_name, ticket_class,
-- tickets_count
-- Сортировка: airline_name, ticket_class
-- Баллы: 10
--
-- Ваш SQL код здесь

SELECT
    a.name AS airline_name,
    classes.ticket_class,
    COUNT(t.id) AS tickets_count
FROM airline AS a
CROSS JOIN (
    SELECT 'economy' AS ticket_class
    UNION ALL
    SELECT 'comfort'
    UNION ALL
    SELECT 'business'
) AS classes
LEFT JOIN flights AS f ON f.airline_id = a.id
LEFT JOIN ticket AS t
    ON t.flight_id = f.id
   AND t.ticket_class = classes.ticket_class
GROUP BY a.id, classes.ticket_class
ORDER BY airline_name, ticket_class;
