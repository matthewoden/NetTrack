defmodule NetTrack.Connection.PollTest do
  use NetTrack.RepoCase
  alias NetTrack.Connection
  alias Connection.{Poll, Host}
  import ExUnit.CaptureIO

  setup do
    {:ok, data} =
      Connection.add_many([
        %{mac_address: "ff:ff:ff:ff:ff", hostname: "test.local"},
        %{mac_address: "aa:aa:aa:aa:aa", hostname: "test2.local", blacklisted: true}
      ])

    {:ok, data: data}
  end

  test "handle_continue/1 hydrates the initial state connections and blacklist" do
    {:noreply, %{connections: connections, blacklist: blacklist}} =
      Poll.handle_continue(:fetch, %{connections: [], blacklist: []})

    assert [%Host{mac_address: "ff:ff:ff:ff:ff"}] = connections
    assert blacklist == ["aa:aa:aa:aa:aa"]
  end

  test "handle_info(:poll) updates the local connection store", %{
    data: data
  } do
    {:noreply, state} = Poll.handle_info(:poll, %{connections: data, blacklist: []})

    assert [%Host{mac_address: "cd:ef:gh:ij:kl:ab"}] = state.connections
  end

  test "handle_info(:poll) dispatches the registry on change", %{
    data: data
  } do
    Poll.subscribe({IO, :inspect})
    output = capture_io(fn -> Poll.handle_info(:poll, %{connections: data, blacklist: []}) end)
    assert output =~ "%NetTrack.Connection.Host{"
  end

  test "subscribe/1 adds to the registry" do
    Poll.subscribe({IO, :inspect})
    assert 1 == Registry.count(Connection.Registry)
  end

  test "unsubscribe/1 removes from to the registry" do
    Poll.subscribe({IO, :inspect})
    Poll.unsubscribe({IO, :inspect})

    assert 0 == Registry.count(Connection.Registry)
  end
end
