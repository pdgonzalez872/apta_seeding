defmodule AptaSeeding.Integration.MadeUpCases.Test do
  use ExUnit.Case

  alias AptaSeeding.SeedingManager.SeasonManager
  alias AptaSeeding.SeedingManager
  alias AptaSeeding.Data
  alias AptaSeeding.Data.{Tournament, IndividualResult, TeamResult, Player, Team}
  alias AptaSeeding.Repo

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    Repo.delete_all(Tournament)
    Repo.delete_all(Player)
    Repo.delete_all(IndividualResult)
    Repo.delete_all(Team)
    Repo.delete_all(TeamResult)
    :ok
  end

  describe "integration tests for my sanity" do
    test "team has played 3 in the current season - 1" do
      # create players
      p1 = %{name: "Tyler Fraser"} |> Data.create_player()
      p2 = %{name: "Paulo Gonzalez"} |> Data.create_player()

      # create team
      team =
        %{name: "Tyler Fraser - Paulo Gonzalez", player_1_id: p1.id, player_2_id: p2.id}
        |> Data.create_team()

      # tournament attrs
      [
        %{
          name: "t1",
          name_and_date_unique_name: "t1",
          date: ~D[2018-08-20],
          results_have_been_processed: true,
          raw_results_html: "html"
        },
        %{
          name: "t2",
          name_and_date_unique_name: "t2",
          date: ~D[2018-09-20],
          results_have_been_processed: true,
          raw_results_html: "html"
        },
        %{
          name: "t3",
          name_and_date_unique_name: "t3",
          date: ~D[2018-10-20],
          results_have_been_processed: true,
          raw_results_html: "html"
        },
        %{
          name: "t4",
          name_and_date_unique_name: "t4",
          date: ~D[2018-11-20],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
      ]
      |> Enum.with_index()
      |> Enum.map(fn {tournament_attrs, index} ->
        {:ok, tournament} =
          tournament_attrs
          |> Data.create_tournament()

        {tournament, index}
      end)
      |> Enum.map(fn {tournament, index} ->
        points = Decimal.new((index + 1) * (index + 1))

        %{team_id: team.id, tournament_id: tournament.id, points: points}
        |> Data.create_team_result()
      end)

      {:ok, results} =
        {:ok,
         %{
           tournament_name: "Dummy Tournament",
           tournament_date: ~D[2018-12-24],
           team_data: [{"Tyler Fraser", "Paulo Gonzalez", "Tyler Fraser - Paulo Gonzalez"}]
         }}
        |> SeedingManager.call()

      first_team_result = Enum.at(results.team_data_objects, 0)
      assert first_team_result.seeding_criteria == "team has played 3 tournaments"
      assert first_team_result.team_points == Decimal.new("29.0")
      assert first_team_result.total_seeding_points == Decimal.new("29.0")
    end

    test "team has played 2 tournaments together and players have played with others" do
      # create players
      p1 = %{name: "Tyler Fraser"} |> Data.create_player()
      p2 = %{name: "Paulo Gonzalez"} |> Data.create_player()

      # create team
      team =
        %{name: "Tyler Fraser - Paulo Gonzalez", player_1_id: p1.id, player_2_id: p2.id}
        |> Data.create_team()

      # tournament attrs
      [
        %{
          name: "t3",
          name_and_date_unique_name: "t3",
          date: ~D[2018-10-20],
          results_have_been_processed: true,
          raw_results_html: "html"
        },
        %{
          name: "t4",
          name_and_date_unique_name: "t4",
          date: ~D[2018-11-20],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
      ]
      |> Enum.with_index()
      |> Enum.map(fn {tournament_attrs, index} ->
        {:ok, tournament} =
          tournament_attrs
          |> Data.create_tournament()

        {tournament, index}
      end)
      |> Enum.map(fn {tournament, index} ->
        points = Decimal.new((index + 1) * (index + 1))

        %{team_id: team.id, tournament_id: tournament.id, points: points}
        |> Data.create_team_result()
      end)

      # Paulo plays another tournament with Kasey

       {:ok, tournament} = %{
          name: "t5",
          name_and_date_unique_name: "t5",
          date: ~D[2018-09-20],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: p2.id, tournament_id: tournament.id, points: Decimal.new("500.0")}
      |> Data.create_individual_result()


      # This struct is what will be passed in live requests.
      {:ok, results} =
        {:ok,
         %{
           tournament_name: "Dummy Tournament",
           tournament_date: ~D[2018-12-24],
           team_data: [{"Tyler Fraser", "Paulo Gonzalez", "Tyler Fraser - Paulo Gonzalez"}]
         }}
        |> SeedingManager.call()

      first_team_result = Enum.at(results.team_data_objects, 0)
      assert first_team_result.seeding_criteria == "team has played 2 tournaments, 1 individual"
      assert first_team_result.team_points == Decimal.new("5.0")
      assert first_team_result.total_seeding_points == Decimal.new("455.00")

      # expect(result.first[:team_points]).to eq 5.0
      # expect(result.first[:player_1_points]).to eq 0.0
      # expect(result.first[:player_2_points]).to eq 450.0
      # expect(result.first[:total_seeding_points]).to eq 455.0
    end

    test "team has played 2 tournaments together and players have not played with others" do

    end
  end

  # TODO: Deprecate
  describe "is_current_tournament/2" do
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

    def create_charities_2018() do
      %{
        name: "Chicago Charities Men",
        name_and_date_unique_name: "Chicago Charities Men|2018-11-04",
        date: ~D[2017-11-04],
        results_have_been_processed: true,
        raw_results_html: "html"
      }
      |> Data.create_tournament()
    end

    test "charities 2017 and 2016, then create 2018" do
      create_charities_2017_2016()

      charities_2017 =
        Data.list_tournaments()
        |> Enum.find(fn t -> t.name_and_date_unique_name == "Chicago Charities Men|2017-11-04" end)

      charities_2016 =
        Data.list_tournaments()
        |> Enum.find(fn t -> t.name_and_date_unique_name == "Chicago Charities Men|2016-11-05" end)

      assert SeedingManager.is_current_tournament(charities_2017, Data.list_tournaments()) == true

      assert SeedingManager.is_current_tournament(charities_2016, Data.list_tournaments()) ==
               false

      create_charities_2018()

      charities_2018 =
        Data.list_tournaments()
        |> Enum.find(fn t -> t.name_and_date_unique_name == "Chicago Charities Men|2018-11-04" end)

      assert SeedingManager.is_current_tournament(charities_2018, Data.list_tournaments()) == true

      assert SeedingManager.is_current_tournament(charities_2017, Data.list_tournaments()) ==
               false

      assert SeedingManager.is_current_tournament(charities_2016, Data.list_tournaments()) ==
               false
    end
  end

  # TODO: move this to SeedingManager
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
        SeedingManager.get_tournament_multiplier(charities_2017, Data.list_tournaments(), :team)

      assert charities_2017_results.multiplier == Decimal.new("1.0")

      charities_2016_results =
        SeedingManager.get_tournament_multiplier(charities_2016, Data.list_tournaments(), :team)

      assert charities_2016_results.multiplier == Decimal.new("0.9")
    end

    test "Gets the correct multiplier - last season" do
    end

    test "Gets the correct multiplier - two seasons ago" do
    end
  end

  describe "create_tournament_multiplier_matrix/3" do
    test "returns a matrix with the correct multipliers" do
      create_charities_2017_2016()

      charities_2017 =
        Data.list_tournaments()
        |> Enum.find(fn t -> t.name_and_date_unique_name == "Chicago Charities Men|2017-11-04" end)

      result =
        SeedingManager.create_tournament_multiplier_matrix(
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

  describe "get_team_points/2" do
  end
end
