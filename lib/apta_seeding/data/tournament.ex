defmodule AptaSeeding.Data.Tournament do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tournaments" do
    field(:date, :date)
    field(:name, :string)
    field(:name_and_date_unique_name, :string)
    field(:results_have_been_processed, :boolean, default: false)
    field(:raw_results_html, :string)

    has_many :individual_results, AptaSeeding.Data.IndividualResult

    timestamps()
  end

  @doc false
  def changeset(tournament, attrs) do
    tournament
    |> cast(attrs, [
      :name,
      :name_and_date_unique_name,
      :date,
      :results_have_been_processed,
      :raw_results_html
    ])
    |> validate_required([:name, :name_and_date_unique_name, :date, :results_have_been_processed])
    |> unique_constraint(:name_and_date_unique_name)
  end
end
