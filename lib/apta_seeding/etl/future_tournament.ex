defmodule AptaSeeding.ETL.FutureTournament do
  @moduledoc"""
  This is where we manage getting the current player list for a tournament.

  Similar to the other ETL modules, we will have a extract/transform cycle.
  We won't load any data, just will pass it along to other modules that
  will use the data.
  """

  require Logger
  alias AptaSeeding.ETL.DataDistributor

  def call(%{eid: eid, tid: tid} = future_tournament_attrs) do
    future_tournament_attrs
    |> extract()
    |> transform()
  end

  def extract(%{eid: eid, tid: tid} = future_tournament_attrs) do
    html_body_response = future_tournament_attrs
                         |> create_url()
  end

  def transform({:ok, html_response}) do
    team_data = create_team_data(html_response)

    # add tournament
    # tournament_date

    {:ok, %{team_data: team_data}}
  end

  def transform({:error, reason}) do
    raise reason
  end

  def create_url(%{eid: eid, tid: tid}) do
    "https://platformtennisonline.org/TournamentPlayer.aspx?eid=#{eid}&tid=#{tid}"
  end

  def make_request(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc"""
  We put the html response in a structure so we can manipulate it from there.

  I want to know:
    - tournament_name
    - tournament_start_date
    - teams
      - team_name
      - player_1_name
      - player_2_name
  """
  def create_future_tournament_structure(html_response) do
    %{
      tournament_name: "ha",
      tournament_start_date: "2018/10/12",
      teams: [%{team_name: "Paulo - Kels", player_1_name: "Paulo", player_2_name: "Kels"}]
    }

  end

  def create_team_data(html_response) do
    html_response
    |> Floki.find("table.seed td")
    |> Enum.reduce([], fn team_string, acc ->
      acc ++ [handle_team_string(team_string)]
    end)
    |> Enum.filter(fn el -> !is_nil(el) end)
  end

  def handle_team_string({"td", [], ["Teams"]}) do
    nil
  end

  def handle_team_string({"td", [], [team_data]}) do
    {_, _, [team_name]} = team_data
    DataDistributor.parse_team_players(team_name)
  end
end
