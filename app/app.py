import logging
import os

import boto3
from flask import Flask
import psycopg
import psycopg.conninfo

logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.INFO)

app = Flask(__name__)

def main():
    host = os.environ.get("HOST")
    port = os.environ.get("PORT")
    logger.info("Running Flask app on host %s and port %s", host, port)
    app.run(host=host, port=port)


@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


@app.route("/health")
def health():
    conn = get_db_connection()
    conn.execute("SELECT 1")
    return "OK"

@app.route("/migrations")
def migrations():
    conn = get_db_connection()
    cur = conn.execute("SELECT last_migration_date FROM migrations")
    row = cur.fetchone
    if row is None:
        return "No migrations run"
    else:
        last_migration_date = cur.fetchone()[0]
        return f"Last migration on {last_migration_date}"

def get_db_token(host, port, user):
    region = os.environ.get("AWS_REGION")

    # gets the credentials from .aws/credentials
    logger.info("Getting RDS client for region %s", region)
    client = boto3.client("rds", region_name=region)

    logger.info("Generating auth token for user %s", user)
    token = client.generate_db_auth_token(DBHostname=host, Port=port, DBUsername=user, Region=region)
    return token


def get_db_connection():
    host = os.environ.get("DB_HOST")
    port = os.environ.get("DB_PORT")
    user = os.environ.get("DB_USER")

    # Tokens last for 15 minutes, so normally you wouldn't need to generate
    # an auth token every time you create a new connection, but we do that
    # here to keep the example app simple.
    password = get_db_token(host, port, user)
    dbname = os.environ.get("DB_NAME")

    conninfo = psycopg.conninfo.make_conninfo(host=host, port=port, user=user, password=password, dbname=dbname)

    conn = psycopg.connect(conninfo)
    return conn


if __name__ == "__main__":
    main()
