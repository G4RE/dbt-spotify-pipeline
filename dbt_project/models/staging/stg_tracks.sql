-- One row per unique track_id. The raw data repeats a track once per genre
-- it's tagged under (with identical metadata each time), so we dedupe here
-- to get a clean track-level grain for joins and uniqueness tests.

with base as (

    select * from {{ ref('stg_spotify_tracks') }}

),

deduped as (

    select
        track_id,
        artists,
        album_name,
        track_name,
        popularity,
        duration_ms,
        duration_minutes,
        is_explicit,
        row_number() over (
            partition by track_id
            order by source_row_id
        ) as rn

    from base

)

select
    track_id,
    artists,
    album_name,
    track_name,
    popularity,
    duration_ms,
    duration_minutes,
    is_explicit
from deduped
where rn = 1
