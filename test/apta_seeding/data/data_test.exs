defmodule AptaSeeding.DataTest do
  use AptaSeeding.DataCase

  alias AptaSeeding.Data
  alias AptaSeeding.Repo

  describe "tournaments" do
    alias AptaSeeding.Data.Tournament

    @valid_attrs %{
      date: ~D[2010-04-17],
      name: "some name",
      name_and_date_unique_name: "some name_and_date_unique_name",
      results_have_been_processed: true
    }
    @update_attrs %{
      date: ~D[2011-05-18],
      name: "some updated name",
      name_and_date_unique_name: "some updated name_and_date_unique_name",
      results_have_been_processed: false
    }
    @invalid_attrs %{
      date: nil,
      name: nil,
      name_and_date_unique_name: nil,
      results_have_been_processed: nil
    }

    def tournament_fixture(attrs \\ %{}) do
      {:ok, tournament} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Data.create_tournament()

      tournament
    end

    test "list_tournaments/0 returns all tournaments" do
      tournament = tournament_fixture()
      assert Data.list_tournaments() == [tournament]
    end

    test "get_tournament!/1 returns the tournament with given id" do
      tournament = tournament_fixture()
      assert Data.get_tournament!(tournament.id) == tournament
    end

    test "create_tournament/1 with valid data creates a tournament" do
      assert {:ok, %Tournament{} = tournament} = Data.create_tournament(@valid_attrs)
      assert tournament.date == ~D[2010-04-17]
      assert tournament.name == "some name"
      assert tournament.name_and_date_unique_name == "some name_and_date_unique_name"
      assert tournament.results_have_been_processed == true
    end

    test "create_tournament/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Data.create_tournament(@invalid_attrs)
    end

    test "update_tournament/2 with valid data updates the tournament" do
      tournament = tournament_fixture()
      assert {:ok, tournament} = Data.update_tournament(tournament, @update_attrs)
      assert %Tournament{} = tournament
      assert tournament.date == ~D[2011-05-18]
      assert tournament.name == "some updated name"
      assert tournament.name_and_date_unique_name == "some updated name_and_date_unique_name"
      assert tournament.results_have_been_processed == false
    end

    test "update_tournament/2 with invalid data returns error changeset" do
      tournament = tournament_fixture()
      assert {:error, %Ecto.Changeset{}} = Data.update_tournament(tournament, @invalid_attrs)
      assert tournament == Data.get_tournament!(tournament.id)
    end

    test "delete_tournament/1 deletes the tournament" do
      tournament = tournament_fixture()
      assert {:ok, %Tournament{}} = Data.delete_tournament(tournament)
      assert_raise Ecto.NoResultsError, fn -> Data.get_tournament!(tournament.id) end
    end

    test "change_tournament/1 returns a tournament changeset" do
      tournament = tournament_fixture()
      assert %Ecto.Changeset{} = Data.change_tournament(tournament)
    end
  end

  describe "find_or_create_player/1" do
    test "finds or creates players properly" do
      pre_player_count = Data.list_players() |> Enum.count

      cant_find_a_player_that_does_not_exist_so_it_will_create = Data.find_or_create_player("Kasey")

      post_player_create = Data.list_players() |> Enum.count

      assert (post_player_create - pre_player_count) == 1
      assert cant_find_a_player_that_does_not_exist_so_it_will_create.name == "Kasey"

      will_find_this_player_since_it_exists = Data.find_or_create_player("Kasey")
      post_player_find = Data.list_players() |> Enum.count

      did_not_create_a_new_record = post_player_find - post_player_create
      assert did_not_create_a_new_record == 0
    end
  end

  describe "find_or_create_team/1" do
    test "finds or creates teams properly" do
      pre_team_count = Data.list_teams() |> Enum.count

      cant_find_a_team_that_does_not_exist_so_it_will_create = Data.find_or_create_team("Butler - Kasey")

      post_team_create = Data.list_teams() |> Enum.count

      assert (post_team_create - pre_team_count) == 1
      assert cant_find_a_team_that_does_not_exist_so_it_will_create.name == "Butler - Kasey"

      will_find_this_team_since_it_exists = Data.find_or_create_team("Butler - Kasey")
      post_team_find = Data.list_teams() |> Enum.count

      did_not_create_a_new_record = post_team_find - post_team_create
      assert did_not_create_a_new_record == 0
    end
  end


  describe "process_tournament_and_tournament_results/1" do

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

      Data.create_tournament(attrs)
    end

    test "processes results correctly" do
      # assert changes in:
      # - player count
      # - Team count
      # - TeamResult count
      # - PlayerResult count

      pre_player_count = Data.list_players() |> Enum.count

      results_structure = [%{
        individual_points: Decimal.new("34.375"),
        player_1_name: "Ryan Baxter",
        player_2_name: "Ricky Heath",
        team_name: "Ryan Baxter - Ricky Heath",
        team_points: Decimal.new("68.75"),
        tournament_name_and_date_unique_name: "Indi|2018-02-01"
      }]

      tournament = create_indi_tournament()

      output = Data.process_tournament_and_tournament_results(%{tournament: tournament, results_structure: results_structure})

      post_player_count = Data.list_players() |> Enum.count

      #assert output == 1
      assert (post_player_count - pre_player_count) == 2
    end
  end
end
