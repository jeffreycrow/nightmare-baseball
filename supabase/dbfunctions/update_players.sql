create or replace function update_players()
returns trigger
as $$
DECLARE
 player RECORD;
BEGIN
  FOR player IN SELECT * FROM get_players_from_game_json()
  LOOP
        INSERT INTO players(mlb_player_id, first_name, last_name, primary_position, bat_side, pitch_hand,last_updated,md5_hash)
        VALUES(player.mlb_player_id, player.first_name, player.last_name, player.primary_position, player.bat_side, player.pitch_hand, now(),
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