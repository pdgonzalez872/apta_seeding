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
      assert Enum.at(result, 6) == %{team_name: "Paulo Gonzalez - Jay Schwab", team_points: "34.375"}
      assert Enum.count(result) == 40
    end

    test "create_result_data_structure/1 creates a data structure from a result map" do
      result = %{team_name: "Paulo Gonzalez - Jay Schwab", team_points: "34.375"}
               |> DataDistributor.create_result_data_structure()

      assert result == 1
    end
  end
end
