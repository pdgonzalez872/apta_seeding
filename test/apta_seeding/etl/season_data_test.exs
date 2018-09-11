defmodule AptaSeeding.ETL.SeasonDataTest do
  use ExUnit.Case

  alias AptaSeeding.ETL.SeasonData

  describe "SeasonData" do
    test "create_season_url/1 returns the correct url 2015" do
      result =
        SeasonData.create_season_url(%{
          "copt" => 3,
          "rnum" => 0,
          "rtype" => 1,
          "sid" => 8,
          "stype" => 2,
          "xid" => 0
        })

      expected = "https://platformtennisonline.org/Ranking.aspx?stype=2&rtype=1&sid=8&copt=3"

      assert result == expected
    end

    test "create_season_url/1 returns the correct url 2016" do
      result =
        SeasonData.create_season_url(%{
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

  test "parse_html/1 parses html correctly" do
    file =
      [
        System.cwd(),
        "test",
        "apta_seeding",
        "etl",
        "static_files_for_test",
        "season_2017_2018.html"
      ]
      |> Path.join()
      |> File.read!()

    result = SeasonData.parse_html(file)

    assert Enum.at(result, 0) == %{tournament_date: "03/09/18", tournament_name: "APTA Men's Nationals", xid: "460"}
    assert Enum.at(result, -1) == %{tournament_date: "10/07/17", tournament_name: "Patterson Club Men", xid: "396"}
  end
end
