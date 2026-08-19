-- Tracks joined to their audio features and exploded across genres.
-- Grain: one row per (track_id, track_genre) — same grain as the raw data,
-- but now with clean, deduplicated metadata and features joined in.

with tracks as (

    select * from {{ ref('stg_tracks') }}

),

audio_features as (

    select * from {{ ref('stg_audio_features') }}

),

genres as (

    select * from {{ ref('stg_track_genres') }}

)

select
    t.track_id,
    t.track_name,
    t.artists,
    t.album_name,
    t.popularity,
    t.duration_ms,
    t.duration_minutes,
    t.is_explicit,
    g.track_genre,
    af.danceability,
    af.energy,
    af.key,
    af.loudness,
    af.mode,
    af.mode_name,
    af.speechiness,
    af.acousticness,
    af.instrumentalness,
    af.liveness,
    af.valence,
    af.tempo,
    af.time_signature
from tracks t
inner join audio_features af on t.track_id = af.track_id
inner join genres g on t.track_id = g.track_id
