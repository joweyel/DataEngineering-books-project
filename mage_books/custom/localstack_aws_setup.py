import os
import subprocess

if 'custom' not in globals():
    from mage_ai.data_preparation.decorators import custom
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@custom
def create_locslstack_resources(*args, **kwargs):

    # Debug prints for Redshift environment variables
    print('AWS_ENDPOINT_URL:', os.getenv('AWS_ENDPOINT_URL'))
    print('REDSHIFT_CLUSTER_ID:', os.getenv('REDSHIFT_CLUSTER_ID'))
    print('REDSHIFT_USER:', os.getenv('REDSHIFT_USER'))
    print('REDSHIFT_PASSWORD:', os.getenv('REDSHIFT_PASSWORD'))
    print('REDSHIFT_DBNAME:', os.getenv('REDSHIFT_DBNAME'))

    # Run awslocal to create an S3 bucket
    try:
        result = subprocess.run(
            ['awslocal', 's3', 'mb', 's3://book-recommendation-data'], 
            check=True, 
            capture_output=True, 
            text=True
        )
        print('Bucket created successfully:', result.stdout)
    except subprocess.CalledProcessError as e:
        print(f'Error creating bucket: {e.stderr}')

    # Run awslocal to create an Redshift Cluster
    try:
        result = subprocess.run(
            [
                'awslocal', 'redshift', 'create-cluster',
                '--cluster-id', os.getenv('REDSHIFT_CLUSTER_ID'),
                '--node-type', 'dc2.large',  # Example node type
                '--master-username', os.getenv('REDSHIFT_USER'),
                '--master-user-password', os.getenv('REDSHIFT_PASSWORD'),
                '--cluster-type', 'single-node',
                '--db-name', os.getenv('REDSHIFT_DBNAME'),
                '--port', '5439',
                '--endpoint-url', os.getenv('AWS_ENDPOINT_URL')  # Ensure this is correct for your setup
            ],
            check=True,
            capture_output=True,
            text=True
        )
    except subprocess.CalledProcessError as e:
        print(f'Error creating resources: {e.stderr}')    


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
