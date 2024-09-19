import os
import json
from typing import Tuple

def get_credentials(creds_path: str) -> Tuple[str, str]:
    with open(f"{creds_path}/kaggle.json") as f:
        data = json.load(f)
    return data["username"], data["key"]