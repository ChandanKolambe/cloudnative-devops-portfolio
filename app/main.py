from fastapi import FastAPI, Depends, BackgroundTasks
from app.core.dependencies import get_db

app = FastAPI(title="CloudNative DevOps Portfolio API", version="0.2.0")

@app.get("/")
def root():
    return {"message": "Hello, DevOps World!"}

@app.get("/items/")
def read_items(db=Depends(get_db)):
    return {"db_connection": db["connection"], "items": ["item1", "item2"]}

@app.post("/process/")
def process_data(data: dict, background_tasks: BackgroundTasks):
    background_tasks.add_task(log_data, data)
    return {"status": "processing started"}

def log_data(data: dict):
    print(f"Background task logging data: {data}")
