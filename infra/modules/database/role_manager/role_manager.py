from check import check
from manage import manage


def lambda_handler(event, context):
    if event.__class__ is dict and "action" in event and "config" in event:
        if event["action"] == "check":
            return check(event["config"])
        elif event["action"] == "manage":
            return manage(event["config"])
    
    raise Exception("Invalid payload, could not find an action to perform in the lambda handler")