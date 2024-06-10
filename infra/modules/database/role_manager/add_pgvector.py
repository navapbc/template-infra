import db


def add_pgvector():
    """Create the pgvector extension in the search path so it is available
    to database users
    """
    print("Running command 'add-pgvector' to create the pgvector extension")
    with db.connect_as_master_user() as conn:
        conn.run("CREATE EXTENSION IF NOT EXISTS vector SCHEMA pg_catalog")
    return {"success": True}