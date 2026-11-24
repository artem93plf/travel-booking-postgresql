-- Вопрос: какое место занимает каждый отель по цене ночи среди отелей своего города?
--
-- Требование: запрос должен использовать оконную функцию (OVER).
-- Свои запросы не должны использовать таблицы и колонки промокодов: во втором прогоне smoke alter.sql не выполняется.
--
-- Ваш SQL код здесь

SELECT
    c.name AS city_name,
    h.name AS hotel_name,
    h.price_per_night,
    RANK() OVER (
        PARTITION BY h.city_id
        ORDER BY h.price_per_night DESC
    ) AS price_rank
FROM hotel AS h
JOIN city AS c ON c.id = h.city_id
ORDER BY city_name, price_rank, hotel_name;
