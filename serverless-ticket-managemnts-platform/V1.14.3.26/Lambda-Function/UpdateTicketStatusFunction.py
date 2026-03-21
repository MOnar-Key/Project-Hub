import json
import boto3
import os

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])


def lambda_handler(event, context):
    try:
        ticket_id = event["pathParameters"]["id"]
        body = json.loads(event.get("body", "{}"))

        status = body.get("status")

        if not status:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "status is required"})
            }

        table.update_item(
            Key={"ticketID": ticket_id},
            UpdateExpression="SET #s = :s",
            ExpressionAttributeNames={"#s": "status"},
            ExpressionAttributeValues={":s": status},
            ConditionExpression="attribute_exists(ticketID)"
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Ticket status updated"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }