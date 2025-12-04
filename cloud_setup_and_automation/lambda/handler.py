#AWS Invokes Lambda handler whenever S3 fires an event notification
#Lambda accesses the record and extracts bucket name , object key, and size - logging in CLoudwatch

import json
import logging
import os

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")

DATA_BUCKET_NAME = os.environ.get("DATA_BUCKET_NAME", "")

def lambda_handler(event, context):
    logger.info("receive event: %s", json.dumps(event))
    
    for record in event.get("Records", []):
        s3_info = record.get("s3", {})
        bucket_name = s3_info.get("bucket", {}).get("name")
        object_key = s3_info.get("object", {}).get("key")
        object_size = s3_info.get("object", {}).get("size")
        
        logger.info(
            "New object created - bucket: %s, key: %s, size: %s bytes",
            bucket_name,
            object_key,
            object_size,
        )
        #Handler for files not not put in /incoming file location 
        if bucket_name != DATA_BUCKET_NAME:
            logger.warning(
                "Ignore object from unexpected bucket: %s (expected %s)", bucket_name, DATA_BUCKET_NAME
            )
            continue
        
        if not object_key.startswith("incoming/"):
            logger.info(
                "Object key %s is not under 'incoming/'. Skipping", object_key
            )
            continue
            
        filename = object_key[len("incoming/"):]
        destination_key = f"processed/{filename}"
        
        logger.info(
            "Copying object from %s to %s within bucket %s",
            object_key,
            destination_key,
            bucket_name,
        )
#Exception handling
        try:
            copy_source = {"Bucket": bucket_name, "Key": object_key}

            s3.copy_object(
                Bucket=bucket_name,
                Key=destination_key,
                CopySource=copy_source,
            )

            logger.info(
                "Successfully copied %s to %s in bucket %s",
                object_key,
                destination_key,
                bucket_name,
            )
        except Exception as e:
            logger.exception(
                "Error while copying object %s to %s: %s",
                object_key,
                destination_key,
                str(e),
            )
            raise

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Processing complete"}),
    }