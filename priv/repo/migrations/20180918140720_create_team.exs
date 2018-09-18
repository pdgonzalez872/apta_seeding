defmodule AptaSeeding.Repo.Migrations.CreateTeam do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :player_1_id, :integer
      add :player_2_id, :integer

      timestamps()
    end

    create unique_index(:teams, [:name])
  end
end
