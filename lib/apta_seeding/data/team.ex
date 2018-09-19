defmodule AptaSeeding.Data.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field(:name, :string)
    field(:player_1_id, :integer)
    field(:player_2_id, :integer)

    has_many :team_results, AptaSeeding.Data.TeamResult

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [
      :name,
      :player_1_id,
      :player_2_id,
    ])
    |> validate_required([:name, :player_1_id, :player_2_id])
    |> unique_constraint(:name)
  end
end
