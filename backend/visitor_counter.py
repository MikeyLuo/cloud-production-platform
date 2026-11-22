import json
import logging
import os

import boto3
from botocore.config import Config
from botocore.exceptions import BotoCoreError, ClientError


logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

table_name = os.environ["COUNTER_TABLE_NAME"]

dynamodb = boto3.client(
    "dynamodb",
    config=Config(
        retries={"mode": "standard", "total_max_attempts": 1},
    ),
)


def make_response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Cache-Control": "no-store",
        },
        "body": json.dumps(body),
    }


def lambda_handler(event, context):
    method = event.get("requestContext", {}).get("http", {}).get("method")

    if method != "POST":
        response = make_response(405, {"message": "Use POST to record a view."})
        response["headers"]["Allow"] = "POST"
        return response

    try:
        result = dynamodb.update_item(
            TableName=table_name,
            Key={"id": {"S": "portfolio"}},
            UpdateExpression="ADD #views :increment",
            ExpressionAttributeNames={"#views": "views"},
            ExpressionAttributeValues={":increment": {"N": "1"}},
            ReturnValues="UPDATED_NEW",
        )
    except (BotoCoreError, ClientError):
        logger.exception("Could not update the page-view counter.")
        return make_response(503, {"message": "Counter temporarily unavailable."})

    views = int(result["Attributes"]["views"]["N"])
    return make_response(200, {"views": views})