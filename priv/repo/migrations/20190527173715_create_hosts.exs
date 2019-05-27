defmodule NetTrack.Repo.Migrations.CreateHosts do
  use Ecto.Migration

  def change do
    create table(:hosts) do
      add(:mac_address, :string, primary_key: true)
      add(:hostname, :string)
      add(:nickname, :string)
      add(:blacklisted, :boolean, default: false)
      add(:active, :boolean, default: true)

      timestamps()
    end

    create(unique_index(:hosts, [:mac_address]))
    create(index(:hosts, [:blacklisted]))
    create(index(:hosts, [:nickname]))
    create(index(:hosts, [:active]))
  end
end
