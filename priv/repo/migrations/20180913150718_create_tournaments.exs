defmodule AptaSeeding.Repo.Migrations.CreateTournaments do
  use Ecto.Migration

  def change do
    create table(:tournaments) do
      add :name, :string
      add :name_and_date_unique_name, :string
      add :date, :date
      add :results_have_been_processed, :boolean, default: false, null: false

      timestamps()
    end

  end
end
