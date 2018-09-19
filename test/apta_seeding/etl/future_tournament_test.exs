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
end
