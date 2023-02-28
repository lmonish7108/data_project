import boto3
from datetime import datetime
import json
import time

firehose_client = boto3.client('firehose', region_name='eu-west-2')

def lambda_handler(event, context):
    stream_data = bytes(json.dumps(event['body']).encode('utf-8'))
    filename = f'{str(time.time() * 1000)}.json'
    response = firehose_client.put_record(
        DeliveryStreamName='push-to-s3-data-stream',
        Record={
            'Data': stream_data
        }
    )
    return {
        'statusCode': 200,
        'body': json.dumps('S3 file uploaded succesfully')
    }
