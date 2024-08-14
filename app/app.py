import logging
import os
from datetime import datetime

import click
from flask import Flask, render_template

import storage
from db import get_db_connection
from feature_flags import is_feature_enabled

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
    return render_template("index.html")


@app.route("/health")
def health():
    conn = get_db_connection()
    conn.execute("SELECT 1")
    return {
        "status": "healthy",
        "version": os.environ.get("IMAGE_TAG"),
    }


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


@app.route("/feature-flags")
def feature_flags():
    foo_status = "enabled" if is_feature_enabled("foo") else "disabled"
    bar_status = "enabled" if is_feature_enabled("bar") else "disabled"

    return f"<p>Feature foo is {foo_status}</p><p>Feature bar is {bar_status}</p>"


@app.route("/document-upload")
def document_upload():
    path = f"uploads/{datetime.now().date()}/${{filename}}"
    upload_url, fields = storage.create_upload_url(path)
    additional_fields = "".join(
        [
            f'<input type="hidden" name="{name}" value="{value}">'
            for name, value in fields.items()
        ]
    )
    # Note: Additional fields should come first before the file and submit button
    return f'<form method="post" action="{upload_url}" enctype="multipart/form-data">{additional_fields}<input type="file" name="file"><input type="submit"></form>'


@app.route("/secrets")
def secrets():
    secret_sauce = os.environ["SECRET_SAUCE"]
    random_secret = os.environ["RANDOM_SECRET"]
    return f'The secret sauce is "{secret_sauce}".<br> The random secret is "{random_secret}".'


@app.cli.command("etl", help="Run ETL job")
@click.argument("input")
def etl(input):
    # input should be something like "etl/input/somefile.ext"
    assert input.startswith("etl/input/")
    output = input.replace("/input/", "/output/")
    data = storage.download_file(input)
    storage.upload_file(output, data)


if __name__ == "__main__":
    main()
