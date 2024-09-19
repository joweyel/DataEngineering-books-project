import time


def create_schema_query(schema_name: str) -> str:
    query = f"CREATE SCHEMA IF NOT EXISTS {schema_name};"
    return query

def create_table_query(
    table_name: str,
    schema_name: str,
    replace: bool = False
    ) -> str:

    if table_name == "books":
        ## Books-data
        query = f"""
            CREATE TABLE IF NOT EXISTS {schema_name}.books (
            isbn VARCHAR(20),
            title VARCHAR(512),
            author VARCHAR(255),
            year INTEGER,
            publisher VARCHAR(255)
        );
        """
    elif table_name == "users":
        ## Users-data
        query = f"""
        CREATE TABLE IF NOT EXISTS {schema_name}.users (
            user_id BIGINT,
            age INTEGER,
            city VARCHAR(255),
            state VARCHAR(255),
            country VARCHAR(255)
        );
        """
    elif table_name == "ratings":
        query = f"""
        CREATE TABLE IF NOT EXISTS {schema_name}.ratings (
            user_id BIGINT,
            isbn VARCHAR(20),
            rating INTEGER
        );
        """
    else:
        raise ValueError(f"Invalid table {table_name} specified")

    return query


def execute_sql(client, db_name, sql, workgroup_name):
    client.execute_statement(
        Database=db_name,
        Sql=sql,
        WorkgroupName=workgroup_name
    )

def get_query_results(client, query_id):
    # Polling until the query is completed
    while True:
        response = client.get_statement_result(Id=query_id)
        status = response.get('Status')
        if status == 'FINISHED':
            return response
        elif status == 'FAILED' or status == 'ABORTED':
            raise Exception(f"Query failed or was aborted: {response}")
        time.sleep(5)  # Wait before polling again


def check_data_exists(send_query, client, schema, table):
    check_table_sql = f"""
    SELECT COUNT(*)
    FROM information_schema.tables
    WHERE table_schema = '{schema}' AND table_name = '{table}';
    """
    # Execute the query and get the response
    response = send_query(Sql=check_table_sql)
    
    query_id = response['Id']
    
    n_iter = 1
    # Poll the query status until it's done
    while True:
        print(f"Data-check iteration: {n_iter}")
        status_response = client.describe_statement(Id=query_id)
        status = status_response['Status']
        
        if status == 'FINISHED':
            # Fetch the result after query completion
            result = client.get_statement_result(Id=query_id)
            count = int(result['Records'][0][0]['longValue'])
            return count > 0
        elif status in ['FAILED', 'ABORTED']:
            raise Exception(f"Query failed or was aborted: {status_response}")
        
        # Sleep for a second before checking again
        time.sleep(5)
        n_iter += 1

def check_table_exists(send_query, client, schema, table):
    """
    Function to check if a table exists in the given schema.
    
    Args:
    - send_query: A partial function to execute a query in Redshift.
    - client: The boto3 Redshift data client.
    - schema: The schema where the table is expected to exist.
    - table: The table name to check for existence.

    Returns:
    - True if the table exists, False otherwise.
    """
    # SQL query to check if the table exists in the given schema
    check_table_sql = f"""
    SELECT COUNT(*)
    FROM information_schema.tables
    WHERE table_schema = '{schema}' AND table_name = '{table}';
    """
    
    # Execute the query
    response = send_query(Sql=check_table_sql)
    
    query_id = response['Id']
    
    n_iter = 1

    # Poll the query status until it's done
    while True:

        status_response = client.describe_statement(Id=query_id)
        status = status_response['Status']
        
        if status == 'FINISHED':
            # Fetch the result after query completion
            result = client.get_statement_result(Id=query_id)
            count = int(result['Records'][0][0]['longValue'])
            return count > 0  # Return True if count > 0, meaning the table exists
        elif status in ['FAILED', 'ABORTED']:
            raise Exception(f"Query failed or was aborted: {status_response}")
        
        # Wait for a second before polling again
        time.sleep(5)
        n_iter = 1


def copy_data_to_redshift(send_query, client, schema, table, s3_bucket, s3_key, iam_role):
    copy_query = f"""
    COPY {schema}.{table}
    FROM 's3://{s3_bucket}/{s3_key}'
    IAM_ROLE '{iam_role}'
    FORMAT AS PARQUET;
    """
    send_query(Sql=copy_query)