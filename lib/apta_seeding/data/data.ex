defmodule AptaSeeding.Data do
  @moduledoc """
  The Data context.
  """

  import Ecto.Query, warn: false
  alias AptaSeeding.Repo

  alias AptaSeeding.Data.{Tournament, Player}

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
    query = from p in "players",
            where: p.name == ^player_name,
            select: p.id
    result = Repo.all(query)

    cond do
      Enum.count(result) == 0 ->
        create_player(%{name: player_name})
      true ->
        get_player!(Enum.at(result, 0))
    end
  end

  def process_tournament_and_tournament_results(%{tournament: tournament, results_structure: results_structure}) do
    results_structure
    |> Enum.map(fn r ->

      player_1 = find_or_create_player(r.player_1_name)
      player_2 = find_or_create_player(r.player_2_name)

      #team = find_or_create_team(r.team_name)

      # continue here: start modeling the database.
      # create the other modules, migrations
    end)
  end
end
