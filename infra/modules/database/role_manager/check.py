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
        check_migrator_create_table(migrator_conn)
        check_app_use_table(app_conn)
        cleanup_migrator_drop_table(migrator_conn)

    return {"success": True}


def check_search_path(migrator_conn: Connection, schema_name: str):
    print("-- Check that search path is %s", schema_name)
    assert db.execute(migrator_conn, "SHOW search_path") == [[schema_name]]


def check_migrator_create_table(migrator_conn: Connection):
    print(f"-- Check that migrator is able to create tables")
    cleanup_migrator_drop_table(migrator_conn)
    db.execute(
        migrator_conn,
        "CREATE TABLE IF NOT EXISTS role_manager_test(created_at TIMESTAMP)",
    )


def check_app_use_table(app_conn: Connection):
    app_username = app_conn.user.decode("utf-8")
    print(f"-- Check that {app_username} is able to read and write from the table")
    db.execute(app_conn, "INSERT INTO role_manager_test (created_at) VALUES (NOW())")
    db.execute(app_conn, "SELECT * FROM role_manager_test")


def cleanup_migrator_drop_table(migrator_conn: Connection):
    print("-- Clean up role_manager_test table if it exists")
    db.execute(migrator_conn, "DROP TABLE IF EXISTS role_manager_test")
