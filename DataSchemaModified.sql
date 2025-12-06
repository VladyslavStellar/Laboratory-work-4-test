CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,

    CONSTRAINT chk_email_format CHECK (
        email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'
    )
);

CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    coordinates VARCHAR(50) NOT NULL,
    address VARCHAR(200),
    entry_fee DECIMAL(10, 2) DEFAULT 0.00,
    is_open BOOLEAN DEFAULT TRUE,

    -- Перевірка формату координат (напр. "48.8566, 2.3522")
    CONSTRAINT chk_coordinates_format CHECK (
        coordinates ~ '^-?\d{1,3}\.\d+, -?\d{1,3}\.\d+$'
    ),
    -- Ціна не може бути від'ємною
    CONSTRAINT chk_entry_fee_positive CHECK (entry_fee >= 0)
);

CREATE TABLE air_quality_logs (
    log_id BIGSERIAL PRIMARY KEY,
    location_id INT NOT NULL,
    aqi_value INT NOT NULL,
    status_text VARCHAR(20),
    measured_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_aqi_location FOREIGN KEY (location_id) REFERENCES locations (
        location_id
    ) ON DELETE CASCADE,
    -- AQI не може бути менше 0
    CONSTRAINT chk_aqi_range CHECK (aqi_value >= 0)
);

CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    biography TEXT
);

CREATE TABLE poetry_collections (
    collection_id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    publication_year INT,

    -- Рік не може бути у майбутньому
    CONSTRAINT chk_year CHECK (
        publication_year <= EXTRACT(YEAR FROM CURRENT_DATE)
    )
);

CREATE TABLE poems (
    poem_id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    full_text TEXT NOT NULL,
    genre VARCHAR(50),
    author_id INT NOT NULL,
    collection_id INT, -- Може бути NULL, якщо вірш не в збірці
    location_id INT, 

    CONSTRAINT fk_poem_author FOREIGN KEY (author_id) REFERENCES authors (
        author_id
    ) ON DELETE CASCADE,
    CONSTRAINT fk_poem_collection FOREIGN KEY (
        collection_id
    ) REFERENCES poetry_collections (collection_id) ON DELETE SET NULL

    CONSTRAINT fk_poem_location FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE SET NULL
);

-- Проміжна таблиця: збережені вірші(User <-> Poem)
CREATE TABLE user_saved_poems (
    saved_id BIGSERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    poem_id BIGINT NOT NULL,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_saved_user FOREIGN KEY (user_id) REFERENCES users (
        user_id
    ) ON DELETE CASCADE,
    CONSTRAINT fk_saved_poem FOREIGN KEY (poem_id) REFERENCES poems (
        poem_id
    ) ON DELETE CASCADE,

    -- Унікальність: Юзер не може зберегти один вірш двічі
    CONSTRAINT uq_user_poem UNIQUE (user_id, poem_id)
);
