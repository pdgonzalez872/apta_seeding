defmodule AptaSeeding.ETL do

  alias AptaSeeding.ETL.{TournamentData}

  @doc """
  Get a bunch of the tournaments params, then create a list, and pass it to `.call`

  """
  def call() do

  end


  def handle_multiple_tournaments_context(tournaments_params) do
    TournamentData.call(tournaments_params)
  end

  def handle_single_tournament_context(single_tournament_params) do

  end
end
