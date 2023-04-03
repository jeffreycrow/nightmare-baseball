create or replace function get_atbats_from_game_json()
returns TABLE(id integer, game_pk integer, created_at timestamp with time zone, event_type varchar, rbi integer, batter_id integer, pitcher_id integer, inning integer)
as $$
    SELECT
        concat(game_pk, (play->'about'->>'atBatIndex'))::int as id, 
        game_pk::int as game_pk,
        now() as created_at,
        play->'result'->>'eventType' as event_type,
        (play->'result'->>'rbi')::int as rbi,
        (play->'matchup'->'batter'->>'id')::int as batter_id,
        (play->'matchup'->'pitcher'->>'id')::int as pitcher_id,
        (play->'about'->>'inning')::int as inning
    FROM (
        SELECT
            game_pk,
            json_array_elements(game_json->'liveData'->'plays'->'allPlays') as play        
        FROM game_json
        WHERE game_date=(current_timestamp at time zone 'america/los_angeles')::date
    ) a
$$ language sql;