defmodule AptaSeeding.ETL do
  alias AptaSeeding.ETL.{SeasonData, TournamentData}

  @doc """
  Get a bunch of the tournaments params, then create a list, and pass it to `.call`
  """

  @spec handle_season_data(map()) ::tuple()
  def handle_season_data(season_params) do
    SeasonData.call(season_params)
  end

  @spec handle_tournament_data(tuple()) :: tuple()
  def handle_tournament_data({:ok, state}) do
    TournamentData.call(state)
  end
end
