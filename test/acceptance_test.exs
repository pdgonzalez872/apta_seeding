defmodule AptaSeeding.AcceptanceTest do
  use ExUnit.Case

  alias AptaSeeding.ETL

  describe "This is where we try things out" do
    test "playground" do

      {:ok, result} = ETL.handle_season_data([%{"stype" => 2,"rtype" => 1,"sid" => 10,"rnum" => 0,"copt" => 3,"xid" => 0}])

      assert result == 1

      assert Enum.at(result.tournaments, 0) == %{third_party_tournament_id: "416",
                                                 tournament_date: "12/09/17",
                                                 tournament_name: "Western New England Men",
                                                 tournament_weight: "2.500"}

      assert Enum.at(result.tournaments, -1) == %{third_party_tournament_id: "343",
                                                  tournament_date: "12/10/16",
                                                  tournament_name: "Detroit Invitational Men",
                                                  tournament_weight: "1.375"}
    end
  end
end
