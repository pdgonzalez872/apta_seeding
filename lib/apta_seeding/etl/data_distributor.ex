defmodule AptaSeeding.ETL.DataDistributor do
  @moduledoc """
  Update tournament results_have_been_processed to true after processing a tournament

    # Do the below in the DataDistributor
    # create the data structure
    # - Player
    # - Team
    # - Player Result (points, half of a team result)
    # - Team Result (points)

  """

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

end
