import os
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text


# ---------------------------------------------------------
# Configuration
# ---------------------------------------------------------

# Project root:
# dbt-spotify-pipeline/
PROJECT_ROOT = Path(__file__).resolve().parent.parent

# CSV location:
# dbt-spotify-pipeline/data/dataset.csv
# Can be overridden with SPOTIFY_CSV_PATH (used by CI to point at the
# small fixture in tests/fixtures/ instead of the full local dataset).
CSV_PATH = Path(
    os.environ.get("SPOTIFY_CSV_PATH", PROJECT_ROOT / "data" / "dataset.csv")
)

# PostgreSQL settings from docker-compose.yml
DB_USER = "spotify"
DB_PASSWORD = "spotify_password"
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "spotify"

# Raw database schema/table
SCHEMA_NAME = "raw"
TABLE_NAME = "spotify_tracks"


# ---------------------------------------------------------
# Database connection
# ---------------------------------------------------------

DATABASE_URL = (
    f"postgresql+psycopg2://"
    f"{DB_USER}:{DB_PASSWORD}"
    f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)


def create_database_engine():
    """Create and return a PostgreSQL SQLAlchemy engine."""
    return create_engine(DATABASE_URL)


# ---------------------------------------------------------
# Load CSV
# ---------------------------------------------------------

def load_csv():
    """Read the Spotify CSV into a pandas DataFrame."""

    if not CSV_PATH.exists():
        raise FileNotFoundError(
            f"Could not find dataset at:\n{CSV_PATH}\n\n"
            "Make sure dataset.csv is located in data/dataset.csv, or set "
            "SPOTIFY_CSV_PATH to point at a different file."
        )

    print(f"Reading dataset from: {CSV_PATH}")

    df = pd.read_csv(CSV_PATH)

    print(f"Loaded {len(df):,} rows and {len(df.columns)} columns.")

    return df


# ---------------------------------------------------------
# Create raw schema
# ---------------------------------------------------------

def create_raw_schema(engine):
    """Create the raw schema if it doesn't already exist."""

    with engine.begin() as connection:
        connection.execute(
            text(f"CREATE SCHEMA IF NOT EXISTS {SCHEMA_NAME}")
        )

    print(f"Schema '{SCHEMA_NAME}' is ready.")


# ---------------------------------------------------------
# Load DataFrame into PostgreSQL
# ---------------------------------------------------------

def load_to_postgres(df, engine):
    """Load the DataFrame into the raw PostgreSQL table."""

    print(
        f"Loading data into "
        f"{SCHEMA_NAME}.{TABLE_NAME}..."
    )

    df.to_sql(
        name=TABLE_NAME,
        con=engine,
        schema=SCHEMA_NAME,
        if_exists="replace",
        index=False,
        method="multi",
        chunksize=5000,
    )

    print(
        f"Successfully loaded {len(df):,} rows into "
        f"{SCHEMA_NAME}.{TABLE_NAME}."
    )


# ---------------------------------------------------------
# Verify load
# ---------------------------------------------------------

def verify_load(engine):
    """Check how many rows were loaded into PostgreSQL."""

    query = text(
        f"SELECT COUNT(*) FROM {SCHEMA_NAME}.{TABLE_NAME}"
    )

    with engine.connect() as connection:
        row_count = connection.execute(query).scalar()

    print(
        f"PostgreSQL contains {row_count:,} rows "
        f"in {SCHEMA_NAME}.{TABLE_NAME}."
    )

    return row_count


# ---------------------------------------------------------
# Main
# ---------------------------------------------------------

def main():
    print("=" * 60)
    print("Spotify Data Pipeline - Raw Data Ingestion")
    print("=" * 60)

    print("\n1. Creating PostgreSQL connection...")
    engine = create_database_engine()

    try:
        # Test the connection
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))

        print("PostgreSQL connection successful.")

        print("\n2. Reading CSV...")
        df = load_csv()

        print("\n3. Creating raw schema...")
        create_raw_schema(engine)

        print("\n4. Loading data into PostgreSQL...")
        load_to_postgres(df, engine)

        print("\n5. Verifying load...")
        verify_load(engine)

        print("\n" + "=" * 60)
        print("INGESTION COMPLETE")
        print("=" * 60)

    except Exception as error:
        print("\n" + "=" * 60)
        print("INGESTION FAILED")
        print("=" * 60)
        print(f"\nError: {error}")
        raise

    finally:
        engine.dispose()


if __name__ == "__main__":
    main()
