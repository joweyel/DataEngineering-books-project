import os
import io
import json
import requests
import pandas as pd
from typing import Tuple

# Kaggle imports 
os.environ["KAGGLE_USERNAME"] = os.getenv("KAGGLE_USERNAME")
os.environ["KAGGLE_KEY"] = os.getenv("KAGGLE_KEY")
from kaggle.api.kaggle_api_extended import KaggleApi

if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@data_loader
def load_data(*args, **kwargs) -> Tuple[
    pd.DataFrame,
    pd.DataFrame,
    pd.DataFrame
]:
    os.makedirs("data/", exist_ok=True)
    ds_name = "arashnic/book-recommendation-dataset"
    data_names = ["Books.csv", "Users.csv", "Ratings.csv"]
    save_path = "/home/src/data"

    print("Load data from Kaggle")
    api = KaggleApi()
    api.authenticate()
    api.datasets_list()
    api.dataset_download_files(dataset=ds_name, path=save_path, force=False, unzip=True)


    data = {
        "books": pd.read_csv(f"{save_path}/Books.csv"),
        "users": pd.read_csv(f"{save_path}/Users.csv"),
        "ratings": pd.read_csv(f"{save_path}/Ratings.csv"),
    }

    # return data
    return data["books"], data["users"], data["ratings"]
