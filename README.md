# Music Trend Analytics Pipeline

[1-2 sentence description — see repo description above]

## Disclaimer
Personal project using the public Kaggle "Spotify Tracks Dataset."
Not affiliated with, endorsed by, or connected to Spotify.

## Architecture
[Diagram or short description: CSV → Postgres (raw) → dbt (staging → intermediate → marts)]

## Tech Stack
- Python (pandas, psycopg2/sqlalchemy) — ingestion
- PostgreSQL (Docker) — warehouse
- dbt-core — transformation, testing, docs

## Data Source
[Kaggle dataset name/link, size, what it contains, any known limitations]

## Models
[Short table: staging / intermediate / mart, one line each on purpose]

## Tests & Data Quality
[What's tested and why — not_null, unique, relationships, custom valence/energy bounds test]

## Key Insight
[The genuine finding from genre_trends_by_year — fill in last]

## Running This Project
[docker-compose up, load script, dbt run, dbt test, dbt docs generate]

## Lineage Graph
[Screenshot from dbt docs]
