create or replace function update_atbats()
returns trigger
as $$
DECLARE
 atbat RECORD;
BEGIN
  FOR atbat IN SELECT * FROM get_atbats_from_game_json()
  LOOP
    INSERT INTO atbats(id, game_pk, created_at, event_type, rbi, batter_id, pitcher_id, inning)
    VALUES(atbat.id, atbat.game_pk, atbat.created_at, atbat.event_type, atbat.rbi, atbat.batter_id, atbat.pitcher_id, atbat.inning)
    ON CONFLICT (id) DO NOTHING;
  END LOOP;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;