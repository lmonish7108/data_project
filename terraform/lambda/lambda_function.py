import json
import boto3

firehose_client = boto3.client('firehose', region_name='eu-west-2')

def lambda_handler(event, context):
    response = firehose_client.put_record(
        DeliveryStreamName='push-to-s3',
        Record={
            'Data': bytes(json.dumps(event["body"]).encode('utf-8'))
        }
    )
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }
