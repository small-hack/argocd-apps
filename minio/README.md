# MinIO Operator (and optional Tenant) Argo CD Applications

We default deploy the operator (admin) console and (optionally, if you use directory recursion) a tenant console/api 

Operator helm chart: https://github.com/minio/operator/tree/master/helm/operator

Optional Tenant helm chart: https://github.com/minio/operator/tree/master/helm/tenant

## Remaining Tasks

- figure out encryption

## Notes

### tenant API is not accessible
The easiest way to remedy this is to try accessing the user console with a letsencrypt-prod cert. The staging cert will always fail with x509 signed by unknown authority errors.

### creating a simple streamlined python client

After you've installed the minio python sdk:

```bash
pip install minio
```

And you have the following in your `~/.mc/config.json` (replacing the url, accessKey, and secretKey with your own tenant root credentials):

```json
{
  "version": "10",
  "aliases": {
    "minio-root": {
      "url": "https://minio-api.example.com",
      "accessKey": "minioadmin",
      "secretKey": "minio123",
      "api": "S3v4",
      "path": "auto"
    }
  }
}
```

You can use this free code to get started:

```python
from json import dump
import logging as log
from os.path import exists
from os import makedirs

# pip install minio
from minio import Minio, MinioAdmin


class BetterMinio:
    """ 
    a wrapper around the two seperate Minio and MinioAdmin clients to create
    users and buckets with basic policies
    """

    def __init__(self,
                 minio_alias: str,
                 api_hostname: str,
                 access_key: str,
                 secret_key: str) -> None:
        self.root_user = access_key
        self.root_password = secret_key
        self.admin_client = MinioAdmin(minio_alias)
        self.client = Minio(api_hostname, access_key, secret_key)

    def create_access_credentials(self, access_key: str) -> str:
        """
        given an access key name, we create minio access credentials
        using the mc admin client

        return secret_key
        """
        # Create a client with the MinIO hostname, its access key and secret key.
        log.info(f"About to create the minio credentials for user {access_key}")

        # similar to mc admin user add
        secret_key = create_password()
        self.admin_client.user_add(access_key, secret_key)

        log.info(f"Creation of minio credentials for user {access_key} completed.")
        return secret_key

    def create_bucket(self, bucket_name: str, access_key: str) -> None:
        """
        Takes bucket_name and access_key of user to assign bucket policy to
        creates a bucket via the minio sdk
        """
        # Make bucket if it does not exist already
        log.info(f'Check for bucket "{bucket_name}"...')
        found = self.client.bucket_exists(bucket_name)

        if not found:
            log.info(f'Creating bucket "{bucket_name}"...')
            self.client.make_bucket(bucket_name)

            # policy for bucket
            log.info(f"Adding a readwrite policy for bucket, {bucket_name}")
            policy_name = self.create_bucket_policy(bucket_name)
            self.admin_client.policy_set(policy_name, access_key)
        else:
            log.info(f'Bucket "{bucket_name}" already exists')

    def create_bucket_policy(self, bucket: str) -> str:
        """
        creates a readwrite policy for a given bucket and returns the policy name
        """
        policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "s3:GetBucketLocation",
                        "s3:GetObject",
                        "s3:ListBucket"
                    ],
                    "Resource": [
                        f"arn:aws:s3:::{bucket}",
                        f"arn:aws:s3:::{bucket}/*"
                    ]
                }
            ]
        }

        # we write out the policy, because minio admin client requires it
        policy_file_name =  f'/tmp/minio_{bucket}_policy.json'
        with open(policy_file_name, 'w') as policy_file:
            dump(policy, policy_file)

        # actually create the policy
        policy_name = f'{bucket}BucketReadWrite'
        self.admin_client.policy_add(policy_name, policy_file_name)

        return policy_name

# this should be your tenant root credentials
access_key = "minioadmin"
secret_key = "minio123"
minio_api_hostname = "https://minio-api.example.com"

# example usage
client = BetterMinio('minio-root', minio_api_hostname, access_key, secret_key)

# this creates a bucket and accompanying policy for a given user
client.create_bucket('my-new-bucket', 'my-cool-user')
```
