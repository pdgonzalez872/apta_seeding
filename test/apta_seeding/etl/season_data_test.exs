defmodule AptaSeeding.ETL.SeasonDataTest do
  use ExUnit.Case

  alias AptaSeeding.ETL.SeasonData

  describe "create_season_url/1" do
    test "returns the correct url 2015" do
      result = SeasonData.create_season_url(%{"copt" => 3, "rnum" => 0, "rtype" => 1, "sid" => 8, "stype" => 2, "xid" => 0})

      expected = "https://platformtennisonline.org/Ranking.aspx?stype=2&rtype=1&sid=8&copt=3"

      assert result == expected
    end

    test "returns the correct url 2016" do
      result = SeasonData.create_season_url(%{
                                              "stype" => 2,
                                              "rtype" => 1,
                                              "sid" => 9,
                                              "rnum" => 0,
                                              "copt" => 3,
                                              "xid" => 0
                                            })

      expected = "https://platformtennisonline.org/Ranking.aspx?stype=2&rtype=1&sid=9&copt=3"

      assert result == expected
    end
  end
end
