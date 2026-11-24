-- q06. Маршруты пассажира
--
-- Выведите все билеты пассажира с паспортом 4510 123456 в порядке вылета:
-- время вылета, номер рейса, IATA и город вылета, IATA и город прилёта, класс
-- билета. Паспорт указан в том формате, в котором он хранится в исходных
-- данных raw.
--
-- Параметры:
--   passport = 4510 123456
--
-- Вывод (колонки строго в этом порядке): departure_at, flight_no, from_iata,
-- from_city, to_iata, to_city, ticket_class
-- Сортировка: departure_at
-- Баллы: 10
--
-- Ваш SQL код здесь

SELECT
    f.departure_at,
    f.flight_no,
    af.iata AS from_iata,
    cf.name AS from_city,
    at.iata AS to_iata,
    ct.name AS to_city,
    t.ticket_class
FROM ticket AS t
JOIN passengers AS p ON p.id = t.passenger_id
JOIN flights AS f ON f.id = t.flight_id
JOIN airports AS af ON af.id = f.from_airport_id
JOIN city AS cf ON cf.id = af.city_id
JOIN airports AS at ON at.id = f.to_airport_id
JOIN city AS ct ON ct.id = at.city_id
WHERE p.passport = '4510 123456'
ORDER BY f.departure_at;