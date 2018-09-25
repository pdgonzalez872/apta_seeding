defmodule AptaSeeding.SeedingManager.TournamentPicker do

  alias AptaSeeding.Data
  alias AptaSeeding.SeedingManager.{SeasonManager, SeedingReporter, TournamentPicker}

  #
  # Get Team Points
  #

  def get_team_points(team_data_object, _seeding_criteria, tournaments_to_take) do
    team_results_objects =
      team_data_object.team.team_results
      |> Enum.sort_by(fn tr ->
        tr =
          tr
          |> Data.preload_tournament()

        d = tr.tournament.date
        {d.year, d.month, d.day}
      end)
      |> Enum.map(fn tr -> Data.preload_tournament(tr) end)
      |> Enum.reverse()
      |> Enum.take(tournaments_to_take)
      |> Enum.map(fn tr ->
        target_tournaments =
          Enum.filter(Data.list_tournaments(), fn t -> t.name == tr.tournament.name end)

        result = get_tournament_multiplier(tr.tournament, target_tournaments, :team)

        %{
          tournament_unique_name: tr.tournament.name_and_date_unique_name,
          team: tr.team.name,
          multiplier: result.multiplier,
          points: tr.points,
          total_points: Decimal.mult(result.multiplier, tr.points)
        }
      end)

    total_points = calculate_total_points(team_results_objects)
    %{total_points: total_points, details: team_results_objects}
  end

  def get_team_points(team_data_object, :team_has_played_3_tournaments = seeding_criteria) do
    get_team_points(team_data_object, seeding_criteria, 3)
  end

  def get_team_points(
        team_data_object,
        :team_has_played_2_tournaments_1_best_individual = seeding_criteria
      ) do
    get_team_points(team_data_object, seeding_criteria, 2)
  end

  def get_team_points(
        team_data_object,
        :team_has_played_1_tournament_2_best_individual = seeding_criteria
      ) do
    get_team_points(team_data_object, seeding_criteria, 1)
  end

  #
  # Get Individual Points
  #

  def get_individual_points(
        team_data_object,
        :team_has_played_2_tournaments_1_best_individual = seeding_criteria
      ) do
    get_individual_points(team_data_object, seeding_criteria, 1)
  end

  def get_individual_points(
        team_data_object,
        :team_has_played_1_tournament_2_best_individual = seeding_criteria
      ) do
    get_individual_points(team_data_object, seeding_criteria, 2)
  end

  def get_individual_points(
        team_data_object,
        :team_has_not_played_together_3_best_individual = seeding_criteria
      ) do
    get_individual_points(team_data_object, seeding_criteria, 3)
  end

  @doc """
  This is where the logic for getting individual results goes
  """
  def get_individual_points(team_data_object, _seeding_criteria, tournaments_to_take) do
    player_1_results =
      get_highest_individual_results_for_player(team_data_object.player_1, tournaments_to_take)

    player_2_results =
      get_highest_individual_results_for_player(team_data_object.player_2, tournaments_to_take)

    [player_1_results, player_2_results]
    |> Enum.sort_by(fn r -> r.total_points end)
    |> Enum.reverse()
  end

  def get_highest_individual_results_for_player(player, tournaments_to_take) do
    team_results_objects =
      player.individual_results
      |> Enum.sort_by(fn id ->
        id =
          id
          |> Data.preload_tournament()

        d = id.tournament.date
        {d.year, d.month, d.day}
      end)
      |> Enum.map(fn id ->
        id
        |> Data.preload_tournament()
        |> Data.preload_player()
      end)
      |> Enum.reverse()
      |> Enum.map(fn id ->
        create_result_data_structure(id, :individual)
      end)
      |> Enum.take(tournaments_to_take)

    total_points = calculate_total_points(team_results_objects)

    %{total_points: total_points, details: team_results_objects}
  end

  def create_result_data_structure(tr, result_type) do
    target_tournaments =
      Enum.filter(Data.list_tournaments(), fn t -> t.name == tr.tournament.name end)

    # get the multiplier for a tournament
    result = get_tournament_multiplier(tr.tournament, target_tournaments, result_type)

    %{
      tournament_unique_name: tr.tournament.name_and_date_unique_name,
      player: tr.player.name,
      multiplier: result.multiplier,
      points: tr.points,
      total_points: Decimal.mult(result.multiplier, tr.points),
    }
  end

  def calculate_total_points(results) do
    results
    |> Enum.reduce(0, fn obj, acc ->
      Decimal.add(acc, obj.total_points)
    end)
  end

  #
  # Multiplier
  #

  @doc """
  We get the multiplier for each tournament.
  The trick is to know what a "current tournament" is, which not even the APTA seems
  to know exactly, at least not how they state on their rules. From our side, a
  current tournament is a tournament that has not been played in the current season.

  Ex:
  We are currently in Sep 2018.
    Charities 2017 was played in Nov 2017. This is a "current tournament", should be 100% of points, multiplier 1
      (Note that Charities 2018 will happen in Nov 2018, so not yet in this example.)
    Charities 2016 was played in Nov 2016. This is not a current tournament, should be 90%, because it was 1 season ago. multiplier 0.9
    Charities 2015 was played in Nov 2015. This is not a current tournament, should be 50%, because it was 2 seasons ago. multiplier 0.5
  """
  def get_tournament_multiplier(tournament, all_tournaments, type) do
      result = create_tournament_multiplier_matrix(tournament, all_tournaments, type)

        shim = result
        |> Enum.find(fn {t, _multiplier} ->
           t.name_and_date_unique_name == tournament.name_and_date_unique_name
         end)

     {t, multiplier} =
       case shim do
         nil ->
           require IEx; IEx.pry

         {t, multiplier} ->
           {t, multiplier}
       end

    %{tournament: t, multiplier: multiplier}
  end

  def create_tournament_multiplier_matrix(tournament, all_tournaments, type) do
    SeasonManager.create_tournament_multiplier_matrix(tournament, all_tournaments, type)
  end

  #
  # Other
  #

end
