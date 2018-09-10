defmodule AptaSeeding.ETL.Extract do
  alias AptaSeeding.ETL.Extract.{TournamentsPayload}

  @doc """
  This is responsible for handling the payload response resulting
  from the request we make

  """
  def handle_tournaments_payload(tournaments_payload) do
    TournamentsPayload.call(tournaments_payload)
  end
end
