defmodule AptaSeeding.ETL.DataDistributorTest do
  use ExUnit.Case

  alias AptaSeeding.ETL.DataDistributor

  describe "DataDistributor" do
    test "parse_tournament_results/1 parses the tournament results correctly" do
      html =
        [
          System.cwd(),
          "test",
          "apta_seeding",
          "etl",
          "static_files_for_test",
          "raw_tournament_result_indi_2018.html"
        ]
        |> Path.join()
        |> File.read!()

      {:ok, result} = DataDistributor.parse_tournament_results(html)

      assert Enum.at(result, 0) == %{team_name: "Ryan Baxter - Ricky Heath", team_points: "68.75"}
      assert Enum.at(result, 5) == %{team_name: "Scott Kahler - Matt  Rogers", team_points: "38.5"}
      assert Enum.at(result, 6) == %{team_name: "Paulo Gonzalez - Jay Schwab", team_points: "34.375"}
      assert Enum.count(result) == 40
    end

    test "create_result_data_structure/1 creates a data structure from a result map - simple name case" do
      result = %{team_name: "Paulo Gonzalez - Jay Schwab", team_points: "34.375"}
               |> DataDistributor.create_result_data_structure()

      expected = %{
        player_1_name: "Paulo Gonzalez",
        player_2_name: "Jay Schwab",
        team_points: Decimal.new("34.375"),
        individual_points: Decimal.new("17.1875"),
      }
      assert result == expected
    end

    @tag :skip
    test "create_result_data_structure/1 creates a data structure from a result map - spaces in name" do
      result = %{team_name: "Scott Kahler - Matt  Rogers", team_points: "38.5"}
               |> DataDistributor.create_result_data_structure()

      expected = %{
        player_1_name: "Scott Kahler",
        player_2_name: "Matt Rogers", # no double space in the name here
        team_points: 38.5,
        individual_points: 19.25,
      }
      assert result == expected
    end

    # TODO: Sanitize input -> Johan du Rant
    # Matt  Rogers
    # Scott  Yancey
  end
end
