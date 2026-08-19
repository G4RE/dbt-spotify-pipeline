-- Singular test: fails (returns rows) if any track has valence or energy
-- outside the expected 0-1 range documented by Spotify's audio features API.

select
    track_id,
    valence,
    energy
from {{ ref('stg_audio_features') }}
where valence < 0 or valence > 1
   or energy < 0 or energy > 1
