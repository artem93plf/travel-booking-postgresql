-- q07. Отели без заездов
--
-- Выведите отели, в которых не было ни одного заезда с 1 по 30 сентября 2026
-- года включительно: название отеля и город. Отели вообще без проживаний тоже
-- входят.
--
-- Параметры:
--   check_in_from = 2026-09-01
--   check_in_to = 2026-09-30
--
-- Вывод (колонки строго в этом порядке): hotel_name, city_name
-- Сортировка: hotel_name
-- Баллы: 10
--
-- Ваш SQL код здесь

SELECT 
    h.name AS hotel_name,
    c.name AS city_name
FROM hotel AS h
JOIN city AS c ON h.city_id = c.id
WHERE NOT EXISTS (
    SELECT 1
    FROM stay AS s
    WHERE s.check_in >= '2026-09-01' 
    AND s.check_in < '2026-10-01'
    AND h.id = s.hotel_id
)
ORDER BY hotel_name;