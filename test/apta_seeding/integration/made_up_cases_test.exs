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
      p1 = %{name: "Paulo Gonzalez"} |> Data.create_player()
      p2 = %{name: "Tyler Fraser"} |> Data.create_player()

      # create team
      team = %{name: "Tyler Fraser - Paulo Gonzalez", player_1_id: p1.id, player_2_id: p2.id}
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
        },
      ]
      |> Enum.with_index()
      |> Enum.map(fn {tournament_attrs, index} ->
           {:ok, tournament} = tournament_attrs
                               |> Data.create_tournament()
           {tournament, index}
      end)
      |> Enum.map(fn {tournament, index} ->
           points = Decimal.new((index + 1) * (index + 1))

           %{team_id: team.id, tournament_id: tournament.id, points: points}
           |> Data.create_team_result()
      end)


      # This struct is what will be passed in live requests.
      {:ok, results} = {:ok,
        %{
          tournament_name: "Dummy Tournament",
          tournament_date: ~D[2018-12-24],
          team_data: [{"Tyler Fraser", "Paulo Gonzalez", "Tyler Fraser - Paulo Gonzalez"}]
        }
      }
      |> SeedingManager.call()

      #require IEx; IEx.pry

      first_team_result = Enum.at(results.team_data_objects, 0)
      assert first_team_result.seeding_criteria == "team has played 3 tournaments"


      # expect(result.size).to eq 1
      # expect(result.first[:chosen_tournament_criteria]).to eq("team has played 3 tournaments")
      # expect(result.first[:team_points]).to eq 29.0
      # expect(result.first[:total_seeding_points]).to eq 29.0
    end
  end
end
