defmodule NetTrack.Connection do
  import Ecto.Query, warn: false
  alias NetTrack.Repo
  alias NetTrack.Connection.Host
  require Logger

  @type diff :: %{
          added: [Host.t()],
          current: [Host.t()],
          removed: [Host.t()],
          total_added: non_neg_integer,
          total_removed: non_neg_integer
        }
  @type scraped_host :: %{hostname: String.t(), mac_address: mac_address}
  @type mac_address :: String.t()
  @type host :: String.t()
  @type blacklist :: [mac_address]

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

  def get_connection(mac_address) do
    Repo.get_by(Host, mac_address: mac_address)
  end

  def add(connection \\ %{}) do
    %Host{}
    |> Host.changeset(connection)
    |> Ecto.Changeset.change(active: true)
    |> Repo.insert(
      on_conflict: {:replace, [:hostname, :active]},
      conflict_target: :mac_address,
      returning: true
    )
  end

  @spec add_many([scraped_host]) :: {:error, any} | {:ok, any}
  def add_many(connections) do
    connections
    |> Enum.map(fn c ->
      %Host{}
      |> Host.changeset(c)
      |> Ecto.Changeset.change(active: true)
    end)
    |> Repo.bulk_insert(
      on_conflict: {:replace, [:active]},
      conflict_target: :mac_address,
      returning: true
    )
  end

  def update(connection, change) do
    connection
    |> Ecto.Changeset.change(change)
    |> Repo.update()
  end

  @spec update_many([Host.t()], change :: Keyword.t() | map) :: {:error, any} | {:ok, any}
  def update_many(connections, change) do
    connections
    |> Enum.map(fn c -> Ecto.Changeset.change(c, change) end)
    |> Repo.bulk_update()
  end

  @spec blacklist_host(Host.t()) :: {:ok, Host.t()} | {:error, Ecto.Changeset.t()}
  def blacklist_host(connection) do
    connection
    |> Ecto.Changeset.change(blacklisted: true)
    |> Repo.update()
  end

  @spec nickname_host(Host.t(), String.t()) :: {:ok, Host.t()} | {:error, Ecto.Changeset.t()}
  def nickname_host(connection, nickname) do
    connection
    |> Ecto.Changeset.change(nickname: nickname)
    |> Repo.update()
  end

  @spec diff([scraped_host], [Host.t()], blacklist) :: {:error, any} | {:ok, diff}
  def diff(current, previous, blacklist \\ []) do
    %{current_map: current_map, incomplete: incomplete} =
      Enum.reduce(current, %{current_map: %{}, incomplete: [], blacklist: blacklist}, fn
        %{mac_address: "incomplete" <> _} = h, acc ->
          Map.update!(acc, :incomplete, fn inc -> [h.hostname | inc] end)

        h, acc ->
          case has(h.mac_address, acc.blacklist) do
            {true, list} ->
              Map.put(acc, :blacklist, list)

            _ ->
              Map.update!(acc, :current_map, fn curr -> Map.put(curr, h.mac_address, h) end)
          end
      end)

    {previous_map, _} =
      Enum.reduce(previous, {%{}, incomplete}, fn p, {acc, list} ->
        case has(p.hostname, list) do
          {true, new_list} ->
            {acc, new_list}

          _ ->
            {Map.put(acc, p.mac_address, p), list}
        end
      end)

    {added, removed} = diff_map(previous_map, current_map)

    with {:ok, added} <- add_many(added),
         {:ok, _removed} <- update_many(removed, active: false) do
      total_added = length(added)
      total_removed = length(removed)
      total_changes = total_added + total_removed
      current = if total_changes > 0, do: list(), else: previous

      {:ok,
       %{
         added: added,
         total_added: total_added,
         removed: removed,
         total_removed: total_removed,
         current: current
       }}
    else
      {:error, reason} ->
        {:error, reason}

      otherwise ->
        Logger.warn("unknown error: #{inspect(otherwise)}")
        {:error, :unknown}
    end
  end

  defp has(val, list, acc \\ [])

  defp has(_, [], acc) do
    {false, acc}
  end

  defp has(val, [val | rest], acc) do
    {true, rest ++ acc}
  end

  defp has(val, [head | rest], acc), do: has(val, rest, [head | acc])

  defp diff_map(old_map, new_map) do
    added = Map.drop(new_map, Map.keys(old_map)) |> Map.values()
    removed = Map.drop(old_map, Map.keys(new_map)) |> Map.values()

    {added, removed}
  end
end
