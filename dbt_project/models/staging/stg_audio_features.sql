-- One row per unique track_id's precomputed Spotify audio features.
-- Same dedup logic as stg_tracks — features are identical across a track's
-- genre repeats in the raw data.

with base as (

    select * from {{ ref('stg_spotify_tracks') }}

),

deduped as (

    select
        track_id,
        danceability,
        energy,
        key,
        loudness,
        mode,
        mode_name,
        speechiness,
        acousticness,
        instrumentalness,
        liveness,
        valence,
        tempo,
        time_signature,
        row_number() over (
            partition by track_id
            order by source_row_id
        ) as rn

    from base

)

select
    track_id,
    danceability,
    energy,
    key,
    loudness,
    mode,
    mode_name,
    speechiness,
    acousticness,
    instrumentalness,
    liveness,
    valence,
    tempo,
    time_signature
from deduped
where rn = 1
