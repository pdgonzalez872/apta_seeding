defmodule AptaSeeding.ETL do
  alias AptaSeeding.ETL.{SeasonData, TournamentData, DataDistributor}
  alias AptaSeeding.Data

  @doc """
  Get a bunch of the tournaments params, then create a list, and pass it to `.call`
  """
  # This is the only public method
  def call(season_params) do
    season_params
    |> Enum.each(fn season ->
      season
      |> handle_season_data()
      |> handle_tournament_data()
    end)

    distribute_data({:ok, "Nothing"})
    :ok
  end

  @spec handle_season_data(map()) :: tuple()
  def handle_season_data(season_params) do
    SeasonData.call(season_params)
  end

  @spec handle_tournament_data(tuple()) :: tuple()
  def handle_tournament_data({:ok, state}) do
    TournamentData.call(state)
  end

  @spec distribute_data(tuple()) :: tuple()
  def distribute_data({:ok, _state}) do
    DataDistributor.call(Data.list_tournaments())
  end
end
