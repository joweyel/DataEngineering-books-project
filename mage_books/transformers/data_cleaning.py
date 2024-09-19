from typing import Tuple
import pandas as pd

if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
# def transform(data, **kwargs):
def transform(
    dfs: Tuple[
        pd.DataFrame, 
        pd.DataFrame,
        pd.DataFrame
    ], 
    **kwargs
):

    df_books = dfs[0]
    df_users = dfs[1]
    df_ratings = dfs[2]

    # df_books = data["books"].copy()
    df_books.drop_duplicates(keep="first", inplace=True)
    df_books.reset_index(inplace=True, drop=True)

    ##########################
    ## Processing books-data
    ##########################
    df_books.columns = df_books.columns.str.lower().str.replace("-", "_")
    books_mapping = {
        "book_title": "title",
        "book_author": "author",
        "year_of_publication": "year"
    }
    books_drop = ["image_url_s", "image_url_m", "image_url_l"]
    df_books.rename(columns=books_mapping, inplace=True)

    ## Cleaning up isbn
    isbn_len = df_books["isbn"].str.len()
    # Cleaning isbn with length 14 (removing '\' and '"')
    df_books.loc[isbn_len == 14, "isbn"] = df_books["isbn"].str.replace(r'[\\"]', '', regex=True)
    # Cleaning isbn with length 13 (removeing '.')
    df_books.loc[isbn_len == 13, 'isbn'] = df_books['isbn'].str.replace(".", "", regex=False)
    df_books["isbn"] = df_books["isbn"].str.strip()

    df_books["year"] = pd.to_numeric(df_books["year"], errors="coerce")
    df_books.drop(columns=books_drop, inplace=True)
    df_books.dropna(subset=["year"], inplace=True)
    book_dtypes = {
        "isbn": pd.StringDtype(),
        "title": pd.StringDtype(),
        "author": pd.StringDtype(),
        "year": pd.Int32Dtype(),
        "publisher": pd.StringDtype()
    }
    df_books_out = df_books.astype(book_dtypes)
    print("books-data processed")

    ##########################
    ## Processing user-data ##
    ##########################
    # df_users = data["users"].copy()
    df_users.drop_duplicates(keep="first", inplace=True)
    df_users.reset_index(inplace=True, drop=True)

    df_users.columns = df_users.columns.str.lower().str.replace("-", "_")
    df_users["location_list"] = df_users["location"].apply(lambda loc: [
        x.strip() for x in loc.split(",")
    ])
    df_users['location_list'] = df_users['location_list'].apply(lambda locations: [
        loc for loc in locations[::-1] if loc is not None][:3][::-1]
    )
    df_users[["city", "state", "country"]] = pd.DataFrame(df_users["location_list"].tolist())
    df_users.drop(columns=["location", "location_list"], inplace=True)
    check = df_users["country"].str.contains('"') == True
    df_users.loc[check, "country"] = df_users.loc[check, "country"].str.replace('"', '')

    df_users["age"] = df_users["age"].fillna(0)

    users_dtypes = {
        "user_id": pd.Int32Dtype(),
        "age": pd.Int32Dtype(),
        "city": pd.StringDtype(),
        "state": pd.StringDtype(),
        "country": pd.StringDtype(),
    }
    df_users_out = df_users.astype(users_dtypes)
    print("users-data processed")


    ##########################
    ## Processing ratings-data
    ##########################
    # df_ratings = data["ratings"].copy()
    df_ratings.drop_duplicates(keep="first", inplace=True)
    df_ratings.reset_index(inplace=True, drop=True)

    df_ratings.columns = df_ratings.columns.str.lower().str.replace("-", "_")
    df_ratings.rename(columns={"book_rating": "rating"}, inplace=True)

    ## Cleaning up isbn
    isbn_len = df_ratings["isbn"].str.len()
    # Cleaning isbn with length 14 (removing '\' and '"')
    df_ratings.loc[isbn_len == 14, "isbn"] = df_ratings["isbn"].str.replace(r'[\\"]', '', regex=True)
    # Cleaning isbn with length 13 (removeing '.')
    df_ratings.loc[isbn_len == 13, 'isbn'] = df_ratings['isbn'].str.replace(".", "", regex=False)
    df_ratings["isbn"] = df_ratings["isbn"].str.strip()


    ratings_dtypes = {
        "user_id": pd.Int32Dtype(),
        "isbn": pd.StringDtype(),
        "rating": pd.Int32Dtype(),
    }
    df_ratings_out = df_ratings.astype(ratings_dtypes)
    print("ratings-data processed")


    data_transformed = {
        "books": df_books_out,
        "users": df_users_out,
        "ratings": df_ratings_out
    }
    # print("books", data_transformed["books"].dtypes)
    # print("users", data_transformed["users"].dtypes)
    # print("ratings", data_transformed["ratings"].dtypes)

    return data_transformed
    # return data_transformed["books"], data_transformed["users"], data_transformed["ratings"]


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'