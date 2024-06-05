from check import check
from manage import manage


def lambda_handler(event, context):
    if event == "check":
        return check()
    else:
        return manage()
