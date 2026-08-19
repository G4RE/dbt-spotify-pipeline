-- Ad hoc analysis: which genres skew toward each mood cluster?
-- Lives in analyses/ rather than models/ because it's a one-off business
-- question, not a table the pipeline needs to maintain. Compiled with
-- `dbt compile` and run manually / through a BI tool, not built by
-- `dbt run`.

with tracks_with_genre as (

    select
        g.track_genre,
        mc.mood_cluster,
        mc.track_id
    from {{ ref('mood_clusters') }} mc
    inner join {{ ref('stg_track_genres') }} g on mc.track_id = g.track_id

)

select
    track_genre,
    mood_cluster,
    count(*) as track_count,
    round(
        100.0 * count(*) / sum(count(*)) over (partition by track_genre),
        1
    ) as pct_of_genre
from tracks_with_genre
group by track_genre, mood_cluster
order by track_genre, pct_of_genre desc
