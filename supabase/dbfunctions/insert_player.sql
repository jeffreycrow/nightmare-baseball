CREATE OR REPLACE FUNCTION insert_player(id int, first_name varchar, last_name varchar, primary_position varchar, bat_side varchar, pitch_hand varchar)
  RETURNS void AS
  $$
      BEGIN
        INSERT INTO players(mlb_player_id, first_name, last_name, primary_position, bat_side, pitch_hand, last_updated,md5_hash)
        VALUES($1, first_name, last_name, primary_position, bat_side, pitch_hand, now(),
        md5(concat(id::text,first_name::text,last_name::text,primary_position::text,bat_side::text,pitch_hand::text)))
        ON CONFLICT (mlb_player_id) DO UPDATE SET
            first_name=excluded.first_name,
            last_name=excluded.last_name,
            primary_position=excluded.primary_position,
            bat_side=excluded.bat_side,
            pitch_hand=excluded.pitch_hand,
            last_updated=now(),
            md5_hash=excluded.md5_hash
        WHERE players.md5_hash<>excluded.md5_hash;
      END;
  $$
  LANGUAGE 'plpgsql' VOLATILE