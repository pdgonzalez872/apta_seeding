defmodule AptaSeeding.Repo.Migrations.CreateTeamResult do
  use Ecto.Migration

  def change do
    create table(:team_results) do
      add :points, :decimal
      add :team_id, :integer
      add :tournament_id, :integer

      timestamps()
    end
  end
end
