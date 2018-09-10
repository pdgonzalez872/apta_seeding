defmodule AptaSeeding.AcceptanceTest do
  use ExUnit.Case

  alias AptaSeeding.ETL.Extract

  describe "This is where we try things out" do
    test "main" do
      assert Extract.handle_tournaments_payload("hahaha html right") == 1

      result = []

      assert Enum.at(result, 0) == %{third_party_tournament_id: "416",
                                     tournament_date: "12/09/17",
                                     tournament_name: "Western New England Men",
                                     tournament_weight: "2.500"}

      assert Enum.at(result, -1) == %{third_party_tournament_id: "343",
                                      tournament_date: "12/10/16",
                                      tournament_name: "Detroit Invitational Men",
                                      tournament_weight: "1.375"}
    end
  end
end
