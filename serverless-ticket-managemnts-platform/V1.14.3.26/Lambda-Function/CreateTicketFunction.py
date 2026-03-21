import json
import boto3
import uuid
import os
from datetime import datetime

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])


def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))

        title = body.get("title")
        description = body.get("description")

        if not title or not description:
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "title and description are required"})
            }

        ticket_id = str(uuid.uuid4())

        item = {
            "ticketID": ticket_id,
            "title": title,
            "description": description,
            "status": "OPEN",
            "createdAt": datetime.utcnow().isoformat()
        }

        table.put_item(Item=item)

        return {
            "statusCode": 200,
            "body": json.dumps(item)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }