import boto3
import logging


def check():
    must_upload = False

    try:
        s3.get_object(
            Bucket=bucket,
            Key=key,
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchKey':
            must_upload = True
        else:
            raise e
    else:
        must_upload = compare(
            local='',
            remote=body,
        )

    return must_upload


def upload():
    new_version = ''

    s3.put_object(
    )

    return new_version


def save_version():
    return


def main():
    if check():
        new_version = upload()
        save_version(new_version)
