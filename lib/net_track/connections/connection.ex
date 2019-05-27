defmodule NetTrack.Connection do
  import Ecto.Query, warn: false
  alias NetTrack.Repo
  alias NetTrack.Connection.Host

  def list() do
    Repo.all(
      from(
        h in Host,
        where: h.active == true and h.blacklisted == false
      )
    )
  end

  def get_blacklist do
    Repo.all(
      from(
        h in Host,
        select: h.mac_address,
        where: h.blacklisted == true
      )
    )
  end

  def get_connection(%{mac_address: mac_address}) do
    Repo.get_by(Host, mac_address: mac_address)
  end

  def add(connection \\ %{}) do
    %Host{}
    |> Host.changeset(connection)
    |> Repo.insert(on_conflict: {:replace, :hostname})
  end

  def add_many(connections) do
    connections
    |> Enum.map(fn c -> Host.changeset(%Host{}, c) end)
    |> Repo.bulk_insert(on_conflict: :nothing)
  end

  def update_many(connections, change) do
    connections
    |> Enum.map(fn c ->
      %Host{}
      |> Host.changeset(c)
      |> Ecto.Changeset.change(change)
    end)
    |> Repo.bulk_update()
  end

  def blacklist_host(connection \\ %{}) do
    %Host{}
    |> Host.changeset(connection)
    |> Ecto.Changeset.change(blacklisted: true)
    |> Repo.update()
  end

  def set_nickname(connection, nickname) do
    %Host{}
    |> Host.changeset(connection)
    |> Ecto.Changeset.change(nickname: nickname)
    |> Repo.update()
  end

  def diff(new, previous, blacklist \\ []) do
    %{current: current, incomplete: incomplete} =
      Enum.reduce(new, %{current: [], incomplete: []}, fn
        %{mac_address: mac_address} = h, acc ->
          cond do
            String.contains?(mac_address, "incomplete") ->
              Map.update!(acc, :incomplete, fn list -> [h.hostname | list] end)

            h.mac_address not in blacklist ->
              Map.update!(acc, :current, fn list -> [h | list] end)

            true ->
              acc
          end
      end)

    previous =
      previous
      |> Enum.map(fn p -> Map.take(p, [:hostname, :mac_address]) end)
      |> Enum.reject(fn p -> p.hostname in incomplete end)
      |> MapSet.new()

    current_set = MapSet.new(current)
    removed = MapSet.difference(previous, current_set)
    added = MapSet.difference(current_set, previous)

    with {:ok, added} <- add_many(added),
         added <- Map.values(added),
         {:ok, removed} <- update_many(removed, active: false),
         removed <- Map.values(removed) do
      total_added = length(added)
      total_removed = length(removed)
      total_changes = total_added + total_removed

      current =
        if total_changes > 0 do
          list()
        else
          previous
        end

      %{
        added: added,
        total_added: total_added,
        removed: removed,
        total_removed: total_removed,
        current: current
      }
    end
  end
end
