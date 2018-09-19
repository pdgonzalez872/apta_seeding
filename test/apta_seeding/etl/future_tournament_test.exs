defmodule AptaSeeding.ETL.FutureTournamentTest do
  use ExUnit.Case

  alias AptaSeeding.ETL.FutureTournament

  describe "create_url/1" do
    test "create_season_url/1 returns the correct url - Philly 2018-2019" do

      result = %{eid: 228, tid: 496}
      |> FutureTournament.create_url()

      expected = "https://platformtennisonline.org/TournamentPlayer.aspx?eid=228&tid=496"

      assert result == expected
    end
  end

  @tag :skip
  describe "make_request/1" do
    test "makes the request to fetch the data - live request" do

      {:ok, response_body} = %{eid: 228, tid: 496}
                             |> FutureTournament.create_url()
                             |> FutureTournament.make_request()

                             require IEx; IEx.pry

      assert 1 == response_body
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

      assert Enum.at(result.team_data, 0) == {"Luke Alicknavitch", "Darren Schwandt", "Luke Alicknavitch - Darren Schwandt"}
    end
  end
end
