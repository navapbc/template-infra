import logging
import os

import boto3

logger = logging.getLogger()


def create_upload_url(path):
    bucket_name = os.environ.get("BUCKET_NAME")

    s3_client = boto3.client("s3")
    logger.info("Generating presigned POST URL")
    response = s3_client.generate_presigned_post(bucket_name, path)
    return response["url"], response["fields"]
