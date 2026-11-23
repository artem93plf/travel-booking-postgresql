-- q01. Самые дорогие проживания
--
-- Выведите 10 самых дорогих проживаний в отелях: номер заказа, отель и город
-- одной строкой в формате «Отель, Город», дату заезда, количество ночей (выезд
-- минус заезд) и стоимость проживания. nights — целое число ночей (дата выезда
-- минус дата заезда); total_cost = nights × цена за ночь отеля.
--
-- Параметры:
--   limit = 10
--
-- Вывод (колонки строго в этом порядке): order_number, hotel_city, check_in,
-- nights, total_cost
-- Сортировка: total_cost DESC, order_number, check_in
-- Баллы: 5
--
-- Ваш SQL код здесь

SELECT
    o.order_number,
    h.name || ', ' || c.name AS hotel_city,
    s.check_in,
    s.check_out - s.check_in AS nights,
    (s.check_out - s.check_in) * h.price_per_night AS total_cost
FROM stay AS s
JOIN orders AS o ON o.id = s.order_id
JOIN hotel AS h ON h.id = s.hotel_id
JOIN city AS c ON c.id = h.city_id
ORDER BY total_cost DESC, order_number, check_in
LIMIT 10;