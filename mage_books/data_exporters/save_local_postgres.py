import os
from os import path
from mage_ai.settings.repo import get_repo_path
from mage_ai.io.config import ConfigFileLoader
from mage_ai.io.postgres import Postgres
from pandas import DataFrame

from mage_books.utils.postgres_utils.db_utils import create_db

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter


@data_exporter
def export_data_to_postgres(data: dict, **kwargs) -> None:
    
    schema_name = os.getenv("POSTGRES_SCHEMA")
    config_path = path.join(get_repo_path(), 'io_config.yaml')
    config_profile = 'default'

    cfg = ConfigFileLoader(config_path, config_profile)

    # Create database if not already existing
    create_db(
        dbname=os.getenv("POSTGRES_DBNAME"), 
        user=os.getenv("POSTGRES_USER"), 
        password=os.getenv("POSTGRES_PASSWORD"), 
        host=os.getenv("POSTGRES_HOST"), 
        port=os.getenv("POSTGRES_PORT")
    )

    with Postgres.with_config(cfg) as loader:
        for table_name, df in data.items():
            print(f"Saving {df.shape[0]} to {schema_name}.{table_name}")
            loader.export(
                df,
                schema_name,
                table_name,
                index=False,  # Specifies whether to include index in exported table
                if_exists='replace',  # Specify resolution policy if table name already exists
            )
