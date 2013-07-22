-- Load the create file via the command:
-- createdb onote
-- psql -d onote -f script/create_table.sql

CREATE TABLE users (
       id SERIAL PRIMARY KEY,
       username text NOT NULL,
       password text NOT NULL
);

CREATE TABLE onote (
       id SERIAL PRIMARY KEY,
       user_id int NOT NULL,
       name text NOT NULL,
       note text NOT NULL
);
