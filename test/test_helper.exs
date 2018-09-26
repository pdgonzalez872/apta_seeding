ExUnit.start()

ExUnit.configure(exclude: :integration, trace: true)

Ecto.Adapters.SQL.Sandbox.mode(AptaSeeding.Repo, :manual)
