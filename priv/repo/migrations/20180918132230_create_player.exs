defmodule AptaSeeding.Repo.Migrations.CreatePlayer do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :name, :string

      timestamps()
    end

    create unique_index(:tournaments, [:name])
  end
end
