defmodule NetTrack.Connection.Poll do
  use GenServer
  require Logger

  alias NetTrack.Connection

  def start_link(_) do
    subscriptions = Application.get_env(:net_track, :subscriptions, [])

    Enum.each(subscriptions, fn {mod, fun} ->
      {:ok, _} = Registry.register(Connection.Registry, :arrivals, {mod, fun})
    end)

    state = %{connections: [], blacklist: []}
    {:ok, _pid} = GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, state, {:continue, :fetch}}
  end

  defp schedule_poll(time) do
    Process.send_after(self(), :poll, time)
  end

  def subscribe({mod, fun}) do
    {:ok, _} = Registry.register(Connection.Registry, :arrivals, {mod, fun})
  end

  def unsubscribe({mod, fun}) do
    :ok = Registry.unregister_match(Connection.Registry, :arrivals, {mod, fun})
  end

  def handle_continue(:fetch, state) do
    blacklist = Connection.get_blacklist()
    connections = Connection.list()
    schedule_poll(1000)
    state = %{state | blacklist: blacklist ++ state.blacklist, connections: connections}

    {:noreply, state}
  end

  def handle_info(:poll, state) do
    {:ok, connections} =
      Connection.diff(
        list_connections(),
        state.connections,
        state.blacklist
      )

    if connections.total_added > 0 do
      Logger.info("Connections Added: #{connections.total_added}, #{inspect(connections.added)}")
    end

    if connections.total_removed > 0 do
      Logger.info(
        "Connections Removed: #{connections.total_removed}, #{inspect(connections.removed)}"
      )
    end

    Registry.dispatch(Connection.Registry, :arrivals, fn entries ->
      for {_pid, {module, function}} <- entries do
        try do
          connections.added
          |> Enum.map(fn addition -> apply(module, function, [addition]) end)
        catch
          kind, reason ->
            formatted = Exception.format(kind, reason, __STACKTRACE__)
            Logger.error("Registry.dispatch/3 failed with #{formatted}")
        end
      end
    end)

    schedule_poll(1000)

    {:noreply, %{state | connections: connections.current}}
  end

  defp list_connections() do
    if :ok == NetTrack.Command.ping() do
      {:ok, connections} = NetTrack.Command.arp()
      connections
    else
      []
    end
  end
end
