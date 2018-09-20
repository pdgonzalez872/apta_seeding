defmodule AptaSeeding.SeedingManager.SeasonManager do

  def intervals_and_multipliers() do
    [
     %{interval: Timex.Interval.new(from: ~D[2018-10-01], until: [months: 7]), multiplier: Decimal.new("1.0")},
     %{interval: Timex.Interval.new(from: ~D[2017-10-01], until: [months: 7]), multiplier: Decimal.new("0.9")},
     %{interval: Timex.Interval.new(from: ~D[2016-10-01], until: [months: 7]), multiplier: Decimal.new("0.5")},
     %{interval: Timex.Interval.new(from: ~D[2015-10-01], until: [months: 7]), multiplier: Decimal.new("0.5")},
     %{interval: Timex.Interval.new(from: ~D[2014-10-01], until: [months: 7]), multiplier: Decimal.new("0.5")},
    ]
  end

  def call() do
    intervals_and_multipliers()
  end

  def seasons_ago(target_date) do
    intervals_and_multipliers
    |> Enum.find_index(fn season -> target_date in season.interval end)
  end

  def find_season_attrs(target_date) do
    intervals_and_multipliers
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
end
