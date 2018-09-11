defmodule AptaSeeding.ETL.TournamentData do
  @moduledoc """
  This module takes care of dealing with tournament data we retrieve from
  a season. The general

  This module talks to the database to check if we already have data for
  a given tournament.

  If so, we move on to the next tournament.

  If not, we deal with the data that
  comes from making a request to the external api.

  That data has a list of teams and points they got at a specific tournament.

  From here, we build our data model:
  - Player
  - Team
  - Player Result (points, half of a team result)
  - Team Result (points)
  """

  @doc """
  Entry point for this api
  """
  def call(state) do
    {:ok, state}
    |> init()
    |> extract()
    |> transform()
    |> load()
  end

  @doc """
  We create the data we are interested in. We discard unnecessary data by creating a new map
  and using it from now on.
  """
  def init({:ok, state}) do
    state =
      state
      |> Map.put(:step, :tournament_init)

    {:ok, %{step: :tournament_init, params: state.params, tournaments: state.tournaments}}
  end

  def extract({:ok, state}) do

    # make the requests for each tournament here if we don't have it already in the db
    # tournament name and tournament date

    {:ok, tournaments_data} =
      state.tournaments
      |> Enum.map(fn tournament ->
        # check if tournament


        result = tournament
        |> create_tournament_json_payload()

        require IEx; IEx.pry

        # |> make_request()

        # else
        # :already_in_db
      end)


    state =
      state
      |> Map.put(:step, :tournament_extract)
      |> Map.put(:tournaments_data, tournaments_data)

    {:ok, state}
  end

  def transform({:ok, state}) do
    # create the data structure
    # - Player
    # - Team
    # - Player Result (points, half of a team result)
    # - Team Result (points)

    state =
      state
      |> Map.put(:step, :tournament_transform)

    {:ok, state}
  end

  def load({:ok, state}) do
    # This is where we persist
    # Or, we pass through here. Hand the main persisting to something else

    state =
      state
      |> Map.put(:step, :tournament_load)

    {:ok, state}
  end

  @spec create_tournament_json_payload(map()) :: binary()
  def create_tournament_json_payload(tournament) do

  end

end
