defmodule AptaSeeding.Integration.MadeUpCases.Test do
  use ExUnit.Case

  # alias AptaSeeding.SeedingReporter
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
      assert first_team_result.seeding_criteria == :team_has_played_3_tournaments
      assert first_team_result.team_points == Decimal.new("29.0")
      assert first_team_result.total_seeding_points == Decimal.new("29.0")

      expected_details = [
        %{
          direct_object: "Tyler Fraser - Paulo Gonzalez",
          multiplier: Decimal.new("1.0"),
          points: Decimal.new("16"),
          total_points: Decimal.new("16.0"),
          tournament_unique_name: "t4"
        },
        %{
          direct_object: "Tyler Fraser - Paulo Gonzalez",
          multiplier: Decimal.new("1.0"),
          points: Decimal.new("9"),
          total_points: Decimal.new("9.0"),
          tournament_unique_name: "t3"
        },
        %{
          direct_object: "Tyler Fraser - Paulo Gonzalez",
          multiplier: Decimal.new("1.0"),
          points: Decimal.new("4"),
          total_points: Decimal.new("4.0"),
          tournament_unique_name: "t2"
        }
      ]

      assert first_team_result.calculation_details == expected_details
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
               :team_has_played_2_tournaments_1_best_individual

      assert first_team_result.team_points == Decimal.new("5.0")
      assert first_team_result.total_seeding_points == Decimal.new("455.00")

      expected_details = [
        %{
          direct_object: "Tyler Fraser - Paulo Gonzalez",
          multiplier: Decimal.new("1.0"),
          points: Decimal.new("4"),
          total_points: Decimal.new("4.0"),
          tournament_unique_name: "t4"
        },
        %{
          direct_object: "Tyler Fraser - Paulo Gonzalez",
          multiplier: Decimal.new("1.0"),
          points: Decimal.new("1"),
          total_points: Decimal.new("1.0"),
          tournament_unique_name: "t3"
        },
        %{
          direct_object: "Paulo Gonzalez",
          multiplier: Decimal.new("0.9"),
          points: Decimal.new("500.0"),
          total_points: Decimal.new("450.00"),
          tournament_unique_name: "t5"
        }
      ]

      assert first_team_result.calculation_details == expected_details
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
               :team_has_played_2_tournaments_1_best_individual

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
               :team_has_played_1_tournament_2_best_individual

      assert first_team_result.team_points == Decimal.new("500.00")
      assert first_team_result.total_seeding_points == Decimal.new("1400.00")

      expected_details = [
        %{
          multiplier: Decimal.new("1.0"),
          points: Decimal.new("500.0"),
          direct_object: "Tyler Fraser - Paulo Gonzalez",
          total_points: Decimal.new("500.00"),
          tournament_unique_name: "t1"
        },
        %{
          multiplier: Decimal.new("0.9"),
          direct_object: "Paulo Gonzalez",
          points: Decimal.new("500.0"),
          total_points: Decimal.new("450.00"),
          tournament_unique_name: "t5"
        },
        %{
          multiplier: Decimal.new("0.9"),
          direct_object: "Tyler Fraser",
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
               :team_has_not_played_together_3_best_individual

      assert first_team_result.team_points == Decimal.new("0")
      assert first_team_result.total_seeding_points == Decimal.new("2160.00")

      expected_details = [
        %{
          multiplier: Decimal.new("0.9"),
          direct_object: "Paulo Gonzalez",
          points: Decimal.new("700.0"),
          total_points: Decimal.new("630.00"),
          tournament_unique_name: "t6"
        },
        %{
          multiplier: Decimal.new("0.9"),
          direct_object: "Paulo Gonzalez",
          points: Decimal.new("500.0"),
          total_points: Decimal.new("450.00"),
          tournament_unique_name: "t5"
        },
        %{
          multiplier: Decimal.new("0.9"),
          direct_object: "Tyler Fraser",
          points: Decimal.new("700.0"),
          total_points: Decimal.new("630.00"),
          tournament_unique_name: "t6"
        },
        %{
          multiplier: Decimal.new("0.9"),
          direct_object: "Tyler Fraser",
          points: Decimal.new("500.0"),
          total_points: Decimal.new("450.00"),
          tournament_unique_name: "t5"
        }
      ]

      assert first_team_result.calculation_details == expected_details
    end
  end

  describe "These test cases try to be real" do
    test "Anthony McPhearson - this was an edge case we found previously" do
      p1 = %{name: "Anthony McPherson"} |> Data.create_player()
      _p2 = %{name: "Paulo Gonzalez"} |> Data.create_player()

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
           team_data: [
             {"Anthony McPherson", "Paulo Gonzalez", "Anthony McPherson - Paulo Gonzalez"}
           ]
         }}
        |> SeedingManager.call()

      first_team_result = Enum.at(results.team_data_objects, 0)

      assert first_team_result.seeding_criteria ==
               :team_has_not_played_together_3_best_individual

      assert first_team_result.team_points == Decimal.new("0")
      assert first_team_result.total_seeding_points == Decimal.new("21.1265625")

      expected_details = [
        %{
          multiplier: Decimal.new("0.9"),
          direct_object: "Anthony McPherson",
          points: Decimal.new("7.703125"),
          total_points: Decimal.new("6.9328125"),
          tournament_unique_name: "milwa_2017"
        },
        %{
          multiplier: Decimal.new("0.5"),
          direct_object: "Anthony McPherson",
          points: Decimal.new("9.375"),
          total_points: Decimal.new("4.6875"),
          tournament_unique_name: "chicago_charities_2016"
        },
        %{
          multiplier: Decimal.new("0.9"),
          direct_object: "Anthony McPherson",
          points: Decimal.new("10.5625"),
          total_points: Decimal.new("9.50625"),
          tournament_unique_name: "chicago_charities_2017"
        }
      ]

      sorted_results = Enum.sort_by(first_team_result.calculation_details, fn r -> r.tournament_unique_name end)
      sorted_expected = Enum.sort_by(expected_details, fn r -> r.tournament_unique_name end)

      assert sorted_results == sorted_expected
    end

    test "Jeff McMaster - Tom Wiese - this was an edge case we found as well" do
      cleveland_masters_men = "Cleveland Masters Men"

      jm = %{name: "Jeff McMaster"} |> Data.create_player()
      tw = %{name: "Tom Wiese"} |> Data.create_player()

      team =
        %{name: "Jeff McMaster - Tom Wiese", player_1_id: jm.id, player_2_id: tw.id}
        |> Data.create_team()

      # They play a tournament together
      #   Jeff McMaster, 12/05/15 West Penn Men, 0.5, 20.25
      #   Tom Wiese, 12/05/15 West Penn Men, 0.5, 20.25
      {:ok, tournament} =
        %{
          name: "West Penn Men",
          name_and_date_unique_name: "12/05/15 West Penn Men",
          date: ~D[2015-12-05],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      west_penn_2015_points = Decimal.new("40.5")
      %{team_id: team.id, tournament_id: tournament.id, points: west_penn_2015_points}
      |> Data.create_team_result()

      %{player_id: jm.id, tournament_id: tournament.id, points: Decimal.div(west_penn_2015_points, Decimal.new("2"))}
      |> Data.create_individual_result()

      %{player_id: tw.id, tournament_id: tournament.id, points: Decimal.div(west_penn_2015_points, Decimal.new("2"))}
      |> Data.create_individual_result()

      # They play a tournament together, Cleveland 2015
      #   Jeff McMaster, 11/14/15 Cleveland Masters Men, 0.5, 19.125
      #   Note that despite playing, this won't count for Tom Wiese
      {:ok, tournament} =
        %{
          name: cleveland_masters_men,
          name_and_date_unique_name: "11/14/15 Cleveland Masters Men",
          date: ~D[2015-11-14],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      cleveland_2015_points = Decimal.new("38.25")
      %{team_id: team.id, tournament_id: tournament.id, points: cleveland_2015_points}
      |> Data.create_team_result()

      %{player_id: jm.id, tournament_id: tournament.id, points: Decimal.div(cleveland_2015_points, Decimal.new("2"))}
      |> Data.create_individual_result()

      %{player_id: tw.id, tournament_id: tournament.id, points: Decimal.div(cleveland_2015_points, Decimal.new("2"))}
      |> Data.create_individual_result()

      # Cleveland 2016 happens, they don't play in it
      {:ok, _tournament} =
        %{
          name: cleveland_masters_men,
          name_and_date_unique_name: "11/14/16 Cleveland Masters Men",
          date: ~D[2016-11-14],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      # West Penn 2016 happens and they don't play in it
      {:ok, _tournament} =
        %{
          name: "West Penn Men",
          name_and_date_unique_name: "12/05/16 West Penn Men",
          date: ~D[2016-12-05],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      #   Tom Wiese, 10/14/17 Steel City Open Men, 0.9, 12.1875
      {:ok, tournament} =
        %{
          name: "Steel City Open Men",
          name_and_date_unique_name: "10/14/17 Steel City Open Men",
          date: ~D[2017-10-14],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: tw.id, tournament_id: tournament.id, points: Decimal.new("12.1875")}
      |> Data.create_individual_result()

      #   Tom Wiese, 11/11/17 Cleveland Masters Men, 0.9, 5.25
      {:ok, tournament} =
        %{
          name: cleveland_masters_men,
          name_and_date_unique_name: "11/11/17 Cleveland Masters Men",
          date: ~D[2017-11-11],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: tw.id, tournament_id: tournament.id, points: Decimal.new("5.25")}
      |> Data.create_individual_result()

      {:ok, results} =
        {:ok,
         %{
           tournament_name: "Dummy",
           tournament_date: ~D[2017-11-30],
           team_data: [{"Jeff McMaster", "Tom Wiese", "Jeff McMaster - Tom Wiese"}]
         }}
        |> SeedingManager.call()

      first_team_result = Enum.at(results.team_data_objects, 0)

      assert first_team_result.seeding_criteria == :team_has_not_played_together_3_best_individual

      expected_details =
      #1  "Jeff McMaster, 11/14/15 Cleveland Masters Men, 0.5, 19.125",
              [%{
                direct_object: "Jeff McMaster",
                multiplier: Decimal.new("0.5"),
                points: Decimal.new("19.125"),
                total_points: Decimal.new("9.5625"),
                tournament_unique_name: "11/14/15 Cleveland Masters Men"
              },

      #2 ["Jeff McMaster, 12/05/15 West Penn Men, 0.5, 20.25",
              %{
                direct_object: "Jeff McMaster",
                multiplier: Decimal.new("0.5"),
                points: Decimal.new("20.25"),
                total_points: Decimal.new("10.125"),
                tournament_unique_name: "12/05/15 West Penn Men"
              },

      #3  "Tom Wiese, 12/05/15 West Penn Men, 0.5, 20.25"]
              %{
                direct_object: "Tom Wiese",
                multiplier: Decimal.new("0.5"),
                points: Decimal.new("20.25"),
                total_points: Decimal.new("10.125"),
                tournament_unique_name: "12/05/15 West Penn Men"
              },

      #4  "Tom Wiese, 10/14/17 Steel City Open Men, 0.9, 12.1875",
              %{
                direct_object: "Tom Wiese",
                multiplier: Decimal.new("0.9"),
                points: Decimal.new("12.1875"),
                total_points: Decimal.new("10.96875"),
                tournament_unique_name: "10/14/17 Steel City Open Men"
              },

      #5  "Tom Wiese, 11/11/17 Cleveland Masters Men, 0.9, 5.25",
              %{
                direct_object: "Tom Wiese",
                multiplier: Decimal.new("0.9"),
                points: Decimal.new("5.25"),
                total_points: Decimal.new("4.725"),
                tournament_unique_name: "11/11/17 Cleveland Masters Men"
              }
            ]

      sorted_results = Enum.sort_by(first_team_result.calculation_details, fn r -> r.tournament_unique_name end)
      sorted_expected = Enum.sort_by(expected_details, fn r -> r.tournament_unique_name end)

      _r = [sorted_results, sorted_expected]
      |> Enum.zip()
      |> Enum.map(fn {_result, _expected} ->
        nil
        # require IEx; IEx.pry
        # assert result == expected
      end)

      assert sorted_results == sorted_expected

      # This is the output we want:
      # calculation_details = ["Jeff McMaster, 12/05/15 West Penn Men, 0.5, 20.25",
      #                        "Jeff McMaster, 11/14/15 Cleveland Masters Men, 0.5, 19.125",
      #                        "Tom Wiese, 10/14/17 Steel City Open Men, 0.9, 12.1875",
      #                        "Tom Wiese, 11/11/17 Cleveland Masters Men, 0.9, 5.25",
      #                        "Tom Wiese, 12/05/15 West Penn Men, 0.5, 20.25"]
    end

    test "kahler/grangeiro - this is a great test" do
      # # This is what we observed:
      # #
      # # Marco Grangeiro - Scott Kahler, criteria: team has not played, 3 best individual
      # #   Marco Grangeiro, 11/04/17 Chicago Charities Men, 0.9, 34.125
      # #   Marco Grangeiro, 12/02/17 Duane L. Hayden Invitational Men, 0.9, 33.75
      # #   Marco Grangeiro, 11/18/17 Sound Shore Men, 0.9, 30.1875
      # #   Scott Kahler, 01/28/17 Boston Open Men, 0.9, 36.0
      # #   Scott Kahler, 01/14/17 Midwesterns Men, 0.9, 34.875
      # #   Scott Kahler, 10/14/17 Steel City Open Men, 0.9, 33.75
      # #
      # # Test Case:
      # #   But this team played a tournament last season (Sound Shore 2016-2017)
      # #   The rule here is that we only use current seasons tournaments for a team and ignore all rest.
      # #   What we have above should be correct

      sk = %{name: "Scott Kahler"} |> Data.create_player()
      mg = %{name: "Marco Grangeiro"} |> Data.create_player()

      team =
        %{name: "Marco Grangeiro - Scott Kahler", player_1_id: mg.id, player_2_id: sk.id}
        |> Data.create_team()

      # sound_shore_2016 = Tournament.create!(name: "Sound Shore Men",
      #                                       full_name: "11/19/16 Sound Shore Men",
      #                                       date: Date.new(2016, 11, 19))

      # # They play a tournament together 1 season ago, Sound Shore
      {:ok, tournament} =
        %{
          name: "Sound Shore Men",
          name_and_date_unique_name: "11/19/16 Sound Shore Men",
          date: ~D[2016-11-19],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      sound_shore_2016_points = Decimal.new("56.25")
      %{team_id: team.id, tournament_id: tournament.id, points: sound_shore_2016_points}
      |> Data.create_team_result()

      %{player_id: mg.id, tournament_id: tournament.id, points: Decimal.div(sound_shore_2016_points, Decimal.new("2"))}
      |> Data.create_individual_result()

      %{player_id: sk.id, tournament_id: tournament.id, points: Decimal.div(sound_shore_2016_points, Decimal.new("2"))}
      |> Data.create_individual_result()

      # # SK plays Boston
      # #   Scott Kahler, 01/28/17 Boston Open Men, 0.9, 36.0
      {:ok, tournament} =
        %{
          name: "Boston Open Men",
          name_and_date_unique_name: "01/28/17 Boston Open Men",
          date: ~D[2017-01-28],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: sk.id, tournament_id: tournament.id, points: Decimal.new("36")}
      |> Data.create_individual_result()

      # #SK plays Midwesterns
      # #   Scott Kahler, 01/14/17 Midwesterns Men, 0.9, 34.875
      {:ok, tournament} =
        %{
          name: "Midwesterns Men",
          name_and_date_unique_name: "01/14/17 Midwesterns Men",
          date: ~D[2017-01-14],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: sk.id, tournament_id: tournament.id, points: Decimal.new("34.875")}
      |> Data.create_individual_result()

      # # SK plays Steel City
      # #   Scott Kahler, 10/14/17 Steel City Open Men, 0.9, 33.75
      {:ok, tournament} =
        %{
          name: "Steel City Open Men",
          name_and_date_unique_name: "10/14/17 Steel City Open Men",
          date: ~D[2017-10-14],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: sk.id, tournament_id: tournament.id, points: Decimal.new("33.75")}
      |> Data.create_individual_result()

      # # MG plays Charities 2017
      # #   Marco Grangeiro, 11/04/17 Chicago Charities Men, 0.9, 34.125
      {:ok, tournament} =
        %{
          name: "Chicago Charities Men",
          name_and_date_unique_name: "11/04/17 Chicago Charities Men",
          date: ~D[2017-11-14],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: mg.id, tournament_id: tournament.id, points: Decimal.new("34.125")}
      |> Data.create_individual_result()

      # # MG plays duane_hayden_2017
      # #   Marco Grangeiro, 12/02/17 Duane L. Hayden Invitational Men, 0.9, 33.75
      {:ok, tournament} =
        %{
          name: "Duane L. Hayden Invitational Men",
          name_and_date_unique_name: "12/02/17 Duane L. Hayden Invitational Men",
          date: ~D[2017-12-02],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: mg.id, tournament_id: tournament.id, points: Decimal.new("33.75")}
      |> Data.create_individual_result()

      # # MG plays Sound Shore 2017
      # #   Marco Grangeiro, 11/18/17 Sound Shore Men, 0.9, 30.1875
      {:ok, tournament} =
        %{
          name: "Sound Shore Men",
          name_and_date_unique_name: "11/18/17 Sound Shore Men",
          date: ~D[2017-11-18],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: mg.id, tournament_id: tournament.id, points: Decimal.new("30.1875")}
      |> Data.create_individual_result()

      # # Test is not good. Must add more to the state here:
      # # MG plays Marco Grangeiro, 10/29/16 Atlantic Classic Men, 0.5, 30.375
      {:ok, tournament} =
        %{
          name: "Atlantic Classic Men",
          name_and_date_unique_name: "10/29/16 Atlantic Classic Men",
          date: ~D[2016-10-29],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      %{player_id: mg.id, tournament_id: tournament.id, points: Decimal.new("30.375")}
      |> Data.create_individual_result()

      # # And the 2017 version of that tournament occurs
      {:ok, _tournament} =
        %{
          name: "Atlantic Classic Men",
          name_and_date_unique_name: "10/28/17 Atlantic Classic Men",
          date: ~D[2017-10-28],
          results_have_been_processed: true,
          raw_results_html: "html"
        }
        |> Data.create_tournament()

      # # We should be at the correct state now

      {:ok, results} =
        {:ok,
         %{
           tournament_name: "West Penn",
           tournament_date: ~D[2017-11-30],
           team_data: [{"Marco Grangeiro", "Scott Kahler", "Marco Grangeiro - Scott Kahler"}]
         }}
        |> SeedingManager.call()

      first_team_result = Enum.at(results.team_data_objects, 0)

      expected_details = [

      # ["Marco Grangeiro, 11/04/17 Chicago Charities Men, 0.9, 34.125",
        %{
          multiplier: Decimal.new("0.9"),
          direct_object: "Marco Grangeiro",
          points: Decimal.new("34.125"),
          total_points: Decimal.new("30.7125"),
          tournament_unique_name: "11/04/17 Chicago Charities Men"
        },
      #  "Marco Grangeiro, 12/02/17 Duane L. Hayden Invitational Men, 0.9, 33.75",
        %{
          multiplier: Decimal.new("0.9"),
          direct_object: "Marco Grangeiro",
          points: Decimal.new("33.75"),
          total_points: Decimal.new("30.375"),
          tournament_unique_name: "12/02/17 Duane L. Hayden Invitational Men"
        },
      #  "Marco Grangeiro, 11/18/17 Sound Shore Men, 0.9, 30.1875",
        %{
          multiplier: Decimal.new("0.9"),
          direct_object: "Marco Grangeiro",
          points: Decimal.new("30.1875"),
          total_points: Decimal.new("27.16875"),
          tournament_unique_name: "11/18/17 Sound Shore Men"
        },
      #  "Scott Kahler, 01/28/17 Boston Open Men, 0.9, 36.0",
        %{
          multiplier: Decimal.new("0.9"),
          direct_object: "Scott Kahler",
          points: Decimal.new("36"),
          total_points: Decimal.new("32.4"),
          tournament_unique_name: "01/28/17 Boston Open Men"
        },
      #  "Scott Kahler, 01/14/17 Midwesterns Men, 0.9, 34.875",
        %{
          multiplier: Decimal.new("0.9"),
          direct_object: "Scott Kahler",
          points: Decimal.new("34.875"),
          total_points: Decimal.new("31.3875"),
          tournament_unique_name: "01/14/17 Midwesterns Men"
        },
      #  "Scott Kahler, 10/14/17 Steel City Open Men, 0.9, 33.75"]
        %{
          multiplier: Decimal.new("0.9"),
          direct_object: "Scott Kahler",
          points: Decimal.new("33.75"),
          total_points: Decimal.new("30.375"),
          tournament_unique_name: "10/14/17 Steel City Open Men"
        },
      ]

      sorted_results = Enum.sort_by(first_team_result.calculation_details, fn r -> r.tournament_unique_name end)
      sorted_expected = Enum.sort_by(expected_details, fn r -> r.tournament_unique_name end)

      assert sorted_results == sorted_expected

      # calculation_details = ["Marco Grangeiro, 11/04/17 Chicago Charities Men, 0.9, 34.125",
      #                        "Marco Grangeiro, 12/02/17 Duane L. Hayden Invitational Men, 0.9, 33.75",
      #                        "Marco Grangeiro, 11/18/17 Sound Shore Men, 0.9, 30.1875",
      #                        "Scott Kahler, 01/28/17 Boston Open Men, 0.9, 36.0",
      #                        "Scott Kahler, 01/14/17 Midwesterns Men, 0.9, 34.875",
      #                        "Scott Kahler, 10/14/17 Steel City Open Men, 0.9, 33.75"]

      # expect(result.first[:calculation_details]).to eq calculation_details

      # # This is the result we were experiencing temporarily
      # bad_calculation_details = ["Marco Grangeiro, 11/04/17 Chicago Charities Men, 0.9, 34.125",
      #                            "Marco Grangeiro, 12/02/17 Duane L. Hayden Invitational Men, 0.9, 33.75",
      #                            "Marco Grangeiro, 10/29/16 Atlantic Classic Men, 0.5, 30.375",
      #                            "Scott Kahler, 01/28/17 Boston Open Men, 0.9, 36.0",
      #                            "Scott Kahler, 01/14/17 Midwesterns Men, 0.9, 34.875",
      #                            "Scott Kahler, 10/14/17 Steel City Open Men, 0.9, 33.75"]

      # expect(result.first[:calculation_details]).not_to eq bad_calculation_details
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
