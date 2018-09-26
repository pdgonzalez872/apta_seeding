defmodule AptaSeeding.SeedingManager do
  @moduledoc """
  This module is responsible for calculating the seeds. It follows a procedure
  that is somewhere online on the APTA website.  The gist of it is below, was
  sent via email by Eric Miller.

  The below is almost correct. They just didn't have the concept of "season"
  before. It turns out it is not 12 months, but instead, a "season".

  === Tournament Weighting Procedure (sent via email by Eric Miller) ===

  Does team have 3 or more results together in prior 12 month period?

  Yes – Use the average of the best 3 results

  No – Do both players have at least
  3 individual results in the prior 24 month period?

    Yes – Use 100% of the points earned together, plus 90% of the most points
    earned with another partner in the prior 12 months, plus 50% of the most
    points earned with any partner in the past 24 months to come up with 3
    results for each player.  Calculate the average based on the 3 results used.

    No – Use as many results as are available in the prior 24 months using 100%
    of the points earned together, plus 90% of the most points earned with
    another partner in the prior 12 months, plus 50% of the most points earned
    with any partner in the past 24 months.  Calculate the average using 3 as the
    dominator even though less than 3 results were used to determine the total.

  Sort all teams by average descending.

  Take the total average of the top 24 teams in the tournament.

  Double that total.

  Apply that number to the chart below to determine the tournament strength.
  (will show this later, it is a large table)
  ===
  """

  alias AptaSeeding.Data
  alias AptaSeeding.SeedingManager.{SeasonManager, SeedingReporter, TournamentPicker}

  def call({:ok, state}) do
    {:ok, state}
    |> get_players_and_teams()
    |> analyse_each_team()
    |> sort_by_results()
  end

  def sort_by_results({:ok, state}) do
    sorted =
      state.team_data_objects
      |> Enum.sort_by(fn e -> e end)
      |> Enum.sort(&(Decimal.cmp(&1.total_seeding_points, &2.total_seeding_points) != :gt))
      |> Enum.reverse()

    state =
      state
      |> Map.put(:sorted_seeding, sorted)

    {:ok, state}
  end

  def get_players_and_teams({:ok, state}) do
    result =
      state.team_data
      |> Enum.map(fn td ->
        {p1_name, p2_name, team_name} = td

        p1 =
          p1_name
          |> Data.find_or_create_player()
          |> Data.preload_results()

        p2 =
          p2_name
          |> Data.find_or_create_player()
          |> Data.preload_results()

        team =
          %{team_name: team_name, player_1_id: p1.id, player_2_id: p2.id}
          |> Data.find_or_create_team()
          |> Data.preload_results()

        %{player_1: p1, player_2: p2, team: team}
      end)

    state =
      state
      |> Map.put(:team_data_objects, result)

    {:ok, state}
  end

  def analyse_each_team({:ok, state}) do
    team_data_objects =
      state.team_data_objects
      |> Enum.map(fn tdo ->
      handle_seeding_criteria(tdo, get_seeding_criteria(tdo))
      end)

    state =
      state
      |> Map.put(:team_data_objects, team_data_objects)

    {:ok, state}
  end

  def handle_seeding_criteria(tdo, :team_has_played_3_tournaments = seeding_criteria) do
    team_results_details = TournamentPicker.get_team_points(tdo, seeding_criteria)

    tdo
    |> Map.put(:seeding_criteria, seeding_criteria)
    |> Map.put(:team_points, team_results_details.total_points)
    |> Map.put(:total_seeding_points, team_results_details.total_points)
    |> Map.put(
      :calculation_details,
      create_calculations_explanations([team_results_details], seeding_criteria)
    )
  end

  def handle_seeding_criteria(
        tdo,
        :team_has_played_2_tournaments_1_best_individual = seeding_criteria
      ) do
    team_results_details = TournamentPicker.get_team_points(tdo, seeding_criteria)

    individual_results_details = TournamentPicker.get_individual_points(tdo, seeding_criteria)

    tdo
    |> Map.put(:seeding_criteria, seeding_criteria)
    |> Map.put(:team_points, team_results_details.total_points)
    |> Map.put(
      :total_seeding_points,
      Decimal.add(
        team_results_details.total_points,
        calculate_total_points(individual_results_details)
      )
    )
    |> Map.put(
      :calculation_details,
      create_calculations_explanations(
        [team_results_details] ++ individual_results_details,
        seeding_criteria
      )
    )
  end

  def handle_seeding_criteria(
        tdo,
        :team_has_played_1_tournament_2_best_individual = seeding_criteria
      ) do
    team_results_details = TournamentPicker.get_team_points(tdo, seeding_criteria)

    individual_results_details = TournamentPicker.get_individual_points(tdo, seeding_criteria)

    tdo
    |> Map.put(:seeding_criteria, seeding_criteria)
    |> Map.put(:team_points, team_results_details.total_points)
    |> Map.put(
      :total_seeding_points,
      Decimal.add(
        team_results_details.total_points,
        calculate_total_points(individual_results_details)
      )
    )
    |> Map.put(
      :calculation_details,
      create_calculations_explanations(
        [team_results_details] ++ individual_results_details,
        seeding_criteria
      )
    )
  end

  def handle_seeding_criteria(
        tdo,
        :team_has_not_played_together_3_best_individual = seeding_criteria
      ) do
    individual_results_details = TournamentPicker.get_individual_points(tdo, seeding_criteria)

    tdo
    |> Map.put(:seeding_criteria, seeding_criteria)
    |> Map.put(:team_points, Decimal.new("0"))
    |> Map.put(:total_seeding_points, calculate_total_points(individual_results_details))
    |> Map.put(
      :calculation_details,
      create_calculations_explanations(individual_results_details, seeding_criteria)
    )
  end

  @doc """
  Returns the correct seeding criteria for a team
  """
  def get_seeding_criteria(state) do
    cond do
      current_tournaments_played(state) >= 3 ->
        :team_has_played_3_tournaments

      current_tournaments_played(state) == 2 ->
        :team_has_played_2_tournaments_1_best_individual

      current_tournaments_played(state) == 1 ->
        :team_has_played_1_tournament_2_best_individual

      current_tournaments_played(state) == 0 ->
        :team_has_not_played_together_3_best_individual

      true ->
        raise "Error in seeding criteria for #{state.team.name}"
    end
  end

  def current_tournaments_played(state) do
    state.team.team_results
    |> Enum.filter(fn tr ->
      tr = Data.preload_tournament(tr)
      tournament = tr.tournament

      target_tournaments =
        Enum.filter(Data.list_tournaments(), fn t -> t.name == tr.tournament.name end)

      result = is_current_tournament(tournament, target_tournaments)
    end)
    |> Enum.count()
  end

  def is_current_tournament(tournament, all_tournaments) do
    SeasonManager.is_current_tournament(tournament, all_tournaments)
  end

  #
  # Calculation helpers
  #

  def calculate_total_points(results_details) do
    results_details
    |> Enum.reduce(Decimal.new("0"), fn el, acc ->
      Decimal.add(acc, el.total_points)
    end)
  end

  #
  # Calculation details helpers
  #

  def create_calculations_explanations(results, _seeding_criteria) do
    results
    |> Enum.reduce([], fn r, acc -> acc ++ r.details end)
    |> Enum.map(fn r -> create_details(r) end)
  end

  def create_details(%{team: team} = attrs) do
    attrs
    |> Map.delete(:team)
    |> Map.put(:direct_object, team)
  end

  def create_details(%{player: player} = attrs) do
    attrs
    |> Map.delete(:player)
    |> Map.put(:direct_object, player)
  end
end
