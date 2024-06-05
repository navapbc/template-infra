import os

from pg8000.native import Connection

import db


def check():
    """Check that database roles, schema, and privileges were
    properly configured
    """
    print("Running command 'check' to check database roles, schema, and privileges")
    app_username = os.environ.get("APP_USER")
    migrator_username = os.environ.get("MIGRATOR_USER")
    schema_name = os.environ.get("DB_SCHEMA")

    with (
        db.connect_using_iam(app_username) as app_conn,
        db.connect_using_iam(migrator_username) as migrator_conn,
    ):
        check_search_path(migrator_conn, schema_name)
        check_migrator_create_table(migrator_conn, app_username)
        check_app_use_table(app_conn)
        cleanup_migrator_drop_table(migrator_conn)

    return {"success": True}


def check_search_path(migrator_conn: Connection, schema_name: str):
    print("-- Check that search path is %s", schema_name)
    assert db.execute(migrator_conn, "SHOW search_path") == [[schema_name]]


def check_migrator_create_table(migrator_conn: Connection, app_username: str):
    print(
        "-- Check that migrator is able to create tables and grant access to app user: %s",
        app_username,
    )
    cleanup_migrator_drop_table(migrator_conn)
    db.execute(
        migrator_conn, "CREATE TABLE IF NOT EXISTS temporary(created_at TIMESTAMP)"
    )


def check_app_use_table(app_conn: Connection):
    print("-- Check that app is able to read and write from the table")
    db.execute(app_conn, "INSERT INTO temporary (created_at) VALUES (NOW())")
    db.execute(app_conn, "SELECT * FROM temporary")


def cleanup_migrator_drop_table(migrator_conn: Connection):
    print("-- Clean up temporary table if it exists")
    db.execute(migrator_conn, "DROP TABLE IF EXISTS temporary")
