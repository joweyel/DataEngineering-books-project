from mage_ai.io.file import FileIO
from pandas import DataFrame
from typing import Dict
import pandas as pd

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter


@data_exporter
def export_data_to_file(
    data, **kwargs
) -> None:
    for key in data.keys():
        df = data[key]
        df = df.astype({col: pd.Int32Dtype() for col in df.select_dtypes(include='Int64').columns})  # Ensure In32
        filepath = f"/home/src/data/{key}.parquet"
        print(f"Saving {filepath}")
        FileIO().export(df, filepath)
