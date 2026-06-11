from fastapi import Depends

def get_db():
    db = {"connection": "fake-db-connection"}
    try:
        yield db
    finally:
        print("Closing DB connection")
