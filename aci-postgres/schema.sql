CREATE TABLE IF NOT EXISTS users(
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    PRIMARY KEY(id),
    firstname TEXT NOT NULL,
    lastname TEXT NOT NULL,
    gender VARCHAR(6) NOT NULL CHECK (gender IN ('male', 'female'))
);