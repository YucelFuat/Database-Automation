#!/bin/bash

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found!"
    exit 1
fi

echo "Starting PostgreSQL Database Setup..."

# Execute PostgreSQL commands
sudo -u postgres psql <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME') THEN
      CREATE DATABASE $DB_NAME;
   END IF;
END
\$\$;

\c $DB_NAME;

-- Drop view first before dropping the table (fixes dependency issue)
DROP VIEW IF EXISTS book_list CASCADE;
DROP TABLE IF EXISTS books CASCADE;

-- Create the books table
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    sub_title VARCHAR(255),
    author VARCHAR(255) NOT NULL,
    publisher VARCHAR(255) NOT NULL
);

-- Insert dummy data into books table
INSERT INTO books (title, sub_title, author, publisher) VALUES
('The Phoenix Project', 'A Novel About IT and DevOps', 'Gene Kim', 'IT Revolution'),
('The DevOps Handbook', 'How to Create World-Class Agility', 'Gene Kim', 'IT Revolution'),
('Site Reliability Engineering', 'How Google Runs Production Systems', 'Betsy Beyer', 'O’Reilly Media'),
('The Art of Monitoring', NULL, 'James Turnbull', 'Turnbull Press'),
('Clean Code', 'A Handbook of Agile Software Craftsmanship', 'Robert C. Martin', 'Prentice Hall');

-- Drop users after revoking their privileges (fixes user deletion issue)
DO \$\$
DECLARE user_exists INTEGER;
BEGIN
   SELECT COUNT(*) INTO user_exists FROM pg_roles WHERE rolname = '$DB_USER_ADMIN';
   IF user_exists > 0 THEN
      REVOKE ALL PRIVILEGES ON DATABASE $DB_NAME FROM $DB_USER_ADMIN;
      REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM $DB_USER_ADMIN;
      DROP USER $DB_USER_ADMIN;
   END IF;
END
\$\$;

DO \$\$
DECLARE user_exists INTEGER;
BEGIN
   SELECT COUNT(*) INTO user_exists FROM pg_roles WHERE rolname = '$DB_USER_VIEW';
   IF user_exists > 0 THEN
      REVOKE ALL PRIVILEGES ON DATABASE $DB_NAME FROM $DB_USER_VIEW;
      REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM $DB_USER_VIEW;
      DROP USER $DB_USER_VIEW;
   END IF;
END
\$\$;

-- Create an admin user with full privileges
CREATE USER $DB_USER_ADMIN WITH ENCRYPTED PASSWORD '$DB_PASSWORD_ADMIN';
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER_ADMIN;
GRANT ALL ON ALL TABLES IN SCHEMA public TO $DB_USER_ADMIN;

-- Create a view-only user
CREATE USER $DB_USER_VIEW WITH ENCRYPTED PASSWORD '$DB_PASSWORD_VIEW';
GRANT CONNECT ON DATABASE $DB_NAME TO $DB_USER_VIEW;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO $DB_USER_VIEW;

-- Drop function if it exists
DROP FUNCTION IF EXISTS add_book;

-- Create a function to add a book
CREATE OR REPLACE FUNCTION add_book(title VARCHAR, sub_title VARCHAR, author VARCHAR, publisher VARCHAR) RETURNS VOID AS \$\$
BEGIN
    INSERT INTO books (title, sub_title, author, publisher) VALUES (title, sub_title, author, publisher);
END;
\$\$ LANGUAGE plpgsql;

-- Create a view for books
CREATE VIEW book_list AS
SELECT id, title, author, publisher FROM books;

GRANT SELECT ON book_list TO $DB_USER_VIEW;

EOF

echo "PostgreSQL Database Setup Completed Successfully!"

