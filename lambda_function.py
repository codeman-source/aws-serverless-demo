import json
from datetime import datetime

#unlike flask, it has no routes, no server, no app.run()
#Lambda just executes lambda_handler() per request.
def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "message": "Hello World from AWS Lambda",
            "time": datetime.utcnow().isoformat(),
            "cloud": "aws"
        })
    }