from mage_ai.settings.repo import get_repo_path
from mage_ai.io.config import ConfigFileLoader
from mage_ai.io.s3 import S3
from pandas import DataFrame
import pandas as pd
from os import path
import os
from typing import Dict

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter


@data_exporter
def export_data_to_s3(data, **kwargs) -> None:
    
    # Update the configuration to use LocalStack or real AWS
    config_path = path.join(get_repo_path(), 'io_config.yaml')
    config_profile = 'default'

    for key in data.keys():
        df = data[key]
        df = df.astype({col: pd.Int32Dtype() for col in df.select_dtypes(include='Int64').columns})

        filename = f"{key}.parquet"

        bucket_name = os.getenv('S3_BUCKET_NAME')
        object_key = f"data/{filename}"
        print(f"loading data: {object_key}")

        # Ensure S3 configuration is updated
        S3.with_config(ConfigFileLoader(config_path, config_profile)).export(
            df,
            bucket_name,
            object_key,
        )
