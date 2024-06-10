from check import check
from manage import manage
from add_pgvector import add_pgvector


def lambda_handler(event, context):
    if event == "check":
        return check()
    elif event == "add-pgvector":
        return add_pgvector()
    else:
        return manage()
