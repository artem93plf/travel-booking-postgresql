-- q03. Московские рейсы октября
--
-- Выведите рейсы, вылетающие из московских аэропортов (SVO, DME, VKO) за
-- период с 1 по 31 октября 2026 года включительно с базовой ценой от 5000 до
-- 15000 включительно: номер рейса, время вылета, IATA вылета и прилёта,
-- базовая цена.
--
-- Параметры:
--   iata = SVO, DME, VKO
--   date_from = 2026-10-01
--   date_to = 2026-10-31
--   price_min = 5000
--   price_max = 15000
--
-- Вывод (колонки строго в этом порядке): flight_no, departure_at, from_iata,
-- to_iata, base_price
-- Сортировка: departure_at, flight_no
-- Баллы: 5
--
-- Ваш SQL код здесь

SELECT 
    f.flight_no,
    f.departure_at,
    af.iata AS from_iata,
    at.iata AS to_iata,
    f.base_price
FROM flights AS f 
JOIN airports AS af ON af.id = f.from_airport_id
JOIN airports AS at ON at.id = f.to_airport_id
WHERE af.iata IN ('SVO', 'DME', 'VKO') 
    AND f.departure_at >= '2026-10-01'
    AND f.departure_at < '2026-11-01'
    AND f.base_price BETWEEN 5000 AND 15000
ORDER BY departure_at, flight_no;
