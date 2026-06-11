from fastapi import FastAPI

app = FastAPI(
    title="CloudNative DevOps Portfolio API",
    version="0.1.0",
    description="Learning DevOps stack step by step"
)

@app.get("/")
def root():
    return {"message": "Hello, DevOps World!"}

@app.post("/echo")
def echo_message(data: dict):
    return {"you_sent": data}
