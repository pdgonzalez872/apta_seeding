defmodule AptaSeeding.SeedingManager.SeasonManagerTest do
  use ExUnit.Case

  alias AptaSeeding.SeedingManager.SeasonManager

  describe "seasons_ago/1" do
    test "returns the correct number of seasons ago - current season" do
      result = SeasonManager.seasons_ago(~D[2018-10-06])

      assert result == 0
    end

    test "returns the correct number of seasons ago - ending in 2018" do
      result = SeasonManager.seasons_ago(~D[2018-01-06])

      assert result == 1
    end

    test "returns the correct number of seasons ago - ending in 2018 - beginning of it" do
      result = SeasonManager.seasons_ago(~D[2017-11-06])

      assert result == 1
    end

    test "returns the correct number of seasons ago - ending in 2017" do
      result = SeasonManager.seasons_ago(~D[2017-03-06])

      assert result == 2
    end
  end
end
