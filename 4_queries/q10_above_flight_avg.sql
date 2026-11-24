-- q10. Билеты дороже средней по рейсу
--
-- Выведите билеты, цена которых выше средней цены билетов своего рейса: номер
-- рейса, время вылета, паспорт пассажира, цена билета и средняя цена билетов
-- рейса (округлите до 2 знаков). Сравнение выполняйте с неокруглённой средней
-- ценой рейса; в колонке flight_avg_price выводится средняя, округлённая до 2
-- знаков. Рейс — конкретный вылет (номер рейса + дата и время вылета).
--
-- Вывод (колонки строго в этом порядке): flight_no, departure_at,
-- passenger_passport, ticket_price, flight_avg_price
-- Сортировка: flight_no, departure_at, passenger_passport, ticket_price
-- Баллы: 10
--
-- Ваш SQL код здесь

SELECT
    f.flight_no,
    f.departure_at,
    p.passport AS passenger_passport,
    t.price AS ticket_price,
    ROUND(avg_prices.avg_price, 2) AS flight_avg_price
FROM ticket AS t
JOIN flights AS f ON f.id = t.flight_id
JOIN passengers AS p ON p.id = t.passenger_id
JOIN (
    SELECT flight_id, AVG(price) AS avg_price
    FROM ticket
    GROUP BY flight_id
) AS avg_prices ON avg_prices.flight_id = t.flight_id
WHERE t.price > avg_prices.avg_price
ORDER BY flight_no, departure_at, passenger_passport, ticket_price;