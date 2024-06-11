from dotenv import load_dotenv
import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

load_dotenv()

SQLALCHEMY_DATABASE_URL = "sqlite:///./sql_app.db"
if os.environ.get("DB_CONNECTION_STRING"):
    SQLALCHEMY_DATABASE_URL = os.environ["DB_CONNECTION_STRING"]
else:
    print("DB_CONNECTION_STRING not set. Using default sqlite database.")

connect_args = {}
if SQLALCHEMY_DATABASE_URL.startswith("sqlite"):
    connect_args["check_same_thread"] = False

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args=connect_args,
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()
