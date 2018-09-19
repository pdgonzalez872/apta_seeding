defmodule Mix.Tasks.GatherAllData do
  use Mix.Task
  require Logger
  require IEx

  alias AptaSeeding.ETL

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

    # season_data.mens
    # |> Enum.each(fn season ->
    #   season
    #   |> ETL.handle_season_data()
    #   |> ETL.handle_tournament_data()
    # end)

    ETL.distribute_data({:ok, "Nothing"})

    # The above should only be a call to ETL.call() or ETL.process_season_data()
    # require IEx
    # IEx.pry()

    Logger.info("Finish Task")
  end

  def create_season_data_for_request() do
    #
    # Men's
    #

    # https://platformtennisonline.org/Ranking.aspx?stype=1&rtype=1&copt=3
    current_tournaments = %{copt: 3, rnum: 0, rtype: 1, sid: 0, stype: 1, xid: 0}

    # https://platformtennisonline.org/Ranking.aspx?stype=2&rtype=1&sid=13&copt=3
    season_ending_in_2018 = %{copt: 3, rnum: 0, rtype: 1, sid: 13, stype: 2, xid: 0}

    # https://platformtennisonline.org/Ranking.aspx?stype=2&rtype=1&sid=10&copt=3
    season_ending_in_2017 = %{copt: 3, rnum: 0, rtype: 1, sid: 10, stype: 2, xid: 0}

    # https://platformtennisonline.org/Ranking.aspx?stype=2&rtype=1&sid=9&copt=3
    season_ending_in_2016 = %{copt: 3, rnum: 0, rtype: 1, sid: 9, stype: 2, xid: 0}

    # https://platformtennisonline.org/Ranking.aspx?stype=2&rtype=1&sid=8&copt=3
    season_ending_in_2015 = %{copt: 3, rnum: 0, rtype: 1, sid: 8, stype: 2, xid: 0}

    mens_tournament_collection = [
      season_ending_in_2015,
      season_ending_in_2016,
      season_ending_in_2017,
      season_ending_in_2018,
      current_tournaments
    ]

    # TODO
    # When ready, port women as well
    {:ok, %{mens: mens_tournament_collection, womens: []}}
  end
end
