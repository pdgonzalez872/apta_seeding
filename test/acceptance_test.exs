defmodule AptaSeeding.AcceptanceTest do
  use ExUnit.Case

  use Timex

  alias AptaSeeding.Data.{Tournament}
  alias AptaSeeding.Repo
  alias AptaSeeding.ETL.TournamentData

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "This is where we try things out" do
    test "playground" do

      third_party_tournament_data_params = %{
        :tournament_date => "03/06/15",
        :tournament_name => "APTA Men's Nationals",
        :xid => "214",
        "copt" => 3,
        "rnum" => 0,
        "rtype" => 1,
        "sid" => 8,
        "stype" => 2,
        "xid" => 0
      }

      date = ~D[2018-09-14]
      name = "Paulos"

      tournament = %{
        date: date,
        name: name,
        name_and_date_unique_name: "#{name}|#{Date.to_string(date)}",
        results_have_been_processed: false,
      }

      change = Tournament.changeset(%Tournament{}, tournament)
      result = Repo.insert!(change)

      new_change = Tournament.changeset(%Tournament{}, tournament)

      new_result = Repo.insert(new_change)

      date = TournamentData.parse_date(third_party_tournament_data_params.tournament_date)
      require IEx; IEx.pry

      # create a tournament, then see what the check would look like.

      # raise "Add check that the tournament with the same name and date does not exist already"
      # raise "Move the decode_json_response and parse_tournament_results to the transform step"

      # raise "continue working on TournamentData, where we send requests for certain tournaments"
      # raise "add integration test, that runs the mix task."
    end
  end
end
