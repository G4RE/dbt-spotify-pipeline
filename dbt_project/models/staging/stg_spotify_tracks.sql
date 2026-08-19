-- Cleaned, cast version of the raw source.
-- Grain matches the raw data: one row per (track_id, track_genre) pairing.
-- This model exists purely as a casting/renaming layer; downstream staging
-- models split it into track-grain, audio-feature-grain, and genre-bridge
-- shapes.

with source as (

    select * from {{ source('raw', 'spotify_tracks') }}

),

cleaned as (

    select
        "Unnamed: 0"::int                as source_row_id,
        track_id::varchar                as track_id,
        nullif(trim(artists), '')        as artists,
        nullif(trim(album_name), '')     as album_name,
        nullif(trim(track_name), '')     as track_name,
        popularity::int                  as popularity,
        duration_ms::int                 as duration_ms,
        round(duration_ms::numeric / 60000, 2) as duration_minutes,
        explicit::boolean                as is_explicit,
        danceability::float              as danceability,
        energy::float                    as energy,
        key::int                         as key,
        loudness::float                  as loudness,
        mode::int                        as mode,
        case when mode = 1 then 'major' else 'minor' end as mode_name,
        speechiness::float               as speechiness,
        acousticness::float              as acousticness,
        instrumentalness::float          as instrumentalness,
        liveness::float                  as liveness,
        valence::float                   as valence,
        tempo::float                     as tempo,
        time_signature::int              as time_signature,
        lower(trim(track_genre))         as track_genre

    from source
    where track_id is not null

)

select * from cleaned
