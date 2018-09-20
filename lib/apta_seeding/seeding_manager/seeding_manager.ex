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
      # each team will have a seeding_criteria:
      # "team has played 3 tournaments"
      # "team has played 2 tournaments, 1 individual"
      # "team has played 1 tournament, 2 individual"
      #   This is the highest individual possible

      seeding_criteria = get_seeding_criteria(tdo.team)

      #seeding_criteria = "money banks"
      Map.put(tdo, :seeding_criteria, seeding_criteria)
    end)

    state = state
            |> Map.put(:team_data_objects, team_data_objects)

    {:ok, state}
  end

  def get_seeding_criteria(team) do
    team_result_count = Enum.count(team.team_results)
    cond do
      team_result_count >= 3 ->
        "team has played 3 tournaments"
      true ->
        raise "Error in seeding criteria for #{team.name}"
    end

  end
end
