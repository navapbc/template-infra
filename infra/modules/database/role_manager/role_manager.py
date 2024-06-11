from check import check
from manage import manage


def lambda_handler(event, context):
    if event == "check":
        return check()
    elif event == "enable-pgvector-extension":
        manage(enable_pgvector_extension=True)
    else:
        return manage()
