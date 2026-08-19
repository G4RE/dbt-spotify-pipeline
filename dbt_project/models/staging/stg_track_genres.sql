-- Bridge table: track_id -> track_genre, many rows per track_id.
-- This replaces the originally-planned stg_artists model. The dataset has
-- no separate artist entity — `artists` is a single free-text field on each
-- track (sometimes semicolon-separated for collaborations) — but it does
-- have a genuine many-to-many relationship between tracks and genres, which
-- this bridge captures.

select distinct
    track_id,
    track_genre
from {{ ref('stg_spotify_tracks') }}
where track_genre is not null
