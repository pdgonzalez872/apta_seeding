defmodule AptaSeeding.ETL.TournamentData do
  @moduledoc """
  This module takes care of dealing with tournament data we retrieve from
  a season. The general

  This module talks to the database to check if we already have data for
  a given tournament.

  If so, we move on to the next tournament.

  If not, we deal with the data that
  comes from making a request to the external api.

  That data has a list of teams and points they got at a specific tournament.

  From here, we build our data model:
  - Player
  - Team
  - Player Result (points, half of a team result)
  - Team Result (points)
  """

  require Logger

  @doc """
  Entry point for this api
  """
  def call(state) do
    {:ok, state}
    |> init()
    |> extract()
    |> transform()
    |> load()
  end

  @doc """
  We create the data we are interested in. We discard unnecessary data by creating a new map
  and using it from now on.
  """
  def init({:ok, state}) do
    state =
      state
      |> Map.put(:step, :tournament_init)

    {:ok, %{step: :tournament_init, params: state.params, tournaments: state.tournaments}}
  end

  def extract({:ok, state}) do

    # make the requests for each tournament here if we don't have it already in the db
    # The check is: tournament name and tournament date

    {:ok, tournaments_data} =
      state.tournaments
      |> Enum.map(fn tournament ->
        # check if tournament

        result = tournament
        |> create_tournament_json_payload()
        |> make_request()
        |> decode_json_response()
        |> parse_tournament_results()

        raise "Add the Data.Tournament concept: table, module"
        raise "Add check that the tournament with the same name and date does not exist already"
        raise "Move the decode_json_response and parse_tournament_results to the transform step"

        # else
        # :already_in_db
      end)


    state =
      state
      |> Map.put(:step, :tournament_extract)
      |> Map.put(:tournaments_data, tournaments_data)

    {:ok, state}
  end

  def transform({:ok, state}) do
    # create the data structure
    # - Player
    # - Team
    # - Player Result (points, half of a team result)
    # - Team Result (points)

    state =
      state
      |> Map.put(:step, :tournament_transform)

    {:ok, state}
  end

  def load({:ok, state}) do
    # This is where we persist
    # Or, we pass through here. Hand the main persisting to something else

    state =
      state
      |> Map.put(:step, :tournament_load)

    {:ok, state}
  end

  @doc"""
  We want to mimic the below request:

  $.ajax({
      async: false, type: "POST", url: "services/2015ServiceRanking.asmx/GetResults",
      data: "{'stype':" + stype + ",'rtype':" + rtype + ",'sid':" + sid + ",'rnum':" + rnum + ",'copt':" + copt + ",'xid':" + xid + "}",
      contentType: "application/json; charset=utf-8", dataType: "json",
      success: function (msg) { $("#r" + xid).html(msg.d); }

  This is what the map coming in looks like:
  %{
    :tournament_date => "03/06/15",
    :tournament_name => "APTA Men's Nationals",
    :xid => "214",
    "copt" => 3,
    "rnum" => 0,
    "rtype" => 1,
    "sid" => 8,
    "stype" => 2,
    "xid" => 0
  }

  Tried sending a json object to the api, didn't work. Will mimic the string creation like they do.
  """
  @spec create_tournament_json_payload(map()) :: binary()
  def create_tournament_json_payload(tournament) do
    stype = tournament["stype"]
    rtype = tournament["rtype"]
    sid = tournament["sid"]
    rnum = tournament["rnum"]
    copt = tournament["copt"]
    xid = tournament.xid

    # This is not pretty. Unsure why passing a json object did not work. This did.
    "{'stype':#{stype},'rtype':#{rtype},'sid':#{sid},'rnum':#{rnum},'copt':#{copt},'xid':#{xid}}"
  end

  @doc """
  Should not be a post, but it is.
  """
  def make_request(params_to_send) do
    target_url = "https://platformtennisonline.org/services/2015ServiceRanking.asmx/GetResults"
    json_content_type = [{"Content-Type", "application/json"}]

    case HTTPoison.post(target_url, params_to_send, json_content_type) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def decode_json_response({:ok, json}) do
    %{"d" => tournament_results_html} = Jason.decode! json
    {:ok, tournament_results_html}
  end

  @spec parse_tournament_results(binary()) :: list()
  def parse_tournament_results({:ok, tournament_results_html}) do
    results =
      tournament_results_html
      |> Floki.find("tr")
      |> Enum.map(fn tr ->
        {_, _, [{_, _, [team_name]}, _, {_, _, [team_points]}]} = tr
        %{team_name: team_name, team_points: team_points}
      end)
    {:ok, results}
  end
end
