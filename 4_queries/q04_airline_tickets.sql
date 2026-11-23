-- q04. Билеты по авиакомпаниям
--
-- Для каждой авиакомпании выведите название, число проданных билетов и среднюю
-- цену билета (округлите до 2 знаков). Авиакомпании без билетов тоже должны
-- попасть в результат. Учитываются все билеты независимо от статуса заказа. У
-- авиакомпании без билетов tickets_count = 0, avg_ticket_price = NULL.
--
-- Вывод (колонки строго в этом порядке): airline_name, tickets_count,
-- avg_ticket_price
-- Сортировка: airline_name
-- Баллы: 10
--
-- Ваш SQL код здесь

SELECT
    a.name AS airline_name,
    COUNT(t.id) AS tickets_count,
    ROUND(AVG(t.price), 2) AS avg_ticket_price
FROM airline AS a
LEFT JOIN flights AS f ON f.airline_id = a.id
LEFT JOIN ticket AS t ON t.flight_id = f.id
GROUP BY a.id, a.name
ORDER BY airline_name;