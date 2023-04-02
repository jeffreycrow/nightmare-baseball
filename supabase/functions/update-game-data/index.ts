import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@1.33.1";

async function getGamesForDay(date: Date) {
  const res = await fetch(
    "https://statsapi.mlb.com/api/v1/schedule/games/?sportId=1",
    {
      method: "GET"
    }
  );
  const data = await res.json();
  return data;
}

async function getDataForGame(gamePk: Number) {
  console.log('in gdfg ',gamePk)
  const res = await fetch(
    "https://statsapi.mlb.com/api/v1.1/game/"+gamePk+"/feed/live",
    {
      method: 'GET',
      mode: 'cors'
    }
  );
  console.log('gdfg res ok? ',res.status)
  const data = await res.json();
  console.log('getdataforgame end')
  return data;
}

serve(async (req:Request) => {
  console.log('FUNCTION START')
  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )
    console.log('supabase client created')
    const gamesData = await getGamesForDay(new Date());
    let games = []
    try {
        games = gamesData.dates[0].games.map((gameData: any) => ({
        game_pk: gameData.gamePk,
        last_updated: new Date(),
        link: gameData.link,
        detailed_state: gameData.status.detailedState,
        game_type: gameData.gameType,
        game_timestamp: gameData.gameDate,
        game_date: new Date(gameData.officialDate),
        home_team: gameData.teams.home.team.id,
        away_team: gameData.teams.away.team.id,
        game_data: gameData
      }));
    } catch (error) {
      console.log('ERROR: ', error)
    }
    let {error, status} = await supabaseClient.from('games').upsert(games, {onConflict: 'game_pk', ignoreDuplicates: false});
    console.log('upsert games status',status)
    if(status==201) {
      games.forEach(async (game: any) => {
        console.log('inside foreach',game.game_pk)
        let gameJSON = await getDataForGame(game.game_pk)
        console.log('after await')
        let game_data = {
          game_pk: game.game_pk,
          game_json: gameJSON,
          game_date: game.game_date,
          last_updated: new Date().toISOString()
        }
        let {error, status} = await supabaseClient.from('game_json').upsert(game_data, {onConflict: 'game_pk', ignoreDuplicates: false})
        console.log('game_json upsert',status,error)
        if(status==201) {
          //good result
          return {
            status_code: 201,
            body: {status:'success'}
          }
        } else {
          return {
            status_code: 500,
            body:{status:'error'}
          }
        }
      })

    } else {
      return {
        status_code: 500,
        body: { status: 'error', errorMsg: error}
      }
    }
  } catch(error) {
    console.log('ERROR',error)
  }
});