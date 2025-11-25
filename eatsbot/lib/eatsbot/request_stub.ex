defmodule Eatsbot.RequestStub do
  @moduledoc false
  # https://medium.com/@dimakoua/mocking-http-requests-in-elixir-a-practical-guide-7b177dfd9725
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get!(url, _opts) do
    Agent.get(__MODULE__, &Map.get(&1, url, %{body: []}))
  end

  def set_response(url, response) do
    Agent.update(__MODULE__, &Map.put(&1, url, response))
  end
end
