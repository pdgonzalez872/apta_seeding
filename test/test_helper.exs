ExUnit.start()

ExUnit.configure(exclude: :integration)

Ecto.Adapters.SQL.Sandbox.mode(AptaSeeding.Repo, :manual)
