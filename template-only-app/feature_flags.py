import logging
import os
import boto3
logger = logging.getLogger()
def is_feature_enabled(feature_name: str) -> bool:
    value = os.environ.get(f"FF_{feature_name}".upper())
    return value == "true" if value else False

