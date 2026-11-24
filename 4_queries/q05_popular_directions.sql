-- q05. Популярные направления
--
-- Выведите направления (город вылета, город прилёта), на которые в октябре
-- 2026 года (по дате вылета) куплено строго больше 3 билетов только в заказах
-- в статусе paid, с числом пассажиров. Сначала самые популярные.
-- passengers_count — число билетов (каждый билет — один пассажир на одном
-- рейсе); направление — пара «город вылета → город прилёта» (аэропорты одного
-- города объединяются).
--
-- Параметры:
--   departure_month = 2026-10
--   order_status = paid
--   min_passengers_exclusive = 3
--
-- Вывод (колонки строго в этом порядке): from_city, to_city, passengers_count
-- Сортировка: passengers_count DESC, from_city, to_city
-- Баллы: 10
--
-- Ваш SQL код здесь

SELECT
    cf.name AS from_city,
    ct.name AS to_city,
    COUNT(t.id) AS passengers_count
FROM ticket AS t
JOIN orders AS o ON o.id = t.order_id
JOIN flights AS f ON f.id = t.flight_id
JOIN airports AS af ON af.id = f.from_airport_id
JOIN airports AS at ON at.id = f.to_airport_id
JOIN city AS cf ON cf.id = af.city_id
JOIN city AS ct ON ct.id = at.city_id
WHERE o.status = 'paid'
  AND f.departure_at >= '2026-10-01'
  AND f.departure_at < '2026-11-01'
GROUP BY cf.id, cf.name, ct.id, ct.name
HAVING COUNT(t.id) > 3
ORDER BY passengers_count DESC, from_city, to_city;