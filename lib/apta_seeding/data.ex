defmodule AptaSeeding.Data do
  @moduledoc """
  The Data context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias AptaSeeding.Repo

  alias AptaSeeding.Data.{Tournament, Player, Team, IndividualResult, TeamResult}

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

  def find_tournaments_by_name(tournament_name) do
    query =
      from(
        t in "tournaments",
        where: t.name == ^tournament_name,
        select: t.id
      )

    Repo.all(query)
    |> Enum.map(fn tournament_id -> get_tournament!(tournament_id) end)
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
        {:ok, create_player(%{name: player_name})}

      true ->
        {:ok, get_player!(Enum.at(result, 0))}
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

  def find_or_create_team(%{
        team_name: team_name,
        player_1_id: player_1_id,
        player_2_id: player_2_id
      }) do
    query =
      from(
        t in "teams",
        where: t.name == ^team_name,
        select: t.id
      )

    result = Repo.all(query)

    cond do
      Enum.count(result) == 0 ->
        {:ok, create_team(%{name: team_name, player_1_id: player_1_id, player_2_id: player_2_id})}

      true ->
        {:ok, get_team!(Enum.at(result, 0))}
    end
  end

  def find_or_create_team(team_name) do
    query =
      from(
        t in "teams",
        where: t.name == ^team_name,
        select: t.id
      )

    result = Repo.all(query)

    cond do
      Enum.count(result) == 0 ->
        {:ok, create_team(%{name: team_name})}

      true ->
        {:ok, get_team!(Enum.at(result, 0))}
    end
  end

  #
  # IndividualResult
  #

  def individual_results_count() do
    IndividualResult
    |> Repo.all()
    |> Enum.count()
  end

  def create_individual_result(
        %{player_id: _player_id, tournament_id: _tournament_id, points: _points} = attrs
      ) do
    %IndividualResult{}
    |> IndividualResult.changeset(attrs)
    |> Repo.insert!()
  end

  #
  # TeamResult
  #

  def team_results_count() do
    TeamResult
    |> Repo.all()
    |> Enum.count()
  end

  def create_team_result(
        %{team_id: _team_id, tournament_id: _tournament_id, points: _points} = attrs
      ) do
    %TeamResult{}
    |> TeamResult.changeset(attrs)
    |> Repo.insert!()
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
    # require IEx; IEx.pry

    results_structure
    |> Enum.map(fn r ->
      {:ok, player_1} = find_or_create_player(r.player_1_name)
      {:ok, player_2} = find_or_create_player(r.player_2_name)

      {:ok, team} =
        find_or_create_team(%{
          team_name: r.team_name,
          player_1_id: player_1.id,
          player_2_id: player_2.id
        })

      create_individual_result(%{
        player_id: player_1.id,
        tournament_id: tournament.id,
        points: r.individual_points
      })

      create_individual_result(%{
        player_id: player_2.id,
        tournament_id: tournament.id,
        points: r.individual_points
      })

      create_team_result(%{team_id: team.id, tournament_id: tournament.id, points: r.team_points})

      {:ok, _tournament} = update_tournament(tournament, %{results_have_been_processed: true})
    end)

    {:ok, "Tournament was processed"}
  end

  def process_tournament_and_tournament_results(%{
        tournament: tournament,
        results_structure: _results_structure,
        tournament_should_be_processed: true
      }) do
    message = "Tournament was already processed -> #{tournament.name_and_date_unique_name}"
    Logger.info(message)
    {:ok, message}
  end

  #
  # Reporter
  #

  def preload_results({:ok, %Player{} = player}) do
    player
    |> Repo.preload(:individual_results)
  end

  def preload_results({:ok, %Team{} = team}) do
    team
    |> Repo.preload(:team_results)
  end

  def preload_tournament(%IndividualResult{} = individual_result) do
    individual_result
    |> Repo.preload(:tournament)
  end

  def preload_tournament(%TeamResult{} = team_result) do
    team_result
    |> Repo.preload([:tournament, :team])
  end

  def preload_player(%IndividualResult{} = individual_result) do
    individual_result
    |> Repo.preload(:player)
  end

  def get_teams_for_player(%Player{} = player) do
    query =
      from(
        t in "teams",
        where: t.player_1_id == ^player.id,
        or_where: t.player_2_id == ^player.id,
        select: t.id
      )

    query
    |> Repo.all()
    |> Enum.map(fn t -> get_team!(t) end)
    |> Enum.map(fn team -> Repo.preload(team, :team_results) end)
  end

  def get_team_results_for_teams(teams) do
    teams
    |> Enum.reduce([], fn team, team_acc ->
      team_acc ++ [team.team_results]
    end)
    |> List.flatten()
  end
end
