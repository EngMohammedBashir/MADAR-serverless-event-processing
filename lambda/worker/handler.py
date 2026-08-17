import json
import os
import boto3

dynamodb = boto3.resource("dynamodb")
s3 = boto3.client("s3")
sns = boto3.client("sns")

TABLE_NAME = os.environ["TABLE_NAME"]
BUCKET_NAME = os.environ["BUCKET_NAME"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]

table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    for record in event["Records"]:
        message = json.loads(record["body"])

        event_id = message["event_id"]
        payload = message["payload"]
            
        table.update_item(
            Key={"event_id": event_id},
            UpdateExpression="SET #status = :status",
            ExpressionAttributeNames={
                "#status": "status"
            },
            ExpressionAttributeValues={
                ":status": "PROCESSED"
            }
        )

        s3.put_object(
            Bucket=BUCKET_NAME,
            Key=f"processed/{event_id}.json",
            Body=json.dumps(payload)
        )

        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="MADAR Job Processed",
            Message=f"Job {event_id} processed successfully"
        )

    return {
        "statusCode": 200
    }