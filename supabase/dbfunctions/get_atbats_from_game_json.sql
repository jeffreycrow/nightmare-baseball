create or replace function get_atbats_from_game_json()
returns TABLE(created_at timestamp with time zone, game_pk integer, event_type varchar, rbi integer, batter_id integer, pitcher_id integer, inning integer, last_updated timestamp with time zone)
as $$
    SELECT
        now() as created_at,
        game_pk::int as game_pk,
        play->'result'->>'eventType' as event_type,
        (play->'result'->>'rbi')::int as rbi,
        (play->'matchup'->'batter'->>'id')::int as batter_id,
        (play->'matchup'->'pitcher'->>'id')::int as pitcher_id,
        (play->'about'->>'inning')::int as inning,
        now() as last_updated
    FROM (
        SELECT
            game_pk,
            json_array_elements(game_json->'liveData'->'plays'->'allPlays') as play        
        FROM game_json
        WHERE game_date=(current_timestamp at time zone 'america/los_angeles')::date
    ) a
$$ language sql;