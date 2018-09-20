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

    state = {:ok, state}
             |> get_players_and_teams()

    {:ok, state}
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
             end)

    state = state
            |> Map.put(:team_data_objects, result)

    {:ok, state}
  end

end
