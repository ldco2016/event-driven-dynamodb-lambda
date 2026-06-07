import json

def lambda_handler(event, context):
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            new_item = record['dynamodb']['NewImage']
            transaction_id = new_item['TransactionID']['S']
            print("New transaction:", transaction_id)