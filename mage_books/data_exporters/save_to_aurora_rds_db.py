from mage_ai.settings.repo import get_repo_path
from mage_ai.io.config import ConfigFileLoader
from mage_ai.io.postgres import Postgres
from pandas import DataFrame
from os import path
from mage_ai.data_preparation.shared.secrets import get_secret_value

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter


@data_exporter
def export_data_to_postgres(data: dict, **kwargs) -> None:
    """
    Template for exporting data to a PostgreSQL database.
    Specify your configuration settings in 'io_config.yaml'.

    Docs: https://docs.mage.ai/design/data-loading#postgresql
    """
    config_path = path.join(get_repo_path(), 'io_config.yaml')
    config_profile = 'default'

    os.environ["AWS_ACCESS_KEY_ID"] = get_secret_value("AWS_ACCESS_KEY_ID")
    os.environ["AWS_SECRET_ACCESS_KEY"] = get_secret_value("AWS_SECRET_ACCESS_KEY")

    ## Books
    table_types = {
        "books": {
            "isbn": "VARCHAR(20)",
            "title": "VARCHAR(512)",
            "author": "VARCHAR(255)",
            "year": "INTEGER",
            "publisher": "VARCHAR(255)"
        },
        "users": {
            "user_id": "BIGINT",
            "age": "INTEGER",
            "city": "VARCHAR(255)",
            "state": "VARCHAR(255)",
            "country": "VARCHAR(255)"
        },
        "ratings": {
            "user_id": "BIGINT",
            "isbn": "VARCHAR(20)",
            "rating": "INTEGER"
        }
    }
    schema_name = os.getenv("POSTGRES_SCHEMA")


    with Postgres.with_config(ConfigFileLoader(config_path, config_profile)) as loader:
        for table_name, df in data.items():

            loader.export(
                df,
                schema_name,
                table_name,
                index=False,
                if_exists='replace',
                overwrite_types=table_types[table_name]
            )
