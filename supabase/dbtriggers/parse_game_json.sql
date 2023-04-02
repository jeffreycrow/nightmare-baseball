CREATE TRIGGER parse_game_json
  AFTER UPDATE
  ON game_json
  FOR EACH STATEMENT
  EXECUTE FUNCTION update_players();
