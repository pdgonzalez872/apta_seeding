defmodule AptaSeeding.AcceptanceTest do
  use ExUnit.Case

  alias AptaSeeding.Repo
  alias AptaSeeding.ETL.FutureTournament
  alias AptaSeeding.SeedingManager
  alias AptaSeeding.SeedingManager.SeasonManager

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  # @tag :skip
  describe "This is where we try things out" do
    test "pricing Philly" do
      # this is the live stuff, the real stuff.
      # result = priced_tournament_data_structure = %{eid: 228, tid: 496}
      # |> FutureTournament.call()
      # |> SeedingManager.call()

      html =
        [
          System.cwd(),
          "test",
          "apta_seeding",
          "etl",
          "static_files_for_test",
          "future_tournament_philly_2018_2019.html"
        ]
        |> Path.join()
        |> File.read!()

      _result =
        {:ok, html}
        |> FutureTournament.transform()
        |> SeedingManager.call()

      s = SeasonManager.call()

      target_date = ~D[2017-10-20]
      _result = Enum.find_index(s, fn season -> target_date in season.interval end)

      # require IEx
      # IEx.pry()
    end
  end
end
