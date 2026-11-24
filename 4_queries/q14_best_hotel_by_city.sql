-- q14. Лучший отель города
--
-- Для каждого города выведите отель с наивысшей средней оценкой отзывов
-- (округлите среднюю до 2 знаков). Если лучших несколько с одинаковой оценкой,
-- выведите все. Сравнивайте точные средние, округляйте только при выводе;
-- отели без отзывов и города без отзывов не выводятся.
--
-- Вывод (колонки строго в этом порядке): city_name, hotel_name, avg_rating
-- Сортировка: city_name, hotel_name
-- Баллы: 15
--
-- Ваш SQL код здесь

SELECT
    ranked.city_name,
    ranked.hotel_name,
    ROUND(ranked.exact_avg, 2) AS avg_rating
FROM (
    SELECT
        c.name AS city_name,
        h.name AS hotel_name,
        AVG(r.rating) AS exact_avg,
        RANK() OVER (
            PARTITION BY c.id
            ORDER BY AVG(r.rating) DESC
        ) AS rating_rank
    FROM hotel AS h
    JOIN city AS c ON c.id = h.city_id
    JOIN review AS r ON r.hotel_id = h.id
    GROUP BY c.id, c.name, h.id, h.name
) AS ranked
WHERE ranked.rating_rank = 1
ORDER BY city_name, hotel_name;
