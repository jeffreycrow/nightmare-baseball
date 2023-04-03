CREATE TRIGGER update_atbats_on_json_update
  AFTER UPDATE
  ON game_json
  FOR EACH STATEMENT
  EXECUTE FUNCTION update_atbats();