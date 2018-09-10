defmodule Mix.Tasks.GatherAllData do
  use Mix.Task
  require Logger
  require IEx

  @moduledoc """
  This is the task to be run on a daily/weekly basis

  To run this:
  $ `mix gather_all_data`
  """

  def run(_args) do
    Logger.info("Starting Task")

    Application.ensure_all_started(:apta_seeding)

    Logger.info("Starting Hackney")

    #
    # Men's
    #

    # https://platformtennisonline.org/Ranking.aspx?stype=1&rtype=1&copt=3
    current_tournaments =   {"stype" => 1, "rtype" => 1, "sid" => 0, "rnum" => 0, "copt" => 3, "xid" => 0}

    # https://platformtennisonline.org/Ranking.aspx?stype=2&rtype=1&sid=10&copt=3
    season_ending_in_2017 = {"stype" => 2, "rtype" => 1, "sid" => 10,"rnum" => 0, "copt" => 3, "xid" => 0}

    # https://platformtennisonline.org/Ranking.aspx?stype=2&rtype=1&sid=9&copt=3
    season_ending_in_2016 = {"stype" => 2, "rtype" => 1, "sid" => 9, "rnum" => 0, "copt" => 3, "xid" => 0}

    # https://platformtennisonline.org/Ranking.aspx?stype=2&rtype=1&sid=8&copt=3
    season_ending_in_2015 = {"stype" => 2, "rtype" => 1, "sid" => 8, "rnum" => 0, "copt" => 3, "xid" => 0}

    mens_tournament_collection = [current_tournaments, season_ending_in_2015, season_ending_in_2016, season_ending_in_2017]


    AptaSeeding.ETL.handle_season_data([%{"stype" => 2,"rtype" => 1,"sid" => 10,"rnum" => 0,"copt" => 3,"xid" => 0}])
    |> IO.inspect()

    Logger.info("Finish Task")
  end
end
