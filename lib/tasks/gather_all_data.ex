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

    Logger.info("Creating Season Data")
    {:ok, season_data} = create_season_data_for_request()

    Logger.info("Starting Hackney")
    HTTPoison.start()

    AptaSeeding.ETL.handle_season_data(Enum.at(season_data.mens, 1))
    |> IO.inspect()

    Logger.info("Finish Task")
  end

  def create_season_data_for_request() do
    #
    # Men's
    #

    # Add url
    current_tournaments = %{
      "stype" => 0,
      "rtype" => 0,
      "sid" => 0,
      "rnum" => 0,
      "copt" => 0,
      "xid" => 0
    }

    # https://platformtennisonline.org/Ranking.aspx?stype=1&rtype=1&copt=3
    season_ending_in_2018 = %{
      "stype" => 1,
      "rtype" => 1,
      "sid" => 0,
      "rnum" => 0,
      "copt" => 3,
      "xid" => 0
    }

    # https://platformtennisonline.org/Ranking.aspx?stype=2&rtype=1&sid=10&copt=3
    season_ending_in_2017 = %{
      "stype" => 2,
      "rtype" => 1,
      "sid" => 10,
      "rnum" => 0,
      "copt" => 3,
      "xid" => 0
    }

    # https://platformtennisonline.org/Ranking.aspx?stype=2&rtype=1&sid=9&copt=3
    season_ending_in_2016 = %{
      "stype" => 2,
      "rtype" => 1,
      "sid" => 9,
      "rnum" => 0,
      "copt" => 3,
      "xid" => 0
    }

    # https://platformtennisonline.org/Ranking.aspx?stype=2&rtype=1&sid=8&copt=3
    season_ending_in_2015 = %{
      "stype" => 2,
      "rtype" => 1,
      "sid" => 8,
      "rnum" => 0,
      "copt" => 3,
      "xid" => 0
    }

    mens_tournament_collection = [
      current_tournaments,
      season_ending_in_2015,
      season_ending_in_2016,
      season_ending_in_2017,
      season_ending_in_2018
    ]

    # TODO
    # When ready, port women as well
    {:ok, %{mens: mens_tournament_collection, womens: []}}
  end
end
