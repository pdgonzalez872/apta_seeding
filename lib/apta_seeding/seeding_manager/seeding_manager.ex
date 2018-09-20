defmodule AptaSeeding.SeedingManager do
  @moduledoc """
  This module is responsible for calculating the seeds. It follows a procedure
  that is somewhere online on the APTA website.  The gist of it is below, was
  sent via email by Eric Miller.

  The below is almost correct. They just didn't have the concept of "season"
  before. It turns out it is not 12 months, but instead, a "season".

  === Tournament Weighting Procedure (sent via email by Eric Miller) ===

  Does team have 3 or more results together in prior 12 month period?

  Yes – Use the average of the best 3 results

  No – Do both players have at least
  3 individual results in the prior 24 month period?

    Yes – Use 100% of the points earned together, plus 90% of the most points
    earned with another partner in the prior 12 months, plus 50% of the most
    points earned with any partner in the past 24 months to come up with 3
    results for each player.  Calculate the average based on the 3 results used.

    No – Use as many results as are available in the prior 24 months using 100%
    of the points earned together, plus 90% of the most points earned with
    another partner in the prior 12 months, plus 50% of the most points earned
    with any partner in the past 24 months.  Calculate the average using 3 as the
    dominator even though less than 3 results were used to determine the total.

  Sort all teams by average descending.

  Take the total average of the top 24 teams in the tournament.

  Double that total.

  Apply that number to the chart below to determine the tournament strength.
  (will show this later, it is a large table)
  ===
  """

  alias AptaSeeding.Data
  alias AptaSeeding.SeedingManager.SeasonManager

  def call(
        {:ok,
         %{
           team_data: team_data,
           tournament_name: tournament_name,
           tournament_date: tournament_date
         } = state}
      ) do

    {:ok, state}
    |> get_players_and_teams()
    |> analyse_each_team()
  end

  def get_players_and_teams({:ok, state}) do
    result = state.team_data
             |> Enum.map(fn td ->
               {p1_name, p2_name, team_name} = td

               p1 = p1_name
                    |> Data.find_or_create_player()
                    |> Data.preload_results()

               p2 = p2_name
                    |> Data.find_or_create_player()
                    |> Data.preload_results()

               team = team_name
               |> Data.find_or_create_team()
               |> Data.preload_results()

               %{player_1: p1, player_2: p2, team: team}
             end)

    state = state
            |> Map.put(:team_data_objects, result)

    {:ok, state}
  end

  def analyse_each_team({:ok, state}) do
    team_data_objects = state.team_data_objects
    |> Enum.map(fn tdo ->
      seeding_criteria = get_seeding_criteria(tdo.team)
      team_results_details = get_team_points(tdo, seeding_criteria)
      details = get_details_for_calculations(team_results_details)

      tdo
      |> Map.put(:seeding_criteria, seeding_criteria)
      |> Map.put(:team_points, team_results_details.total_points)
    end)

    state = state
            |> Map.put(:team_data_objects, team_data_objects)

    {:ok, state}
  end

  @doc"""
  each team will have a seeding_criteria:
  "team has played 3 tournaments"
  "team has played 2 tournaments, 1 individual"
  "team has played 1 tournament, 2 individual"
   and 0.
  """
  def get_seeding_criteria(team) do
    team_result_count = Enum.count(team.team_results)
    cond do
      team_result_count >= 3 ->
        "team has played 3 tournaments"

      team_result_count == 2 ->
        "team has played 2 tournaments, 1 individual"

      team_result_count == 1 ->
        "team has played 1 tournament, 2 individual"

      team_result_count == 0 ->
        "team has not played together, 3 individual"

      true ->
        raise "Error in seeding criteria for #{team.name}"
    end
  end

  def get_team_points(team_data_object, "team has played 3 tournaments") do
    team_results_objects = team_data_object.team.team_results
    |> Enum.sort_by(fn tr ->
      tr = tr
           |> Data.preload_tournament()
      tr.tournament.date
    end)
    |> Enum.map(fn tr -> Data.preload_tournament(tr) end)
    |> Enum.reverse()
    |> Enum.take(3)
    |> Enum.map(fn tr ->
         # TODO: optimization: pass only the tournaments with the same name instead of all
         result = get_tournament_multiplier(tr.tournament, Data.list_tournaments())
         %{
           tournament_unique_name: tr.tournament.name_and_date_unique_name,
           team: tr.team.name,
           multiplier: result.multiplier,
           points: tr.points,
           total_points: Decimal.mult(result.multiplier, tr.points)
         }
    end)

    total_points = team_results_objects
    |> Enum.reduce(0, fn obj, acc ->
      Decimal.add(acc, obj.total_points)
    end)

    %{total_points: total_points, details: team_results_objects}
  end

  def get_details_for_calculations(team_results_details) do
    # TODO: Remove this. We have the data already, this
    # will be shown in the view.
  end

  @doc"""
  We get the multiplier for each tournament.
  The trick is to know what a "current tournament" is, which not even the APTA seems
  to know exactly, at least not how they state on their rules. From our side, a
  current tournament is a tournament that has not been played in the current season.

  Ex:
  We are currently in Sep 2018.
    Charities 2017 was played in Nov 2017. This is a "current tournament", should be 100% of points, multiplier 1
      (Note that Charities 2018 will happen in Nov 2018, so not yet in this example.)
    Charities 2016 was played in Nov 2016. This is not a current tournament, should be 90%, because it was 1 season ago. multiplier 0.9
    Charities 2015 was played in Nov 2015. This is not a current tournament, should be 50%, because it was 2 seasons ago. multiplier 0.5
  """
  def get_tournament_multiplier(tournament, all_tournaments) do
    {t, multiplier} = create_tournament_multiplier_matrix(tournament, all_tournaments)
    |> Enum.find(fn {t, multiplier} ->
      t.name_and_date_unique_name == tournament.name_and_date_unique_name
    end)
    %{tournament: t, multiplier: multiplier}
  end

  def create_tournament_multiplier_matrix(tournament, all_tournaments) do
    SeasonManager.create_tournament_multiplier_matrix(tournament, all_tournaments)
  end

  def is_current_tournament(tournament, all_tournaments) do
    SeasonManager.is_current_tournament(tournament, all_tournaments)
  end
end
