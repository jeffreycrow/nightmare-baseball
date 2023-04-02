create or replace function update_atbats()
returns trigger
as $$
DECLARE
 atbat RECORD;
BEGIN
  FOR atbat IN SELECT * FROM get_atbats_from_game_json()
  LOOP
        INSERT INTO atbats(id, game_pk, created_at, batter_id, pitcher_id, event_type, rbi, inning)
        VALUES(CONCAT(game_pk), player.first_name, player.last_name, player.primary_position, player.bat_side, player.pitch_hand, now(),
        md5(concat(player.mlb_player_id::text,player.first_name::text,player.last_name::text,player.primary_position::text,player.bat_side::text,player.pitch_hand::text)))
        ON CONFLICT (mlb_player_id) DO UPDATE SET
            first_name=excluded.first_name,
            last_name=excluded.last_name,
            primary_position=excluded.primary_position,
            bat_side=excluded.bat_side,
            pitch_hand=excluded.pitch_hand,
            last_updated=now(),
            md5_hash=excluded.md5_hash
        WHERE md5(concat(player.mlb_player_id::text,player.first_name::text,player.last_name::text,player.primary_position::text,player.bat_side::text,player.pitch_hand::text))<>excluded.md5_hash;
  END LOOP;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;