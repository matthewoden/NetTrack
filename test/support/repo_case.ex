defmodule NetTrack.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias NetTrack.Repo

      import Ecto
      import Ecto.Query
      import NetTrack.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(NetTrack.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(NetTrack.Repo, {:shared, self()})
    end

    :ok
  end
end
