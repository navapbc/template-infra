/*
The SQL file used by the example db-migrate script
This sample file demonstrates the creation of a single migrations table and
stores a single row in the table of the last time migrations were run.
This simulates a simpler version of what most migration frameworks do,
which is to create a version table that stores the current state of the database.
*/

/*
Hardcoded the app username since couldn't figure out
a simple way to pull it from environment variable
*/
ALTER DEFAULT PRIVILEGES GRANT ALL ON TABLES TO app;

DROP TABLE IF EXISTS migrations;

CREATE TABLE IF NOT EXISTS migrations (
    last_migration_date TIMESTAMP
);

INSERT INTO migrations (last_migration_date)
VALUES (NOW());

SELECT * FROM migrations;
