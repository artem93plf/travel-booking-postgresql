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
    order_id INT UNIQUE NOT NULL REFERENCES orders(id) ON DELETE CASCADE, -- При удалении заказа связанная оплата удаляется автоматически
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

CREATE TABLE country (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE city (
    id SERIAL PRIMARY KEY,
    country_id INT NOT NULL REFERENCES country(id),
    name VARCHAR(255) NOT NULL,
    UNIQUE (country_id, name)
);

CREATE TABLE airports (
    id SERIAL PRIMARY KEY,
    iata VARCHAR(3) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    city_id INT NOT NULL REFERENCES city(id)
);

CREATE TABLE airline (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE flights (
    id SERIAL PRIMARY KEY,
    flight_no VARCHAR(20) NOT NULL,
    airline_id INT NOT NULL REFERENCES airline(id),
    from_airport_id INT NOT NULL REFERENCES airports(id),
    to_airport_id INT NOT NULL REFERENCES airports(id),
    departure_at TIMESTAMP NOT NULL,
    arrival_at TIMESTAMP NOT NULL,
    CHECK (departure_at < arrival_at),
    base_price DECIMAL(10, 2) NOT NULL CHECK (base_price > 0),
    UNIQUE (flight_no, departure_at)
);


CREATE TABLE ticket (
    id SERIAL PRIMARY KEY,
    -- При удалении заказа его билеты удаляются автоматически.
    order_id INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    passenger_id INT NOT NULL REFERENCES passengers(id),
    -- Удаление вылета с существующими билетами запрещается внешним ключом.
    flight_id INT NOT NULL REFERENCES flights(id),
    ticket_class VARCHAR(20) NOT NULL CHECK (ticket_class IN ('economy', 'business', 'comfort')),
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0)
);

CREATE TABLE hotel (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    city_id INT NOT NULL REFERENCES city(id),
    UNIQUE (name, city_id),
    stars SMALLINT NOT NULL CHECK (stars >= 1 AND stars <= 5),
    price_per_night DECIMAL(10, 2) NOT NULL CHECK (price_per_night > 0)
);

CREATE TABLE stay (
    id SERIAL PRIMARY KEY,
    -- При удалении заказа его проживания удаляются автоматически.
    order_id INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    hotel_id INT NOT NULL REFERENCES hotel(id),
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    CHECK (check_in < check_out),
    guests_count INT NOT NULL CHECK (guests_count > 0)
);

CREATE TABLE review (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    hotel_id INT NOT NULL REFERENCES hotel(id),
    rating SMALLINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    text TEXT,
    created_at TIMESTAMP NOT NULL
);
