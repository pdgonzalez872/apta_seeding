defmodule AptaSeeding.SeedingManager.SeasonManager do
  @moduledoc"""
  This module is responsible for
  - dealing with seasons
  - getting the right multipliers for tournaments, based on seasons
  """

  alias AptaSeeding.Data

  def intervals_and_multipliers() do
    [
      %{
        interval: Timex.Interval.new(from: ~D[2018-10-01], until: [months: 7]),
        multiplier: Decimal.new("1.0")
      },
      %{
        interval: Timex.Interval.new(from: ~D[2017-10-01], until: [months: 7]),
        multiplier: Decimal.new("0.9")
      },
      %{
        interval: Timex.Interval.new(from: ~D[2016-10-01], until: [months: 7]),
        multiplier: Decimal.new("0.5")
      },
      %{
        interval: Timex.Interval.new(from: ~D[2015-10-01], until: [months: 7]),
        multiplier: Decimal.new("0.5")
      },
      %{
        interval: Timex.Interval.new(from: ~D[2014-10-01], until: [months: 7]),
        multiplier: Decimal.new("0.5")
      }
    ]
  end

  # TODO: Remove
  def call() do
    intervals_and_multipliers()
  end

  def seasons_ago(target_date) do
    intervals_and_multipliers()
    |> Enum.find_index(fn season -> target_date in season.interval end)
  end

  def find_season_attrs(target_date) do
    intervals_and_multipliers()
    |> Enum.find(fn season -> target_date in season.interval end)
  end

  def current_tournaments() do
    # Nationals 2018 is current and should be priced at 1.0
    # currently, it is 1 season ago.
    # tournaments_with_same_name. If there are, then get the most recent one.
  end

  def is_current_tournament(tournament, all_tournaments) do
    [most_recent_tournament_with_same_name] =
      all_tournaments
      |> Enum.filter(fn t -> t.name == tournament.name end)
      |> Enum.sort_by(fn t -> {t.date.year, t.date.month, t.date.day} end)
      |> Enum.reverse()
      |> Enum.take(1)

    tournament.id == most_recent_tournament_with_same_name.id
  end

  @doc """
  Here we create a matrix for given tournaments of a same name and their
  pricing.

  This seems to be a lot better than the previous solution: logic/ifs. Maybe
  this will suffice.
  """

  def team_multiplier() do
    [
      Decimal.new("1.0"),
      Decimal.new("0.9"),
      Decimal.new("0.5"),
      Decimal.new("0.5"),
      # always 0.5 after a certain point.
      Decimal.new("0.5"),
      # always 0.5
      Decimal.new("0.5")
    ]
  end

  def individual_multiplier() do
    [
      Decimal.new("0.9"),
      Decimal.new("0.5"),
      # always 0.5
      Decimal.new("0.5"),
      # always 0.5
      Decimal.new("0.5"),
      # always 0.5
      Decimal.new("0.5")
    ]
  end

  def create_tournament_multiplier_matrix(tournament, all_tournaments, :team) do
    create_multiplier_matrix(tournament, all_tournaments, team_multiplier())
  end

  def create_tournament_multiplier_matrix(tournament, all_tournaments, :individual) do
    create_multiplier_matrix(tournament, all_tournaments, individual_multiplier())
  end

  def create_multiplier_matrix(tournament, all_tournaments, multipliers) do
    all_tournaments
    |> Enum.filter(fn t -> t.name == tournament.name end)
    |> Enum.sort_by(fn t -> {t.date.year, t.date.month, t.date.day} end)
    |> Enum.reverse()
    |> Enum.zip(Enum.take(multipliers, Enum.count(multipliers)))
  end

  def current_tournaments_played(team_data_objects, state) do
    team_data_objects.team.team_results
    |> Enum.filter(fn tr ->

      # TODO: Optmize here
      # There are a few options:
      # 1) Could add a tournament_date to this model, won't need to query again for the tournament.
      # 2) Could find out about a season in a different way. Compare dates instead, that would be fastest.
      #    if we do this (we prob should) we would need to implement the concept of Season that has dates.

      tr = Data.preload_tournament(tr)
      tournament = tr.tournament

      # this is the bad function that takes a long time
      target_tournaments =
        Enum.filter(state.list_of_tournaments, fn tournament ->
          tr.tournament.name == tournament.name
      end)

      is_current_tournament(tournament, target_tournaments)
    end)
    |> Enum.count()
  end
end
