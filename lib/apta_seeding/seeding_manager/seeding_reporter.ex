defmodule AptaSeeding.SeedingManager.SeedingReporter do
  @moduledoc """
  This is the module that does provides some sanity as we go through this exercise.
  """

  alias AptaSeeding.Data

  @doc """
  Usage:

    "Paulo Gonzalez"
    |> AptaSeeding.SeedingReporter.call()

  """
  def call(name) do
    is_this_a_team = String.contains?(name, "-")
    call(name, is_this_a_team)
  end

  def call(name, true) do
    # team
  end

  def call(name, false) do
    name
    |> Data.find_or_create_player()
    |> Data.preload_results()
    |> create_report()
  end

  @doc """
  This is here temporarily.
  """
  def create_report(player) do
    require EEx

    path =
      Path.join([
        File.cwd!(),
        "lib",
        "apta_seeding",
        "seeding_manager",
        "templates",
        "player_report.html.eex"
      ])

    individual_results = handle_results(player.individual_results)

    team_results =
      player
      |> Data.get_teams_for_player()
      |> Data.get_team_results_for_teams()
      |> handle_results()

    EEx.eval_file(
      path,
      assigns: [
        player_name: player.name,
        individual_results: individual_results,
        team_results: team_results
      ]
    )
  end

  def handle_results(results) do
    results
    |> Enum.map(fn r -> Data.preload_tournament(r) end)
    |> Enum.sort_by(fn r ->
      {r.tournament.date.year, r.tournament.date.month, r.tournament.date.day}
    end)
    |> Enum.reverse()
  end
end
