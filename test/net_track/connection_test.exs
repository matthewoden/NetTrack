defmodule NetTrack.ConnectionTest do
  use NetTrack.RepoCase
  alias NetTrack.Connection
  alias Connection.Host

  @default_params %{mac_address: "ff:ff:ff:ff:ff", hostname: "test.local"}
  def add(params \\ %{}) do
    Connection.add(Map.merge(@default_params, params))
  end

  test "add/1 adds a single host" do
    {:ok, result} = Connection.add(@default_params)
    assert Repo.get(Host, result.mac_address) == result
  end

  test "add_many/1 adds a collection of hosts" do
    to_add = [
      %{mac_address: "ff:ff:ff:ff:ff", hostname: "test.local"},
      %{mac_address: "aa:aa:aa:aa:aa", hostname: "test2.local"}
    ]

    {:ok, result} = Connection.add_many(to_add)

    assert [%{mac_address: "ff:ff:ff:ff:ff"}, %{mac_address: "aa:aa:aa:aa:aa"}] = result
  end

  test "add_many/1 sets active to true on conflict" do
    to_add = [
      %{mac_address: "ff:ff:ff:ff:ff", hostname: "test.local"},
      %{mac_address: "aa:aa:aa:aa:aa", hostname: "test2.local"}
    ]

    {:ok, result} = Connection.add_many(to_add)
    Connection.update_many(result, active: false)
    {:ok, result} = Connection.add_many(to_add)

    Enum.map(result, fn x -> assert x.active == true end)
  end

  test "blacklist_host/1 sets a host as blacklisted" do
    {:ok, result} = add()
    Connection.blacklist_host(result)
    host = Repo.get(Host, result.mac_address)
    assert host.blacklisted == true
  end

  test "nickname_host/1 gives a host a nickname" do
    {:ok, result} = add()
    Connection.nickname_host(result, "test_name")
    host = Repo.get(Host, result.mac_address)
    assert host.nickname == "test_name"
  end

  test "list/0 lists all available, non-blacklisted hosts" do
    {:ok, result} = add()
    {:ok, _blacklisted} = add(%{mac_address: "other", blacklisted: true})

    assert Connection.list() == [result]
  end

  test "get_blacklist/1 returns the mac address of all blacklisted hosts" do
    {:ok, blacklisted} = add(%{blacklisted: true})
    {:ok, _whitelisted} = add(%{mac_address: "other", blacklisted: false})
    assert Connection.get_blacklist() == [blacklisted.mac_address]
  end

  test "get_connection/1 returns complete host, given a mac address." do
    {:ok, result} = add()
    assert Connection.get_connection(result.mac_address) == result
  end

  describe "diff/3" do
    @initial_hosts [
      %{mac_address: "ff:ff:ff:ff:ff", hostname: "test.local"},
      %{mac_address: "aa:aa:aa:aa:aa", hostname: "test2.local"}
    ]
    @current [
      %{mac_address: "aa:aa:aa:aa:aa", hostname: "test2.local"},
      %{mac_address: "cc:cc:cc:cc:cc", hostname: "test3.local"}
    ]

    setup do
      {:ok, added} = Connection.add_many(@initial_hosts)

      {:ok, previous: added}
    end

    test "it returns a list of added hosts", %{previous: previous} do
      {:ok, %{added: [added], total_added: total}} = Connection.diff(@current, previous, [])
      assert total == 1
      assert added.mac_address == "cc:cc:cc:cc:cc"
    end

    test "it saves added hosts", %{previous: previous} do
      {:ok, _} = Connection.diff(@current, previous, [])
      host = Repo.get(Host, "cc:cc:cc:cc:cc")
      assert host.hostname == "test3.local"
    end

    test "it marks added hosts as active", %{previous: previous} do
      {:ok, _} = Connection.diff(@current, previous, [])
      host = Repo.get(Host, "cc:cc:cc:cc:cc")
      assert host.active == true
    end

    test "it returns a list of dropped hosts", %{previous: previous} do
      {:ok, %{removed: [removed], total_removed: total}} = Connection.diff(@current, previous, [])
      assert total == 1
      assert removed.mac_address == "ff:ff:ff:ff:ff"
    end

    test "it sets removed hosts as inactive", %{previous: previous} do
      {:ok, _} = Connection.diff(@current, previous, [])
      host = Repo.get(Host, "ff:ff:ff:ff:ff")
      assert host.active == false
    end

    test "it returns a list of the current, db-hydrated hosts", %{previous: previous} do
      assert {:ok,
              %{
                current: [
                  %Host{
                    mac_address: "aa:aa:aa:aa:aa",
                    hostname: "test2.local",
                    active: true,
                    blacklisted: false
                  },
                  %Host{
                    mac_address: "cc:cc:cc:cc:cc",
                    hostname: "test3.local",
                    active: true,
                    blacklisted: false
                  }
                ]
              }} = Connection.diff(@current, previous, [])
    end

    test "it ignores blacklisted hosts", %{previous: previous} do
      blacklist = ["cc:cc:cc:cc:cc"]
      assert {:ok, %{added: [], total_added: 0}} = Connection.diff(@current, previous, blacklist)
    end

    test "it ignores incomplete hosts", %{previous: previous} do
      current = [%{mac_address: "incomplete", hostname: "test4.local"} | @initial_hosts]
      assert {:ok, %{added: [], total_added: 0}} = Connection.diff(current, previous, [])
    end
  end
end
