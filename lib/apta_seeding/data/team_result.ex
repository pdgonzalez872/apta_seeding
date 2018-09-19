defmodule AptaSeeding.Data.TeamResult do
  use Ecto.Schema
  import Ecto.Changeset

  schema "team_results" do
    field(:points, :decimal)

    belongs_to :team, AptaSeeding.Data.Team
    belongs_to :tournament, AptaSeeding.Data.Tournament

    timestamps()
  end

  @doc false
  def changeset(team_result, attrs) do
    team_result
    |> cast(attrs, [
      :points,
      :team_id,
      :tournament_id
    ])
    |> validate_required([:points, :team_id, :tournament_id])
  end
end
