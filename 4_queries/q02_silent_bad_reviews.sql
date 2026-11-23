-- q02. Молчаливые низкие оценки
--
-- Выведите отзывы без текста с оценкой не выше 2, оставленные пользователями с
-- email вида «…@tmail.test»: email пользователя, название отеля, оценка и дата
-- отзыва. Текст отзыва отсутствует (NULL).
--
-- Параметры:
--   email_like = %@tmail.test
--   max_rating = 2
--
-- Вывод (колонки строго в этом порядке): user_email, hotel_name, rating,
-- reviewed_at
-- Сортировка: reviewed_at, user_email
-- Баллы: 5
--
-- Ваш SQL код здесь

SELECT 
    u.email AS user_email,
    h.name AS hotel_name,
    r.rating AS rating, 
    r.created_at AS reviewed_at
FROM review AS r
JOIN users AS u ON r.user_id = u.id
JOIN hotel AS h ON r.hotel_id = h.id
WHERE r.rating <= 2 AND r.text IS NULL AND u.email LIKE '%@tmail.test'
ORDER BY reviewed_at, user_email;


