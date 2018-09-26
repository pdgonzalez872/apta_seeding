defmodule AptaSeeding.SeedingManager.SeasonManagerTest do
  use ExUnit.Case

  alias AptaSeeding.SeedingManager.SeasonManager
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

  describe "seasons_ago/1" do
    test "returns the correct number of seasons ago - current season" do
      result = SeasonManager.seasons_ago(~D[2018-10-06])

      assert result == 0
    end

    test "returns the correct number of seasons ago - ending in 2018" do
      result = SeasonManager.seasons_ago(~D[2018-01-06])

      assert result == 1
    end

    test "returns the correct number of seasons ago - ending in 2018 - beginning of it" do
      result = SeasonManager.seasons_ago(~D[2017-11-06])

      assert result == 1
    end

    test "returns the correct number of seasons ago - ending in 2017" do
      result = SeasonManager.seasons_ago(~D[2017-03-06])

      assert result == 2
    end
  end

  describe "find_season_attrs/1" do
    test "returns the data structure for the season - current" do
      result = SeasonManager.find_season_attrs(~D[2018-10-06])

      assert result.multiplier == Decimal.new("1.0")
    end

    test "returns the data structure for the season - ending in 2017" do
      result = SeasonManager.find_season_attrs(~D[2017-03-06])

      assert result.multiplier == Decimal.new("0.5")
    end
  end

  describe "create_tournament_multiplier_matrix/3" do
    test "returns a matrix with the correct multipliers" do
      create_charities_2017_2016()

      charities_2017 =
        Data.list_tournaments()
        |> Enum.find(fn t -> t.name_and_date_unique_name == "Chicago Charities Men|2017-11-04" end)

      result =
        SeasonManager.create_tournament_multiplier_matrix(
          charities_2017,
          Data.list_tournaments(),
          :team
        )

      {most_recent_tournament, most_recent_multiplier} = Enum.at(result, 0)

      assert most_recent_tournament.name_and_date_unique_name ==
               "Chicago Charities Men|2017-11-04"

      assert most_recent_multiplier == Decimal.new(1.0)

      {second_most_recent_tournament, second_most_recent_multiplier} = Enum.at(result, 1)

      assert second_most_recent_tournament.name_and_date_unique_name ==
               "Chicago Charities Men|2016-11-05"

      assert second_most_recent_multiplier == Decimal.new(0.9)
    end
  end

  describe "groups results per season and picks it accordingly" do
    test "ha" do

    end

  end
end
