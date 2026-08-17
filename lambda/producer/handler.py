import json
import os
import uuid
import boto3

sqs = boto3.client("sqs")
dynamodb = boto3.resource("dynamodb")

QUEUE_URL = os.environ["QUEUE_URL"]
TABLE_NAME = os.environ["TABLE_NAME"]

table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    body = json.loads(event.get("body", "{}"))

    job_id = str(uuid.uuid4())

    item = {
        "event_id": job_id,
        "status": "QUEUED",
        "payload": body
    }

    table.put_item(Item=item)

    sqs.send_message(
        QueueUrl=QUEUE_URL,
        MessageBody=json.dumps({
            "event_id": job_id,
            "payload": body
        })
    )

    return {
        "statusCode": 202,
        "body": json.dumps({
            "message": "Job accepted",
            "event_id": job_id
        })
    }