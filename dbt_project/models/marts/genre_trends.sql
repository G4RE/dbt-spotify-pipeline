-- Avg. audio-feature and popularity profile per genre.
-- NOTE: renamed from the originally-planned genre_trends_by_year — the
-- dataset has no release date or listening-history timestamp, so a
-- year-over-year breakdown isn't possible with this data. This mart gives
-- a per-genre snapshot instead.

with base as (

    select * from {{ ref('int_tracks_with_audio_features') }}

)

select
    track_genre,
    count(distinct track_id)               as track_count,
    round(avg(popularity)::numeric, 1)     as avg_popularity,
    round(avg(danceability)::numeric, 3)   as avg_danceability,
    round(avg(energy)::numeric, 3)         as avg_energy,
    round(avg(valence)::numeric, 3)        as avg_valence,
    round(avg(tempo)::numeric, 1)          as avg_tempo,
    round(avg(acousticness)::numeric, 3)   as avg_acousticness,
    round(avg(instrumentalness)::numeric, 3) as avg_instrumentalness,
    round(avg(speechiness)::numeric, 3)    as avg_speechiness
from base
group by track_genre
order by avg_popularity desc
