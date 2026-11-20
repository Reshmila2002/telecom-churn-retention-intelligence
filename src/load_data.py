
import pandas as pd
from pathlib import Path
from sqlalchemy import text, inspect
from database_connection import get_engine

# Identify the project directory
PROJECT_ROOT = Path(__file__).resolve().parent.parent

# Define cleaned dataset location
DATA_PATH = (
    PROJECT_ROOT
    / "data"
    / "processed"
    / "telecom_churn_cleaned.csv"
)


def load_customer_data():

    # Load cleaned CSV
    df = pd.read_csv(DATA_PATH)

    print("Cleaned dataset loaded successfully!")
    print("Total records:", len(df))
    print("Total columns:", df.shape[1])

    # Validate dataset before importing
    assert len(df) == 3150, "Unexpected record count."
    assert df.shape[1] == 16, "Unexpected column count."
    assert df["record_id"].is_unique, "Duplicate record IDs."
    assert not df.isnull().any().any(), "Missing values found."
    assert df["churn"].isin([0, 1]).all(), "Invalid churn values."

    print("Dataset validation passed!")

    # Connect to PostgreSQL
    engine = get_engine()

    try:
        with engine.begin() as connection:

            # Verify the target database
            database = connection.execute(
                text("SELECT current_database()")
            ).scalar()

            if database != "telecom_churn_db":
                raise RuntimeError("Incorrect target database.")

            # Ensure the customer table already exists
            if not inspect(connection).has_table(
                "customers", schema="public"
            ):
                raise RuntimeError("Customer table does not exist.")

            # Check existing records
            existing_count = connection.execute(
                text("SELECT COUNT(*) FROM public.customers")
            ).scalar()

            if existing_count > 0:
                print(
                    "Import skipped. Customer table already "
                    f"contains {existing_count} records."
                )
                return

            # Import data into the existing table
            df.to_sql(
                name="customers",
                con=connection,
                schema="public",
                if_exists="append",
                index=False,
                chunksize=500
            )

            # Verify imported record count
            imported_count = connection.execute(
                text("SELECT COUNT(*) FROM public.customers")
            ).scalar()

            assert imported_count == len(df), (
                "Imported record count does not match CSV."
            )

        print("Customer data imported successfully!")
        print("Total imported records:", imported_count)

    finally:
        engine.dispose()


if __name__ == "__main__":
    load_customer_data()
