defmodule AptaSeeding.Data.IndividualResult do
  use Ecto.Schema
  import Ecto.Changeset

  schema "individual_results" do
    field(:points, :decimal)

    belongs_to :player, AptaSeeding.Data.Player
    belongs_to :tournament, AptaSeeding.Data.Tournament

    timestamps()
  end

  @doc false
  def changeset(individual_result, attrs) do
    individual_result
    |> cast(attrs, [
      :points,
      :player_id,
      :tournament_id
    ])
    |> validate_required([:points, :player_id, :tournament_id])
  end
end
