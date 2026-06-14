import os

def pytest_configure(config):
    os.environ["APP_ENV"] = "test"
