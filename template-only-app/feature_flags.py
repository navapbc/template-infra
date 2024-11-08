import logging
import os

import boto3

logger = logging.getLogger()


def is_feature_enabled(feature_name: str) -> bool:
    feature_flags_project_name = os.environ.get("FEATURE_FLAGS_PROJECT")

    logger.info("Getting Evidently client")
    client = boto3.client("evidently")

    response = client.evaluate_feature(
        entityId="anonymous",
        feature=feature_name,
        project=feature_flags_project_name,
    )
    return response["value"]["boolValue"]
