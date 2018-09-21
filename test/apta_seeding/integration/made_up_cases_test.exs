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
      p1 = %{name: "Tyler Fraser"} |> Data.create_player()
      p2 = %{name: "Paulo Gonzalez"} |> Data.create_player()

      team =
        %{name: "Tyler Fraser - Paulo Gonzalez", player_1_id: p1.id, player_2_id: p2.id}
        |> Data.create_team()

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
      p1 = %{name: "Tyler Fraser"} |> Data.create_player()
      p2 = %{name: "Paulo Gonzalez"} |> Data.create_player()

      team =
        %{name: "Tyler Fraser - Paulo Gonzalez", player_1_id: p1.id, player_2_id: p2.id}
        |> Data.create_team()

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

      {:ok, tournament} =
        %{
          name: "t5",
          name_and_date_unique_name: "t5",
          date: ~D[2018-09-20],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: p2.id, tournament_id: tournament.id, points: Decimal.new("500.0")}
      |> Data.create_individual_result()

      {:ok, results} =
        {:ok,
         %{
           tournament_name: "Dummy Tournament",
           tournament_date: ~D[2018-12-24],
           team_data: [{"Tyler Fraser", "Paulo Gonzalez", "Tyler Fraser - Paulo Gonzalez"}]
         }}
        |> SeedingManager.call()

      first_team_result = Enum.at(results.team_data_objects, 0)

      assert first_team_result.seeding_criteria ==
               "team has played 2 tournaments, 1 best individual"

      assert first_team_result.team_points == Decimal.new("5.0")
      assert first_team_result.total_seeding_points == Decimal.new("455.00")
    end

    test "team has played 2 tournaments together and players have not played with others" do
      p1 = %{name: "Tyler Fraser"} |> Data.create_player()
      p2 = %{name: "Paulo Gonzalez"} |> Data.create_player()

      team =
        %{name: "Tyler Fraser - Paulo Gonzalez", player_1_id: p1.id, player_2_id: p2.id}
        |> Data.create_team()

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

      {:ok, results} =
        {:ok,
         %{
           tournament_name: "Dummy Tournament",
           tournament_date: ~D[2018-12-24],
           team_data: [{"Tyler Fraser", "Paulo Gonzalez", "Tyler Fraser - Paulo Gonzalez"}]
         }}
        |> SeedingManager.call()

      first_team_result = Enum.at(results.team_data_objects, 0)

      assert first_team_result.seeding_criteria ==
               "team has played 2 tournaments, 1 best individual"

      assert first_team_result.team_points == Decimal.new("5.0")
      assert first_team_result.total_seeding_points == Decimal.new("5.0")
    end

    test "team has played 1 tournament together and players have played 2 with others" do
      p1 = %{name: "Tyler Fraser"} |> Data.create_player()
      p2 = %{name: "Paulo Gonzalez"} |> Data.create_player()

      team =
        %{name: "Tyler Fraser - Paulo Gonzalez", player_1_id: p1.id, player_2_id: p2.id}
        |> Data.create_team()

      {:ok, tournament} =
        %{
          name: "t1",
          name_and_date_unique_name: "t1",
          date: ~D[2018-11-20],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{team_id: team.id, tournament_id: tournament.id, points: Decimal.new("500.0")}
      |> Data.create_team_result()

      # Paulo plays another tournament with Kasey
      {:ok, tournament} =
        %{
          name: "t5",
          name_and_date_unique_name: "t5",
          date: ~D[2018-09-20],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: p2.id, tournament_id: tournament.id, points: Decimal.new("500.0")}
      |> Data.create_individual_result()

      # Tyler with Butler
      %{player_id: p1.id, tournament_id: tournament.id, points: Decimal.new("500.0")}
      |> Data.create_individual_result()

      {:ok, results} =
        {:ok,
         %{
           tournament_name: "Dummy Tournament",
           tournament_date: ~D[2018-12-24],
           team_data: [{"Tyler Fraser", "Paulo Gonzalez", "Tyler Fraser - Paulo Gonzalez"}]
         }}
        |> SeedingManager.call()

      first_team_result = Enum.at(results.team_data_objects, 0)

      assert first_team_result.seeding_criteria ==
               "team has played 1 tournament, 2 best individual"

      assert first_team_result.team_points == Decimal.new("500.00")
      assert first_team_result.total_seeding_points == Decimal.new("1400.00")

      expected_details =
        [
          %{
            multiplier: Decimal.new("1.0"),
            points: Decimal.new("500.0"),
            team: "Tyler Fraser - Paulo Gonzalez",
            total_points: Decimal.new("500.00"),
            tournament_unique_name: "t1"
          },
          %{
            multiplier: Decimal.new("0.9"),
            player: "Paulo Gonzalez",
            points: Decimal.new("500.0"),
            total_points: Decimal.new("450.00"),
            tournament_unique_name: "t5"
          },
          %{
            multiplier: Decimal.new("0.9"),
            player: "Tyler Fraser",
            points: Decimal.new("500.0"),
            total_points: Decimal.new("450.00"),
            tournament_unique_name: "t5"
          }
        ]
      assert first_team_result.calculation_details == expected_details
    end

    test "team has never played together" do
      p1 = %{name: "Tyler Fraser"} |> Data.create_player()
      p2 = %{name: "Paulo Gonzalez"} |> Data.create_player()

      # Paulo plays another tournament with Kasey
      {:ok, tournament} =
        %{
          name: "t5",
          name_and_date_unique_name: "t5",
          date: ~D[2018-09-20],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: p2.id, tournament_id: tournament.id, points: Decimal.new("500.0")}
      |> Data.create_individual_result()

      # Tyler with Butler
      %{player_id: p1.id, tournament_id: tournament.id, points: Decimal.new("500.0")}
      |> Data.create_individual_result()

      # Paulo plays another tournament with Kasey
      {:ok, tournament} =
        %{
          name: "t6",
          name_and_date_unique_name: "t6",
          date: ~D[2018-10-20],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: p2.id, tournament_id: tournament.id, points: Decimal.new("700.0")}
      |> Data.create_individual_result()

      # Tyler with Butler
      %{player_id: p1.id, tournament_id: tournament.id, points: Decimal.new("700.0")}
      |> Data.create_individual_result()

      {:ok, results} =
        {:ok,
         %{
           tournament_name: "Dummy Tournament",
           tournament_date: ~D[2018-12-24],
           team_data: [{"Tyler Fraser", "Paulo Gonzalez", "Tyler Fraser - Paulo Gonzalez"}]
         }}
        |> SeedingManager.call()

      first_team_result = Enum.at(results.team_data_objects, 0)

      assert first_team_result.seeding_criteria ==
               "team has not played together, 3 best individual"

      assert first_team_result.team_points == Decimal.new("0")
      assert first_team_result.total_seeding_points == Decimal.new("2160.00")

      expected_details =
        [
          %{
            multiplier: Decimal.new("0.9"),
            player: "Paulo Gonzalez",
            points: Decimal.new("700.0"),
            total_points: Decimal.new("630.00"),
            tournament_unique_name: "t6"
          },
          %{
            multiplier: Decimal.new("0.9"),
            player: "Paulo Gonzalez",
            points: Decimal.new("500.0"),
            total_points: Decimal.new("450.00"),
            tournament_unique_name: "t5"
          },
          %{
            multiplier: Decimal.new("0.9"),
            player: "Tyler Fraser",
            points: Decimal.new("700.0"),
            total_points: Decimal.new("630.00"),
            tournament_unique_name: "t6"
          },
          %{
            multiplier: Decimal.new("0.9"),
            player: "Tyler Fraser",
            points: Decimal.new("500.0"),
            total_points: Decimal.new("450.00"),
            tournament_unique_name: "t5"
          }
        ]

      assert first_team_result.calculation_details == expected_details
    end
  end

  describe "These test cases try to be real" do
    test "Anthony McPhearson - this was a bug previously" do
      p1 = %{name: "Anthony McPherson"} |> Data.create_player()
      p2 = %{name: "Paulo Gonzalez"} |> Data.create_player()

      {:ok, tournament} =
        %{
          name: "Chicago Charities Men",
          name_and_date_unique_name: "chicago_charities_2017",
          date: ~D[2017-11-04],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: p1.id, tournament_id: tournament.id, points: Decimal.new("10.5625")}
      |> Data.create_individual_result()

      {:ok, tournament} =
        %{
          name: "Milwaukee Men",
          name_and_date_unique_name: "milwa_2017",
          date: ~D[2017-10-21],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: p1.id, tournament_id: tournament.id, points: Decimal.new("7.703125")}
      |> Data.create_individual_result()

      {:ok, tournament} =
        %{
          name: "Chicago Charities Men",
          name_and_date_unique_name: "chicago_charities_2016",
          date: ~D[2016-11-05],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: p1.id, tournament_id: tournament.id, points: Decimal.new("9.375")}
      |> Data.create_individual_result()

      {:ok, results} =
        {:ok,
         %{
           tournament_name: "Dummy Tournament",
           tournament_date: ~D[2018-12-24],
           team_data: [{"Anthony McPherson", "Paulo Gonzalez", "Anthony McPherson - Paulo Gonzalez"}]
         }}
        |> SeedingManager.call()

      first_team_result = Enum.at(results.team_data_objects, 0)

      assert first_team_result.seeding_criteria ==
               "team has not played together, 3 best individual"

      assert first_team_result.team_points == Decimal.new("0")
      assert first_team_result.total_seeding_points == Decimal.new("21.1265625")

      expected_details =
        [
          %{
            multiplier: Decimal.new("0.9"),
            player: "Anthony McPherson",
            points: Decimal.new("7.703125"),
            total_points: Decimal.new("6.9328125"),
            tournament_unique_name: "milwa_2017"
          },
          %{
            multiplier: Decimal.new("0.5"),
            player: "Anthony McPherson",
            points: Decimal.new("9.375"),
            total_points: Decimal.new("4.6875"),
            tournament_unique_name: "chicago_charities_2016"
          },
          %{
            multiplier: Decimal.new("0.9"),
            player: "Anthony McPherson",
            points: Decimal.new("10.5625"),
            total_points: Decimal.new("9.50625"),
            tournament_unique_name: "chicago_charities_2017"
          }
        ]

      assert first_team_result.calculation_details == expected_details
    end

    test "" do
      # # This is what has to happen:
      # #
      # # Jeff McMaster - Tom Wiese, criteria: team has played 1 tournament, 2 best individual
      # #   Jeff McMaster, 12/05/15 West Penn Men, 0.5, 20.25
      # #   Jeff McMaster, 11/14/15 Cleveland Masters Men, 0.5, 19.125
      # #   Tom Wiese, 10/14/17 Steel City Open Men, 0.9, 12.1875
      # #   Tom Wiese, 11/11/17 Cleveland Masters Men, 0.9, 5.25
      # #   Tom Wiese, 12/05/15 West Penn Men, 0.5, 20.25

      # jm = Player.create!(name: "Jeff McMaster")
      # tw = Player.create!(name: "Tom Wiese")
      # team = Team.create!(combined_name: "Jeff McMaster - Tom Wiese")

      # # They play a tournament together
      # #   Jeff McMaster, 12/05/15 West Penn Men, 0.5, 20.25
      # #   Tom Wiese, 12/05/15 West Penn Men, 0.5, 20.25
      # west_penn_2015 = Tournament.create!(name: "West Penn Men",
      #                                     full_name: "12/05/15 West Penn Men",
      #                                     date: Date.new(2015, 12, 5))
      # west_penn_2015_points = 40.5
      # TeamResult.create!(team_id: team.id, tournament_id: west_penn_2015.id, points: west_penn_2015_points)
      # IndividualResult.create!(player_id: jm.id, tournament_id: west_penn_2015.id, points: west_penn_2015_points / 2.0)
      # IndividualResult.create!(player_id: tw.id, tournament_id: west_penn_2015.id, points: west_penn_2015_points / 2.0)

      # # They play a tournament together, Cleveland 2015
      # #   Jeff McMaster, 11/14/15 Cleveland Masters Men, 0.5, 19.125
      # #   Note that despite playing, this won't count for Tom Wiese
      # cleveland_2015 = Tournament.create!(name: "Cleveland Masters Men",
      #                                     full_name: "11/14/15 Cleveland Masters Men",
      #                                     date: Date.new(2015, 11, 14))
      # cleveland_2015_points = 38.25
      # TeamResult.create!(team_id: team.id, tournament_id: cleveland_2015.id, points: cleveland_2015_points)
      # IndividualResult.create!(player_id: jm.id, tournament_id: cleveland_2015.id, points: cleveland_2015_points / 2.0)
      # IndividualResult.create!(player_id: tw.id, tournament_id: cleveland_2015.id, points: cleveland_2015_points / 2.0)

      # # Cleveland 2016 happens, they don't play in it
      # cleveland_2016 = Tournament.create!(name: "Cleveland Masters Men",
      #                                     full_name: "11/14/16 Cleveland Masters Men",
      #                                     date: Date.new(2016, 11, 14))

      # #   Tom Wiese, 10/14/17 Steel City Open Men, 0.9, 12.1875
      # steel_2017 = Tournament.create!(name: "Steel City Open Men",
      #                                  full_name: "10/14/17 Steel City Open Men",
      #                                  date: Date.new(2017, 10, 14))
      # IndividualResult.create!(player_id: tw.id, tournament_id: steel_2017.id, points: 12.1875)

      # #   Tom Wiese, 11/11/17 Cleveland Masters Men, 0.9, 5.25
      # cleveland_2017 = Tournament.create!(name: "Cleveland Masters Men",
      #                                     full_name: "11/11/17 Cleveland Masters Men",
      #                                     date: Date.new(2017, 11, 11))
      # IndividualResult.create!(player_id: tw.id, tournament_id: cleveland_2017.id, points: 5.25)

      # # May need to create more  data to mimic prod

      # # We should be at the correct state now
      # seed_manager = described_class.new(combined_names_input: ["Jeff McMaster - Tom Wiese"],
      #                                    tournament_object: Tournament.new(name: "West Penn", date: Date.new(2017, 11, 30)))
      # result = seed_manager.calculate_seeds_for_tournament

      # calculation_details = ["Jeff McMaster, 12/05/15 West Penn Men, 0.5, 20.25",
      #                        "Jeff McMaster, 11/14/15 Cleveland Masters Men, 0.5, 19.125",
      #                        "Tom Wiese, 10/14/17 Steel City Open Men, 0.9, 12.1875",
      #                        "Tom Wiese, 11/11/17 Cleveland Masters Men, 0.9, 5.25",
      #                        "Tom Wiese, 12/05/15 West Penn Men, 0.5, 20.25"]

      # expect(result.first[:calculation_details]).to eq calculation_details
    end

    test "kahler/grangeiro" do

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

  # TODO: delete this
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
