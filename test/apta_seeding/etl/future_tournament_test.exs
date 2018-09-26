defmodule AptaSeeding.ETL.FutureTournamentTest do
  use ExUnit.Case

  alias AptaSeeding.ETL.FutureTournament

  describe "create_url/1" do
    test "create_season_url/1 returns the correct url - Philly 2018-2019" do
      result =
        %{eid: 228, tid: 496}
        |> FutureTournament.create_url()

      expected = "https://platformtennisonline.org/TournamentPlayer.aspx?eid=228&tid=496"

      assert result == expected
    end
  end

  @tag :integration
  describe "extract/1" do
    test "extract step works as expected with a live request" do
      {:ok, html_response} =
        %{eid: 228, tid: 496}
        |> FutureTournament.extract()

      assert String.contains?(html_response, "Philadelphia Open") == true
      assert String.contains?(html_response, "Friday, Oct 12 - Sunday, Oct 14, 2018") == true
    end
  end

  describe "transform/1" do
    test "transforms the request response in something useful to us - Philly 2018-2019" do
      html =
        [
          System.cwd(),
          "test",
          "apta_seeding",
          "etl",
          "static_files_for_test",
          "future_tournament_philly_2018_2019.html"
        ]
        |> Path.join()
        |> File.read!()

      {:ok, result} = FutureTournament.transform({:ok, html})

      assert Enum.at(result.team_data, 0) ==
               {"Luke Alicknavitch", "Darren Schwandt", "Luke Alicknavitch - Darren Schwandt"}

      assert result.tournament_name == "Philadelphia Open"
      # "Friday, Oct 12 - Sunday, Oct 14, 2018"
      assert result.tournament_date == ~D[2018-10-12]
    end
  end

  describe "create_date/1" do
    test "creates date correctly - normal two day tournament" do
      result = FutureTournament.create_date("Friday, Oct 12 - Sunday, Oct 14, 2018")

      assert result == ~D[2018-10-12]
    end

    test "creates date correctly - one day tournament - 1" do
      result = FutureTournament.create_date("Saturday, December 9, 2017")

      assert result == ~D[2017-12-09]
    end

    test "creates date correctly - one day tournament - 2" do
      result = FutureTournament.create_date("Thursday, March 22, 2018")

      assert result == ~D[2018-03-22]
    end
  end
end
