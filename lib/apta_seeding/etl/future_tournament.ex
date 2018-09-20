defmodule AptaSeeding.ETL.FutureTournament do
  @moduledoc """
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
    html_body_response =
      future_tournament_attrs
      |> create_url()
      |> make_request()
  end

  def transform({:ok, html_response}) do
    result = %{
      team_data: get_team_data(html_response),
      tournament_name: get_tournament_name(html_response),
      tournament_date: get_tournament_date(html_response)
    }

    {:ok, result}
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

  @doc """
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

  def get_team_data(html_response) do
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

  def get_tournament_name(html_response) do
    [{_, _, [tournament_name]}] =
      html_response
      |> Floki.find("#header h1")

    tournament_name
  end

  def get_tournament_date(html_response) do
    [{_, _, [tournament_date]}] =
      html_response
      |> Floki.find("#header h2")

    create_date(tournament_date)
  end

  def create_date(date_string) do
    {year, _} =
      date_string
      |> String.split(", ")
      |> Enum.at(-1)
      |> Integer.parse()

    {month, day} =
      date_string
      |> String.split(" - ")
      |> create_month_and_day()

    {:ok, date} = Date.new(year, month, day)
    date
  end

  @doc """
  This happens in all the bigger/serious tournaments.
  """
  def create_month_and_day([start_date, end_date]) do
    [month_abbrev, day] =
      start_date
      |> String.split(", ")
      |> Enum.at(-1)
      |> String.split(" ")

    months = %{
      "Jan" => 1,
      "Feb" => 2,
      "Mar" => 3,
      "Apr" => 4,
      "May" => 5,
      "Jun" => 6,
      "Jul" => 7,
      "Aug" => 8,
      "Sep" => 9,
      "Oct" => 10,
      "Nov" => 11,
      "Dec" => 12
    }

    {:ok, month} = Map.fetch(months, month_abbrev)
    {day, _} = Integer.parse(day)
    {month, day}
  end

  @doc """
  This happens when the tournament is only one day:
  https://platformtennisonline.org/TournamentHome.aspx?eid=180&tid=0
  """
  def create_month_and_day([single_date]) do
    [_, long_date, _] = single_date |> String.split(", ")
    [long_month, day] = long_date |> String.split(" ")

    months = %{
      "January" => 1,
      "February" => 2,
      "March" => 3,
      "April" => 4,
      "May" => 5,
      "June" => 6,
      "July" => 7,
      "August" => 8,
      "September" => 9,
      "October" => 10,
      "November" => 11,
      "December" => 12
    }

    {:ok, month} = Map.fetch(months, long_month)
    {day, _} = Integer.parse(day)
    {month, day}
  end
end
