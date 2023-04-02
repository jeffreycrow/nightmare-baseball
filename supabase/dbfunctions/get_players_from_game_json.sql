create or replace function get_players_from_game_json()
returns TABLE(created_at timestamp with time zone, mlb_player_id integer, first_name varchar, last_name varchar, primary_position varchar, bat_side varchar, pitch_hand varchar, last_updated timestamp with time zone)
as $$
    SELECT
        now() as created_at,
        (to_json(json_each(game_json->'gameData'->'players'))->'value'->>'id')::int as mlb_player_id,
        to_json(json_each(game_json->'gameData'->'players'))->'value'->>'useName' as first_name,
        to_json(json_each(game_json->'gameData'->'players'))->'value'->>'useLastName' as last_name, 
        to_json(json_each(game_json->'gameData'->'players'))->'value'->'primaryPosition'->>'abbreviation' as primary_position,
        to_json(json_each(game_json->'gameData'->'players'))->'value'->'batSide'->>'code' as bat_side,
        to_json(json_each(game_json->'gameData'->'players'))->'value'->'pitchHand'->>'code' as pitch_hand,
        now() as last_updated
    FROM game_json
    WHERE game_date=(current_timestamp at time zone 'america/los_angeles')::date
$$ language sql;