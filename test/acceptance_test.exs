defmodule AptaSeeding.AcceptanceTest do
  use ExUnit.Case

  alias AptaSeeding.ETL

  describe "This is where we try things out" do
    test "main" do
      assert ETL.handle_tournaments_payload() == 1


    end
  end
end
