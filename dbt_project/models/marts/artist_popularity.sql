-- Popularity summary per artist credit.
-- NOTE: renamed from the originally-planned artist_popularity_over_time —
-- the dataset is a point-in-time snapshot with no historical popularity
-- values, so a time-series trend isn't possible with this data.
-- `artists` is used as-is (sometimes multiple collaborators joined by ';');
-- splitting into individual artists would be a reasonable future addition.

with per_track as (

    select distinct
        track_id,
        artists,
        popularity
    from {{ ref('int_tracks_with_audio_features') }}

)

select
    artists,
    count(track_id)                    as track_count,
    round(avg(popularity)::numeric, 1) as avg_popularity,
    max(popularity)                    as max_popularity,
    min(popularity)                    as min_popularity
from per_track
where artists is not null
group by artists
having count(track_id) > 1
order by avg_popularity desc
