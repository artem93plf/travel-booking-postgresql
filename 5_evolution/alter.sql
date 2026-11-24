-- Эволюция схемы: промокоды
--
-- Сервис запускает промокоды. Промокод — это код (уникален), скидка в
-- процентах (целое число от 1 до 50) и срок действия: дата начала valid_from и
-- дата окончания valid_until (тип DATE, valid_from не позже valid_until).
-- valid_until — дата, а не момент времени: промокод действует до конца дня
-- valid_until включительно, то есть заказ, созданный в день valid_until в
-- любое время, ещё в сроке. К заказу можно применить не больше одного
-- промокода (у заказа промокода может и не быть). В alter.sql добавьте
-- промокоды из списка промокодов ниже и примените их к заказам по списку
-- применений ниже (номер заказа → код). Промокод BLACKFRIDAY50 — акция,
-- которая ещё не началась (valid_from позже «сегодня», 2026-11-01), поэтому
-- заказов с ним пока нет: ни одного применения у него быть не должно.
--
-- Промокоды (code, discount_percent, valid_from, valid_until):
--   NEWYEAR10, 10, 2026-01-01, 2026-01-10
--   MAYDAY15, 15, 2026-04-25, 2026-05-02
--   SUMMER20, 20, 2026-06-01, 2026-08-31
--   AUTUMN5, 5, 2026-10-01, 2026-10-31
--   BLACKFRIDAY50, 50, 2026-11-27, 2026-11-30
--
-- Применение к заказам (номер заказа -> код):
--   TP-10001 -> NEWYEAR10
--   TP-10010 -> NEWYEAR10
--   TP-10013 -> NEWYEAR10
--   TP-10016 -> NEWYEAR10
--   TP-10053 -> MAYDAY15
--   TP-10054 -> MAYDAY15
--   TP-10057 -> MAYDAY15
--   TP-10060 -> MAYDAY15
--   TP-10061 -> MAYDAY15
--   TP-10097 -> SUMMER20
--   TP-10113 -> SUMMER20
--   TP-10125 -> SUMMER20
--   TP-10159 -> AUTUMN5
--   TP-10162 -> AUTUMN5
--
-- Ваш SQL код здесь

CREATE TABLE promo (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_percent INT NOT NULL,
    CHECK(discount_percent >= 1 AND discount_percent <= 50),
    valid_from DATE NOT NULL,
    valid_until DATE NOT NULL,
    CHECK (valid_from <= valid_until)
);

ALTER TABLE orders
ADD COLUMN promo_id INT REFERENCES promo(id);

INSERT INTO promo (code, discount_percent, valid_from, valid_until)
VALUES
    ('NEWYEAR10', 10, '2026-01-01', '2026-01-10'),
    ('MAYDAY15', 15, '2026-04-25', '2026-05-02'),
    ('SUMMER20', 20, '2026-06-01', '2026-08-31'),
    ('AUTUMN5', 5, '2026-10-01', '2026-10-31'),
    ('BLACKFRIDAY50', 50, '2026-11-27', '2026-11-30');

UPDATE orders
SET promo_id = (
    SELECT id
    FROM promo
    WHERE code = 'NEWYEAR10'
)
WHERE order_number IN (
    'TP-10001',
    'TP-10010',
    'TP-10013',
    'TP-10016'
);

UPDATE orders
SET promo_id = (
    SELECT id
    FROM promo
    WHERE code = 'MAYDAY15'
)
WHERE order_number IN (
    'TP-10053',
    'TP-10054',
    'TP-10057',
    'TP-10060',
    'TP-10061'
);

UPDATE orders
SET promo_id = (
    SELECT id
    FROM promo
    WHERE code = 'SUMMER20'
)
WHERE order_number IN (
    'TP-10097',
    'TP-10113',
    'TP-10125'
);

UPDATE orders
SET promo_id = (
    SELECT id
    FROM promo
    WHERE code = 'AUTUMN5'
)
WHERE order_number IN (
    'TP-10159',
    'TP-10162'
);
