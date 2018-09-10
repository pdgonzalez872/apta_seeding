defmodule AptaSeeding.ETL do

  alias AptaSeeding.ETL.{SeasonData}

  @doc """
  Get a bunch of the tournaments params, then create a list, and pass it to `.call`

  """

  def handle_season_data(season_params) do
    SeasonData.call(season_params)
  end
end
