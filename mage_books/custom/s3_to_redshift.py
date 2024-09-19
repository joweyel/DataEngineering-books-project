from mage_ai.settings.repo import get_repo_path
from mage_ai.io.config import ConfigFileLoader
from mage_ai.io.s3 import S3
from mage_ai.io.redshift import Redshift
from mage_books.utils.redshift.redshift_sql import (
    create_table_query,
    create_schema_query,
    execute_sql,
    get_query_results,
    check_data_exists,
    copy_data_to_redshift
)
import boto3
import pandas as pd
from os import path
from functools import partial



if 'custom' not in globals():
    from mage_ai.data_preparation.decorators import custom
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@custom
def transform_custom(*args, **kwargs):
    """
    args: The output from any upstream parent blocks (if applicable)

    Returns:
        Anything (e.g. data frame, dictionary, array, int, str, etc.)
    """

    # Function to execute queries with error handling
    def execute_with_error_handling(sql):
        try:
            response = send_query(Sql=sql)
            print(f"Query executed successfully: {sql}")
            print("Response:", response)
        except Exception as e:
            print(f"Error executing query: {sql}")
            print("Exception:", str(e))


    # Set up config
    config_path = path.join(get_repo_path(), 'io_config.yaml')
    config_profile = 'default'
    cfg = ConfigFileLoader(config_path, config_profile)


    ## Redshift
    region = cfg.get("AWS_REGION")
    table_name_template = "{obj_name}"
    schema_name = cfg.get("REDSHIFT_SCHEMA")
    database_name = cfg.get("REDSHIFT_DBNAME")
    workgroup_name = cfg.get("REDSHIFT_WGNAME")
    iam_role_arn = cfg.get("REDSHIFT_IAM_PROFILE")

    client_redshift = boto3.client("redshift-data", region_name=region)
    
    send_query = partial(
        client_redshift.execute_statement, 
        Database=database_name,
        WorkgroupName=workgroup_name
    )

    # Create schema if not exists
    send_query(Sql=f"CREATE SCHEMA IF NOT EXISTS {schema_name};")

    # S3 parameter
    data_path = kwargs.get("data_path", "data")
    object_names = ["books", "users", "ratings"]
    bucket_name = "book-recommendation-data"
    replace_table = kwargs.get("replace", False)  # Get replace argument from kwargs

    for obj_name in object_names:

        # Get data from S3 bucket
        object_key = f"{data_path}/{obj_name}.parquet"

        # Create tables in redshift
        table_name = table_name_template.format(obj_name=obj_name)
        create_table_sql = create_table_query(table_name, schema_name, replace=replace_table)
        send_query(Sql=create_table_sql)

        truncate_sql = f"TRUNCATE TABLE {schema_name}.{table_name};"
        print(f"Running:\n{truncate_sql}")
        send_query(Sql=truncate_sql)

        # Put data from s3 to redshift
        copy_sql = f"""
        COPY {schema_name}.{table_name}
        FROM 's3://{bucket_name}/{object_key}' IAM_ROLE '{iam_role_arn}'
        FORMAT AS PARQUET;
        """
        print(f"Running:\n{copy_sql}")
        send_query(Sql=copy_sql)
