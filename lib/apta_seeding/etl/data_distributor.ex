defmodule AptaSeeding.ETL.DataDistributor do
  @moduledoc """
  Update tournament results_have_been_processed to true after processing a tournament

  """

  alias AptaSeeding.Data.{Tournament}
  alias AptaSeeding.Repo

  def call() do
    Tournament
    |> Repo.all
    |> Enum.each(fn tournament ->
      tournament.raw_results_html
      |> parse_tournament_results()
      |> create_result_data_structure()
    end)
  end

  @spec parse_tournament_results(binary()) :: list()
  def parse_tournament_results(tournament_results_html) do
    results =
      tournament_results_html
      |> Floki.find("tr")
      |> Enum.map(fn tr ->
        {_, _, [{_, _, [team_name]}, _, {_, _, [team_points]}]} = tr
        %{team_name: team_name, team_points: team_points}
      end)

    {:ok, results}
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
    {player_1_name, player_2_name} = parse_team_players(team_name)
    {team_points, individual_points} = calculate_points(team_points)

    %{
      player_1_name: player_1_name,
      player_2_name: player_2_name,
      team_points: team_points,
      individual_points: individual_points
    }
  end

  def parse_team_players(team_name) do
    [player_1_name, player_2_name] = String.split(team_name, " - ")
    {player_1_name, player_2_name}
  end

  def calculate_points(team_points) do
    team_points = Decimal.new(team_points)
    individual_points = Decimal.div(team_points, Decimal.new(2))
    {team_points, individual_points}
  end
end
