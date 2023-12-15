import logging
import os

import boto3
from botocore.client import Config

logger = logging.getLogger()


def create_upload_url(path):
    bucket_name = os.environ.get("BUCKET_NAME")

    # Manually specify signature version 4 which is required since the bucket is encrypted with KMS.
    # By default presigned URLs use signature version 2 to be backwards compatible
    s3_client = boto3.client("s3", config=Config(signature_version="s3v4"))
    logger.info("Generating presigned POST URL")
    response = s3_client.generate_presigned_post(bucket_name, path)
    return response["url"], response["fields"]
