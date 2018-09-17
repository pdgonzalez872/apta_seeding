defmodule AptaSeeding.DataTest do
  use AptaSeeding.DataCase

  alias AptaSeeding.Data

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
      tournament = create_indi_tournament()
      assert tournament == 1
    end
  end
end
