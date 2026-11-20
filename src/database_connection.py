
import os
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine, URL, text

# Identify project root
PROJECT_ROOT = Path(__file__).resolve().parent.parent

# Load private database configuration
load_dotenv(PROJECT_ROOT / ".env", override=True)


def get_engine():

    # Check database password
    password = os.getenv("DB_PASSWORD")

    if not password:
        raise ValueError("Database password is missing.")

    # Create PostgreSQL connection URL
    database_url = URL.create(
        drivername="postgresql+psycopg2",
        username=os.getenv("DB_USER", "postgres"),
        password=password,
        host=os.getenv("DB_HOST", "localhost"),
        port=int(os.getenv("DB_PORT", "5432")),
        database=os.getenv("DB_NAME", "telecom_churn_db")
    )

    # Create database engine
    engine = create_engine(database_url)

    return engine


# Test database connection
if __name__ == "__main__":

    engine = get_engine()

    try:
        with engine.connect() as connection:

            result = connection.execute(
                text("SELECT current_database();")
            ).scalar()

            print("Database connection successful!")
            print("Connected database:", result)

    finally:
        engine.dispose()
