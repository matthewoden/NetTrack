defmodule NetTrack.Connection.Host do
  use Ecto.Schema
  import Ecto.Changeset
  alias NetTrack.Connection.Host

  @primary_key {:mac_address, :string, autogenerate: false}
  schema "hosts" do
    field(:nickname, :string)
    field(:hostname, :string)
    field(:blacklisted, :boolean)
    field(:active, :boolean)

    timestamps()
  end

  @fields ~w(hostname mac_address nickname blacklisted active)a
  @required ~w(hostname mac_address)a

  @spec changeset(Host.t(), map) :: Ecto.Changeset.t()
  @doc false
  def changeset(%Host{} = host, params \\ %{}) do
    host
    |> cast(params, @fields)
    |> validate_required(@required)
  end
end
