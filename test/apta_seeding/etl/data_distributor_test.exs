defmodule AptaSeeding.ETL.DataDistributorTest do
  use ExUnit.Case

  alias AptaSeeding.ETL.DataDistributor
  alias AptaSeeding.Data
  alias AptaSeeding.Repo

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  def create_indi_tournament() do
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

    attrs = %{
      date: ~D[2018-02-01],
      name: "Indi",
      name_and_date_unique_name: "Indi|2018-02-01",
      results_have_been_processed: false,
      raw_results_html: html
    }

    {:ok, tournament} = Data.create_tournament(attrs)
    tournament
  end

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

      result = DataDistributor.parse_tournament_results(html)

      assert Enum.at(result, 0) == %{team_name: "Ryan Baxter - Ricky Heath", team_points: "68.75"}

      assert Enum.at(result, 5) == %{
               team_name: "Scott Kahler - Matt  Rogers",
               team_points: "38.5"
             }

      assert Enum.at(result, 6) == %{
               team_name: "Paulo Gonzalez - Jay Schwab",
               team_points: "34.375"
             }

      assert Enum.count(result) == 40
    end

    test "create_result_data_structure/1 creates a data structure from a result map - simple name case" do
      result =
        %{team_name: "Paulo Gonzalez - Jay Schwab", team_points: "34.375"}
        |> DataDistributor.create_result_data_structure()

      expected = %{
        team_name: "Paulo Gonzalez - Jay Schwab",
        player_1_name: "Paulo Gonzalez",
        player_2_name: "Jay Schwab",
        team_points: Decimal.new("34.375"),
        individual_points: Decimal.new("17.1875")
      }

      assert result == expected
    end

    test "create_result_data_structure/1 creates a data structure from a result map - spaces in name" do
      result =
        %{team_name: "Scott Kahler - Matt  Rogers", team_points: "38.5"}
        |> DataDistributor.create_result_data_structure()

      expected = %{
        team_name: "Scott Kahler - Matt Rogers",
        player_1_name: "Scott Kahler",
        # no double space in the name here
        player_2_name: "Matt Rogers",
        team_points: Decimal.new("38.5"),
        individual_points: Decimal.new("19.25")
      }

      assert result == expected
    end

    # TODO: Sanitize input -> Johan du Rant
    # Matt  Rogers
    # Scott  Yancey

    test "sanitize_player_name/1 - sanity test 1" do
      # raise "Continue here"
    end

    test "sanitize_player_name/1 - sanity test 2" do
    end

    test "sanitize_player_name/1 - sanity test 3" do
    end

    test "call/1 - integration test here. Making sure that things fit together" do
      _tournament = create_indi_tournament()

      result = DataDistributor.call(Data.list_tournaments())

      assert result == :ok
    end

    test "persist_results/1 - persists records correctly" do
      input = %{
        individual_points: Decimal.new("34.375"),
        player_1_name: "Ryan Baxter",
        player_2_name: "Ricky Heath",
        team_name: "Ryan Baxter - Ricky Heath",
        team_points: Decimal.new("68.75"),
        tournament_name_and_date_unique_name: "Indi|2018-02-01"
      }
    end
  end
end
