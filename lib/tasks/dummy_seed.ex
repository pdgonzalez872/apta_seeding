defmodule Mix.Tasks.DummySeed do
  use Mix.Task
  require Logger
  require IEx

  alias AptaSeeding.Data
  alias AptaSeeding.Repo
  alias AptaSeeding.ETL.FutureTournament
  alias AptaSeeding.SeedingManager
  # need to change the namespace there.
  alias AptaSeeding.SeedingReporter
  alias AptaSeeding.SeedingManager.SeasonManager

  @moduledoc """
  This is the task to be run on a daily/weekly basis

  To run this:
  $ `mix dummy_seed`
  """

  def run(_args) do
    Logger.info("Starting Task")

    Application.ensure_all_started(:apta_seeding)

    Logger.info("Fetching live seeds from website, this is live.")
    {:ok, result} = priced_tournament_data_structure = %{eid: 228, tid: 496}
    |> FutureTournament.call()
    |> SeedingManager.call()

    result.sorted_seeding
    |> Enum.reduce("", fn e, first_acc ->
      details = Enum.reduce(e.calculation_details, "", fn d, second_acc ->
        second_acc <> " #{d.direct_object}, #{d.multiplier}, #{d.points}, #{d.tournament_unique_name}\n"
      end)
      first_acc <> "#{e.team.name}, #{e.seeding_criteria}, #{e.total_seeding_points}, #{Decimal.round(Decimal.div(e.total_seeding_points, Decimal.new("3.0")), 4)}\n #{details}"
    end)
    |> IO.puts()

    Logger.info("Finish Task")
  end
end