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

end
