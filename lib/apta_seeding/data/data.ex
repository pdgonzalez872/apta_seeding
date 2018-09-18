defmodule AptaSeeding.Data do
  @moduledoc """
  The Data context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias AptaSeeding.Repo

  alias AptaSeeding.Data.{Tournament, Player, Team}

  @doc """
  Returns the list of tournaments.

  ## Examples

      iex> list_tournaments()
      [%Tournament{}, ...]

  """
  def list_tournaments do
    Repo.all(Tournament)
  end

  @doc """
  Gets a single tournament.

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

      iex> get_tournament!(123)
      %Tournament{}

      iex> get_tournament!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tournament!(id), do: Repo.get!(Tournament, id)

  @doc """
  Creates a tournament.

  ## Examples

      iex> create_tournament(%{field: value})
      {:ok, %Tournament{}}

      iex> create_tournament(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tournament(attrs \\ %{}) do
    %Tournament{}
    |> Tournament.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tournament.

  ## Examples

      iex> update_tournament(tournament, %{field: new_value})
      {:ok, %Tournament{}}

      iex> update_tournament(tournament, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tournament(%Tournament{} = tournament, attrs) do
    tournament
    |> Tournament.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Tournament.

  ## Examples

      iex> delete_tournament(tournament)
      {:ok, %Tournament{}}

      iex> delete_tournament(tournament)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tournament(%Tournament{} = tournament) do
    Repo.delete(tournament)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tournament changes.

  ## Examples

      iex> change_tournament(tournament)
      %Ecto.Changeset{source: %Tournament{}}

  """
  def change_tournament(%Tournament{} = tournament) do
    Tournament.changeset(tournament, %{})
  end

  #
  # Player
  #

  def list_players() do
    Repo.all(Player)
  end

  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert!()
  end

  def get_player!(id), do: Repo.get!(Player, id)

  def find_or_create_player(player_name) do
    query =
      from(
        p in "players",
        where: p.name == ^player_name,
        select: p.id
      )

    result = Repo.all(query)

    cond do
      Enum.count(result) == 0 ->
        create_player(%{name: player_name})

      true ->
        get_player!(Enum.at(result, 0))
    end
  end

  #
  # Team
  #

  def list_teams() do
    Repo.all(Team)
  end

  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert!()
  end

  def get_team!(id), do: Repo.get!(Team, id)

  def find_or_create_team(%{team_name: team_name, player_1_id: player_1_id, player_2_id: player_2_id}) do
    query =
      from(
        t in "teams",
        where: t.name == ^team_name,
        select: t.id
      )

    result = Repo.all(query)

    cond do
      Enum.count(result) == 0 ->
        create_team(%{name: team_name, player_1_id: player_1_id, player_2_id: player_2_id})

      true ->
        get_team!(Enum.at(result, 0))
    end
  end

  #
  # IndividualResult
  #

  def create_individual_result(%{player: player, tournament: tournament}) do
    nil
  end

  #
  # Creation logic
  #

  @doc """
  We can trust the names are already sanitized, this happens in DataDistributor
  """
  def process_tournament_and_tournament_results(%{
        tournament: tournament,
        results_structure: results_structure,
        tournament_should_be_processed: false
      }) do

    Logger.info("About to process tournament -> #{tournament.name_and_date_unique_name}")
    #require IEx; IEx.pry

    results_structure
    |> Enum.map(fn r ->

      player_1 = find_or_create_player(r.player_1_name)
      player_2 = find_or_create_player(r.player_2_name)

      team = find_or_create_team(%{team_name: r.team_name, player_1_id: player_1.id, player_2_id: player_2.id})

      # individual_results

      # team_result

      # update tournament to results_have_been_processed = true

    end)
    {:ok, "Tournament was processed"}
  end


  def process_tournament_and_tournament_results(%{
        tournament: tournament,
        results_structure: results_structure,
        tournament_should_be_processed: true
      }) do
    message = "Tournament was already processed -> #{tournament.name_and_date_unique_name}"
    Logger.info(message)
    {:ok, message}
  end
end
