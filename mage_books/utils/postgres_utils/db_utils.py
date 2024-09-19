import psycopg2
from psycopg2 import sql


def create_db(dbname, user, password, host, port):
    try:
        # Connect to the default 'postgres' database
        conn = psycopg2.connect(
            dbname='postgres', 
            user=user, 
            password=password, 
            host=host, 
            port=port
        )
        conn.autocommit = True  # Needed to create databases
        cursor = conn.cursor()

        # Check if the database exists
        cursor.execute(sql.SQL("SELECT 1 FROM pg_database WHERE datname = %s"), [dbname])
        exists = cursor.fetchone()

        if not exists:
            # Create the database
            cursor.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier(dbname)))
            print(f"Database '{dbname}' created successfully.")
        else:
            print(f"Database '{dbname}' already exists.")
        
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        if conn:
            cursor.close()
            conn.close()