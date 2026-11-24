-- q09. Сводка по городам
--
-- Для каждого города, где был хотя бы один вылет или хотя бы одно проживание,
-- выведите число вылетов из него и число проживаний в нём (0, если нет).
-- departures_count — число рейсов по расписанию (в исходных данных —
-- raw_flights), вылетающих из аэропортов города, включая рейсы без проданных
-- билетов; stays_count — число проживаний в отелях города в любом статусе
-- заказа.
--
-- Вывод (колонки строго в этом порядке): city_name, departures_count,
-- stays_count
-- Сортировка: city_name
-- Колонки с нулём: departures_count, stays_count. Если значения нет, выведите
-- 0 (NULL тоже допустим).
-- Баллы: 10
--
-- Ваш SQL код здесь

SELECT
    c.name AS city_name,
    (
        SELECT COUNT(f.id)
        FROM flights AS f
        JOIN airports AS a ON a.id = f.from_airport_id
        WHERE a.city_id = c.id
    ) AS departures_count,
    (
        SELECT COUNT(s.id)
        FROM stay AS s
        JOIN hotel AS h ON h.id = s.hotel_id
        WHERE h.city_id = c.id
    ) AS stays_count
FROM city AS c
WHERE EXISTS (
    SELECT 1
    FROM flights AS f
    JOIN airports AS a ON a.id = f.from_airport_id
    WHERE a.city_id = c.id
)
OR EXISTS (
    SELECT 1
    FROM stay AS s
    JOIN hotel AS h ON h.id = s.hotel_id
    WHERE h.city_id = c.id
)
ORDER BY city_name;