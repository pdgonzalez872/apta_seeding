defmodule AptaSeeding.ETL.DataDistributor do
  @moduledoc """
  Update tournament results_have_been_processed to true after processing a tournament

  """

  alias AptaSeeding.Data.{Tournament}
  alias AptaSeeding.Data
  alias AptaSeeding.Repo

  def call(tournaments) do
    results =
      tournaments
      |> Enum.map(fn tournament ->
        results_structure =
          tournament.raw_results_html
          |> parse_tournament_results()
          |> Enum.map(fn r ->
            r
            |> create_result_data_structure()
            |> Map.put(
              :tournament_name_and_date_unique_name,
              tournament.name_and_date_unique_name
            )
          end)

        process_tournament_and_tournament_results(%{
          tournament: tournament,
          results_structure: results_structure
        })
      end)

    :ok
  end

  @spec parse_tournament_results(binary()) :: list()
  def parse_tournament_results(tournament_results_html) do
    tournament_results_html
    |> Floki.find("tr")
    |> Enum.map(fn tr ->
      {_, _, [{_, _, [team_name]}, _, {_, _, [team_points]}]} = tr
      %{team_name: team_name, team_points: team_points}
    end)
  end

  @doc """
  Do the below in the DataDistributor
  create the data structure
  - Player
  - Team
  - Player Result (points, half of a team result)
  - Team Result (points)
  """
  def create_result_data_structure(%{team_name: team_name, team_points: team_points}) do
    {player_1_name, player_2_name, real_team_name} = parse_team_players(team_name)
    {team_points, individual_points} = calculate_points(team_points)

    %{
      team_name: real_team_name,
      player_1_name: player_1_name,
      player_2_name: player_2_name,
      team_points: team_points,
      individual_points: individual_points
    }
  end

  @doc """
  This is where we will have
  - tournament
  - results_structure

  This function will delegate to the Data api and have it do the work.
  """
  def process_tournament_and_tournament_results(args) do
    Data.process_tournament_and_tournament_results(args)
  end

  def parse_team_players(team_name) do
    [player_1_name, player_2_name] = String.split(team_name, " - ")
    p1 = sanitize_player_name(player_1_name)
    p2 = sanitize_player_name(player_2_name)
    team = [p1, p2] |> Enum.join(" - ")
    {p1, p2, team}
  end

  def sanitize_player_name(player_name) do
    player_name
    |> String.split(" ")
    |> Enum.filter(fn el -> !(el == "") end)
    |> Enum.join(" ")
  end

  def calculate_points(team_points) do
    team_points = Decimal.new(team_points)
    individual_points = Decimal.div(team_points, Decimal.new(2))
    {team_points, individual_points}
  end
end
