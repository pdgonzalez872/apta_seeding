defmodule AptaSeeding.SeedingManager.TournamentPickerTest do
  use ExUnit.Case

  alias AptaSeeding.SeedingManager.{TournamentPicker}
  alias AptaSeeding.Data

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(AptaSeeding.Repo)
  end

  def create_charities_2017_2016() do
    [
      %{
        name: "Chicago Charities Men",
        name_and_date_unique_name: "Chicago Charities Men|2017-11-04",
        date: ~D[2017-11-04],
        results_have_been_processed: true,
        raw_results_html: "html"
      },
      %{
        name: "Chicago Charities Men",
        name_and_date_unique_name: "Chicago Charities Men|2016-11-05",
        date: ~D[2016-11-05],
        results_have_been_processed: true,
        raw_results_html: "html"
      }
    ]
    |> Enum.map(fn tournament_attrs -> Data.create_tournament(tournament_attrs) end)
  end

  describe "get_tournament_multiplier/3" do
    test "Gets the correct multiplier - Current tournament" do
      create_charities_2017_2016()

      charities_2017 =
        Data.list_tournaments()
        |> Enum.find(fn t -> t.name_and_date_unique_name == "Chicago Charities Men|2017-11-04" end)

      charities_2016 =
        Data.list_tournaments()
        |> Enum.find(fn t -> t.name_and_date_unique_name == "Chicago Charities Men|2016-11-05" end)

      charities_2017_results =
        TournamentPicker.get_tournament_multiplier(charities_2017, Data.list_tournaments(), :team)

      assert charities_2017_results.multiplier == Decimal.new("1.0")

      charities_2016_results =
        TournamentPicker.get_tournament_multiplier(charities_2016, Data.list_tournaments(), :team)

      assert charities_2016_results.multiplier == Decimal.new("0.9")
    end
  end
end
