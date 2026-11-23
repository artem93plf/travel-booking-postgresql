-- Создайте схему базы данных: все таблицы, первичные и внешние ключи, ограничения
-- (UNIQUE, NOT NULL, CHECK) и типы данных по вашей ER-диаграмме.
--
-- Общее требование: оплата (payment) — отдельная сущность, а не поле заказа;
-- пассажир и пользователь — разные сущности (пассажир ≠ пользователь).
-- Правила целостности из negative_tests.sql должны обеспечиваться самой схемой.
--
-- Ваш SQL код здесь
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone_main VARCHAR(20),
    phone_extra VARCHAR(20) 
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    user_id INT NOT NULL REFERENCES users(id),
    created_at TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('created', 'paid', 'cancelled'))
);

CREATE TABLE payment (
    id serial PRIMARY KEY,
    external_payment_id VARCHAR(50) UNIQUE NOT NULL,
    order_id INT UNIQUE NOT NULL REFERENCES orders(id),
    method VARCHAR(20) NOT NULL,
    paid_at TIMESTAMP NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0)
);

CREATE TABLE passengers (
    id SERIAL PRIMARY KEY,
    passport VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    birth_date DATE NOT NULL
);

CREATE TABLE ticket (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    passenger_id INT NOT NULL REFERENCES passengers(id),
    flight_id INT NOT NULL REFERENCES flights(id),
    ticket_class VARCHAR(20) NOT NULL CHECK (ticket_class IN ('economy', 'business', 'comfort')),
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0)
);

CREATE TABLE airline (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);

