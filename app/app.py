import logging
import os
from datetime import datetime

from flask import Flask

from db import get_db_connection
from feature_flags import is_feature_enabled
from storage import create_upload_url

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


@app.route("/feature-flags")
def feature_flags():
    foo_status = "enabled" if is_feature_enabled("foo") else "disabled"
    bar_status = "enabled" if is_feature_enabled("bar") else "disabled"

    return f"<p>Feature foo is {foo_status}</p><p>Feature bar is {bar_status}</p>"


@app.route("/document-upload")
def document_upload():
    path = f"uploads/{datetime.now().date()}/${{filename}}"
    upload_url, fields = create_upload_url(path)
    additional_fields = "".join(
        [
            f'<input type="hidden" name="{name}" value="{value}">'
            for name, value in fields.items()
        ]
    )
    # Note: Additional fields should come first before the file and submit button
    return f'<form method="post" action="{upload_url}" enctype="multipart/form-data">{additional_fields}<input type="file" name="file"><input type="submit"></form>'


if __name__ == "__main__":
    main()
