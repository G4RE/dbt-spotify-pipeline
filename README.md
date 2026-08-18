# Music Trend Analytics Pipeline

A dbt analytics project exploring genre and mood trends in music, built on the
public Kaggle Spotify Tracks dataset. Staging → intermediate → mart layers,
with data tests and generated documentation (lineage graph).

## Disclaimer

This is a personal, non-commercial project built to demonstrate data
engineering and analytics engineering skills. It uses the publicly available
Kaggle "Spotify Tracks Dataset" and is **not affiliated with, endorsed by, or
connected to Spotify** in any way.

## Architecture

```
Kaggle CSV (Spotify Tracks Dataset)
        │
        ▼
Python ingestion script (pandas)
        │
        ▼
PostgreSQL (raw schema, via Docker)
        │
        ▼
dbt: staging models  (clean, cast, standardise)
        │
        ▼
dbt: intermediate models  (join tracks + audio features)
        │
        ▼
dbt: mart models  (genre trends, artist popularity, mood clusters)
        │
        ▼
dbt docs (lineage graph) + dbt test (data quality)
```

<!-- TODO once ingestion is finalised: confirm this matches the actual raw
table shape (single flat table vs. split raw tables) and update if needed. -->

## Tech Stack

- **Python** (pandas, psycopg2/SQLAlchemy) — data ingestion
- **PostgreSQL** (Docker) — local data warehouse
- **dbt-core** — transformation, testing, and documentation

## Data Source

<!-- TODO: fill in once ingestion is done —
- Dataset name/link (Kaggle "Spotify Tracks Dataset" by maharshipandya)
- Row count actually loaded
- What it contains: track/artist metadata + precomputed audio features
  (danceability, energy, valence, tempo, etc.)
- Any known limitations (e.g. no listening-history/time-series data,
  audio features are Spotify-computed and not independently verified) -->

## Models

| Layer        | Model                              | Purpose |
|--------------|-------------------------------------|---------|
| Staging      | `stg_tracks`                        | Cleaned track-level metadata |
| Staging      | `stg_artists`                       | Cleaned artist-level metadata |
| Staging      | `stg_audio_features`                | Cleaned audio feature columns |
| Intermediate | `int_tracks_with_audio_features`    | Tracks joined to their audio features |
| Mart         | `genre_trends_by_year`              | Avg. energy/valence/tempo per genre per year |
| Mart         | `artist_popularity_over_time`       | Artist popularity trends |
| Mart         | `mood_clusters`                     | Tracks bucketed into mood categories via valence/energy thresholds |

## Tests & Data Quality

- `not_null` / `unique` tests on key columns in staging models
- A `relationships` test linking tracks to artists
- A custom test asserting `valence` and `energy` fall within their expected
  `0–1` range

<!-- TODO: link to the actual schema.yml test definitions once written -->

## Key Insight

<!-- TODO: fill in last, after querying genre_trends_by_year on real data.
Write an honest, specific finding — e.g. how average tempo or valence for a
particular genre has shifted over time — not a generic statement. -->

## Running This Project

```bash
# 1. Start Postgres
docker-compose up -d

# 2. Load raw data
cd ingestion
pip install -r requirements.txt
python load_raw_data.py

# 3. Run dbt
cd ../dbt_project
dbt deps
dbt run
dbt test
dbt docs generate
dbt docs serve
```

## Lineage Graph

<!-- TODO: add screenshot from `dbt docs serve` once models are built -->
