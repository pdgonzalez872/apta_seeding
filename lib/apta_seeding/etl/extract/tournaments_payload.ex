defmodule AptaSeeding.ETL.Extract.TournamentsPayload do

  def call() do
    :tournaments_payload

  end

  @doc """
  This function takes in a binary (html doc) and returns a data structure from it (map).
  """
  def parse_html(html) do
    :parse_html

  end
end
