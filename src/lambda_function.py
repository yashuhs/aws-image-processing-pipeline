import os
import boto3
from PIL import Image
import io
import logging
import urllib.parse

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
s3_client = boto3.client('s3')

# Get configuration from environment variables
DESTINATION_BUCKET = os.environ.get('DESTINATION_BUCKET')
THUMBNAIL_SIZE = tuple(map(int, os.environ.get('THUMBNAIL_SIZE', '150,150').split(',')))
WEB_SIZE = tuple(map(int, os.environ.get('WEB_SIZE', '800,600').split(',')))

def resize_image(image_bytes, size):
    """Resizes an image to a specified size."""
    try:
        with Image.open(io.BytesIO(image_bytes)) as image:
            image.thumbnail(size)
            buffer = io.BytesIO()
            image_format = image.format if image.format else 'JPEG'
            image.save(buffer, format=image_format)
            return buffer.getvalue()
    except Exception as e:
        logger.error(f"Error resizing image: {e}")
        raise

def lambda_handler(event, context):
    """Main Lambda handler function triggered by S3."""
    logger.info(f"Received event: {event}")

    try:
        # Get the bucket and key from the S3 event
        source_bucket = event['Records'][0]['s3']['bucket']['name']
        # Decode the object key to handle spaces and other special characters
        object_key_raw = event['Records'][0]['s3']['object']['key']
        object_key = urllib.parse.unquote_plus(object_key_raw)

        # Download the image from the source bucket
        logger.info(f"Downloading object: {object_key} from bucket: {source_bucket}")
        response = s3_client.get_object(Bucket=source_bucket, Key=object_key)
        image_bytes = response['Body'].read()

        # Generate thumbnail
        logger.info(f"Generating thumbnail for {object_key}")
        thumbnail_bytes = resize_image(image_bytes, THUMBNAIL_SIZE)
        thumbnail_key = f"thumbnails/{os.path.basename(object_key)}"
        s3_client.put_object(Bucket=DESTINATION_BUCKET, Key=thumbnail_key, Body=thumbnail_bytes)
        logger.info(f"Uploaded thumbnail to {DESTINATION_BUCKET}/{thumbnail_key}")

        # Generate web-optimized version
        logger.info(f"Generating web version for {object_key}")
        web_bytes = resize_image(image_bytes, WEB_SIZE)
        web_key = f"web/{os.path.basename(object_key)}"
        s3_client.put_object(Bucket=DESTINATION_BUCKET, Key=web_key, Body=web_bytes)
        logger.info(f"Uploaded web version to {DESTINATION_BUCKET}/{web_key}")

        return {'statusCode': 200, 'body': f"Successfully processed {object_key}"}

    except Exception as e:
        logger.error(f"Error processing event: {e}")
        return {'statusCode': 500, 'body': f"Error processing {object_key}. See logs."}