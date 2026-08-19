-- Buckets each unique track into a mood quadrant based on valence
-- (musical positivity) and energy, using the standard 0.5/0.5 split.

with tracks as (

    select * from {{ ref('stg_tracks') }}

),

audio_features as (

    select * from {{ ref('stg_audio_features') }}

)

select
    t.track_id,
    t.track_name,
    t.artists,
    af.valence,
    af.energy,
    case
        when af.valence >= 0.5 and af.energy >= 0.5 then 'happy_energetic'
        when af.valence >= 0.5 and af.energy < 0.5  then 'calm_positive'
        when af.valence < 0.5  and af.energy >= 0.5 then 'angry_tense'
        else 'sad_low_energy'
    end as mood_cluster
from tracks t
inner join audio_features af on t.track_id = af.track_id
