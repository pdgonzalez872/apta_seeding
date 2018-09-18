defmodule AptaSeeding.Repo.Migrations.CreateIndividualResult do
  use Ecto.Migration

  def change do
    create table(:individual_results) do
      add :points, :decimal
      add :player_id, :integer
      add :tournament_id, :integer

      timestamps()
    end
  end
end
