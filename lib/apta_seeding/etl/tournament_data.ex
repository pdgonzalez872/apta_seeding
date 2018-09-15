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

  require Ecto.Query
  alias AptaSeeding.Data.{Tournament}

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
    # if already in the db, then move on. If not, make the request for the data and add to the state.
    # all of the state will be processed later by the DataDistributor, in the "Load" part of the ETL

    {:ok, tournaments_data} =
      state.tournaments
      |> Enum.map(fn tournament ->

        # Make keys atoms:
        # TODO: Fix the source of this problem: When we make the original request to get the season
        tournament = Enum.reduce(tournament, %{}, fn({k, v}, acc) ->
          Map.put(acc, String.to_atom("#{k}"), v)
        end)

        # check if tournament
        date = parse_date(tournament.tournament_date)
        name = tournament.tournament_name

        attrs = %{
          date: date,
          name: name,
          name_and_date_unique_name: "#{name}|#{Date.to_string(date)}",
          results_have_been_processed: false,
        }

        change = Tournament.changeset(%Tournament{}, attrs)

        case Repo.insert(change) do
          {:ok, tournament} ->

            Logger.info("New tournament, will process it")

          {:error, changeset} ->
            Logger.info("Tournament already created")
          _ ->
            raise "whoa"


        end

        require IEx; IEx.pry

        result = tournament
        |> create_tournament_json_payload()
        |> make_request()
        |> decode_json_response()
        |> parse_tournament_results()

        # Continue here: check if the tournament exists or not already. If so, do nothing. If not, make request
        # When done, add the tournaments to the state. I want a season to have tournaments. and the tournaments to have a "status"
        # status are :nothing_to_do or :must_process (if they exist or not). If they don't make the request, and add it to a map

        raise "Move the decode_json_response and parse_tournament_results to the transform step"

        # set "results_have_been_processed" to true for the tournament

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
    # Do the below in the DataDistributor
    # create the data structure
    # - Player
    # - Team
    # - Player Result (points, half of a team result)
    # - Team Result (points)

    # Here, we want to only do some filtering on if a tournament needs to be processed or not.
    # the ones that need to be processed will have the data to be processed (The results from the tournament).

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

  @spec parse_date(binary()) :: any()
  def parse_date(date) do
    [month, day, incomplete_year] = String.split(date, "/")
    {:ok, date} = Date.new(String.to_integer("20#{incomplete_year}"), String.to_integer(month), String.to_integer(day))
    date
  end
end
