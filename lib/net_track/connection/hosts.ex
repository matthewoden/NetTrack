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

  @spec changeset(Host.t(), map) :: Ecto.Changeset.t()
  @doc false
  def changeset(%Host{} = host, params \\ %{}) do
    host
    |> cast(params, [:hostname, :mac_address, :nickname, :blacklisted, :active])
    |> validate_required([:hostname, :mac_address])
    |> unique_constraint(:mac_address)
  end
end
