defmodule AptaSeeding.ETL.TournamentDataTest do
  use ExUnit.Case

  alias AptaSeeding.ETL.TournamentData

  describe "TournamentData" do
    test "create_tournament_json_payload/1 creates the json payload correctly" do
      input = %{
        tournament_date: "03/06/15",
        tournament_name: "APTA Men's Nationals",
        xid: "214",
        copt: 3,
        rnum: 0,
        rtype: 1,
        sid: 8,
        stype: 2,
      }

      result = TournamentData.create_tournament_json_payload(input)

      assert result == "{'stype':2,'rtype':1,'sid':8,'rnum':0,'copt':3,'xid':214}"
    end
  end
end
