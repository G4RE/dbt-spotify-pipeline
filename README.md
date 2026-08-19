# Music Trend Analytics Pipeline

![dbt CI](https://github.com/G4RE/dbt-spotify-pipeline/actions/workflows/dbt_ci.yml/badge.svg)

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
dbt: staging models  (clean, cast, standardise, dedupe)
        │
        ▼
dbt: intermediate models  (join tracks + audio features + genres)
        │
        ▼
dbt: mart models  (genre trends, artist popularity, mood clusters)
        │
        ▼
dbt docs (lineage graph) + dbt test (data quality)
```

## Tech Stack

- **Python** (pandas, psycopg2/SQLAlchemy) — data ingestion
- **PostgreSQL** (Docker) — local data warehouse
- **dbt-core** + **dbt_utils** — transformation, testing, and documentation
- **GitHub Actions** — CI, runs `dbt build` on every push/PR

## Data Source

- Dataset: Kaggle "Spotify Tracks Dataset" by maharshipandya
- 114,000 rows loaded, 21 columns
- Contains track/artist metadata + precomputed Spotify audio features
  (danceability, energy, valence, tempo, etc.)
- **Known limitations:** no listening-history/time-series data (it's a
  point-in-time snapshot, so no year-over-year trends are possible), no
  separate artist entity (artists are a free-text field, sometimes
  semicolon-separated for collaborations), audio features are
  Spotify-computed and not independently verified. 450 rows in the raw CSV
  are exact duplicates (same track_id + same genre repeated) — caught by
  the `dbt_utils.unique_combination_of_columns` test and deduplicated in
  `stg_track_genres`.

## Models

| Layer        | Model                              | Purpose |
|--------------|-------------------------------------|---------|
| Staging      | `stg_spotify_tracks`                | Cleaned, cast version of the raw source |
| Staging      | `stg_tracks`                        | One row per unique track (metadata) |
| Staging      | `stg_audio_features`                | One row per unique track (audio features) |
| Staging      | `stg_track_genres`                  | Bridge table: track_id ↔ track_genre (many-to-many) |
| Intermediate | `int_tracks_with_audio_features`    | Tracks joined to features and genres |
| Mart         | `genre_trends`                      | Avg. popularity/energy/valence/tempo per genre |
| Mart         | `artist_popularity`                 | Popularity summary per artist credit |
| Mart         | `mood_clusters`                     | Tracks bucketed into mood quadrants via valence/energy |

## Tests & Data Quality

- `not_null` / `unique` tests on key columns across staging and mart models
- A `relationships` test linking `stg_track_genres` to `stg_tracks`
- A `dbt_utils.unique_combination_of_columns` test on `stg_track_genres`
  (track_id, track_genre)
- A custom singular test (`tests/assert_audio_features_in_unit_range.sql`)
  asserting `valence` and `energy` fall within their expected `0–1` range
- 22 tests total, all passing — see `dbt build` output in CI

## Key Insight

Across 114,000 tracks, **pop-film** and **k-pop** lead in average popularity
(59.3 and 56.9 respectively), while genres like **grunge** and **sad** skew
lower (49.6 and 52.4) despite comparable track counts (~1,000 tracks each).
Mood-wise, tracks skew energetic overall: **happy_energetic** (33,221
tracks) and **angry_tense** (30,211) together account for ~70% of all
tracks, while **calm_positive** is the rarest mood at just 7,279 tracks —
suggesting the dataset (and perhaps popular music generally, within its
limitations) leans toward higher-energy material regardless of valence.

## Design Decisions

A few choices in this pipeline were driven by what the actual data looked
like, not the original plan:

**Grain of the raw data.** The source CSV has one row per (track, genre)
pairing, not one row per track — a track tagged under 3 genres appears 3
times with identical metadata and audio features, differing only in
`track_genre`. `stg_tracks` and `stg_audio_features` dedupe down to track
grain (89,741 unique tracks); `stg_track_genres` keeps the raw many-to-many
grain as a bridge table.

**No separate artist entity.** `artists` is a free-text field (sometimes
semicolon-separated for collaborations), not a normalized relationship in
the source data. That layer was replaced with `stg_track_genres`, which
*is* a genuine many-to-many relationship in this dataset.

**No time-series marts.** The dataset is a point-in-time snapshot with no
release date or listening-history timestamp, so `genre_trends` and
`artist_popularity` report aggregate/summary stats rather than trends over
time.

## CI

`.github/workflows/dbt_ci.yml` runs `dbt build` (models + tests together)
against a throwaway Postgres service on every push and PR, using a small
570-row stratified sample (`tests/fixtures/ci_sample_dataset.csv`, 5 rows
per genre) instead of the full dataset — keeps CI fast and independent of
the local `data/dataset.csv`, which isn't committed.

## Analyses

`analyses/top_genres_by_mood.sql` is an example ad hoc query (not a
materialized model) joining `mood_clusters` and `stg_track_genres` to
answer a specific question: which genres skew toward which mood.

## Running This Project

```bash
# 1. Get the dataset (not committed — see Data Source above)
#    Download the Kaggle "Spotify Tracks Dataset" and place it at:
#    data/dataset.csv

# 2. Start Postgres
docker-compose up -d

# 3. Load raw data
cd ingestion
pip install -r requirements.txt
python load_raw_data.py

# 4. Set up dbt
cd ../dbt_project
cp profiles.yml.example profiles.yml   # or copy to ~/.dbt/profiles.yml
pip install dbt-core dbt-postgres
dbt deps

# 5. Run dbt
dbt build          # runs all models + all tests
dbt docs generate
dbt docs serve
```

## Lineage Graph

Run `dbt docs serve` after `dbt build` to view the interactive lineage
graph in your browser: raw source → 4 staging models → 1 intermediate
model → 3 marts.
