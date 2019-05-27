defmodule NetTrack do
  @moduledoc """
  Documentation for NetTrack.
  """

  @doc """
  start application

  """
  use Application

  def start(_type, _args) do
    children = [
      {NetTrack.Repo, []},
      {NetTrack.Connection.Supervisor, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
