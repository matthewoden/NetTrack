defmodule NetTrack.Repo do
  use Ecto.Repo,
    otp_app: :net_track,
    adapter: Ecto.Adapters.Postgres

  alias NetTrack.Repo
  alias Ecto.Multi

  @type changesets :: [Ecto.Changeset.t()]

  @spec bulk_insert(changesets, Keyword.t()) :: {:ok, term} | {:error, term}
  def bulk_insert(changesets \\ [], opts \\ [])

  def bulk_insert([], _opts), do: {:ok, %{}}

  def bulk_insert(changesets, opts) do
    Enum.reduce(changesets, {0, Multi.new()}, fn changeset, {n, multi} ->
      {n + 1, Multi.insert(multi, n, changeset, opts)}
    end)
    |> elem(1)
    |> Repo.transaction()
  end

  @spec bulk_update(changesets, Keyword.t()) :: {:ok, term} | {:error, term}
  def bulk_update(changesets \\ [], opts \\ [])

  def bulk_update([], _opts), do: {:ok, %{}}

  def bulk_update(changesets, opts) do
    Enum.reduce(changesets, {0, Multi.new()}, fn changeset, {n, multi} ->
      {n + 1, Multi.update(multi, n, changeset, opts)}
    end)
    |> elem(1)
    |> Repo.transaction()
  end
end
