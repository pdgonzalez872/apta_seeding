defmodule AptaSeeding.AcceptanceTest do
  use ExUnit.Case

  alias AptaSeeding.Data
  alias AptaSeeding.Repo
  alias AptaSeeding.ETL.FutureTournament
  alias AptaSeeding.SeedingManager
  alias AptaSeeding.SeedingReporter

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  @tag :live_request
  describe "This is where we try things out" do
    test "pricing Philly" do
      # priced_tournament_data_structure = %{eid: 228, tid: 496}
      # |> FutureTournament.call()
      # |> SeedingManager.call()

      result = "Paulo Gonzalez"
               |> AptaSeeding.SeedingReporter.call()

      IO.puts result
    end
  end
end
