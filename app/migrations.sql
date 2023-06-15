CREATE TABLE IF NOT EXISTS migrations (
    last_migration_date TIMESTAMP
);

TRUNCATE TABLE migrations;

INSERT INTO migrations (last_migration_date)
VALUES (NOW());

SELECT * FROM migrations;
