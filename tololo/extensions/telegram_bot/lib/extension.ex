defmodule Tololo.Extensions.TelegramBot do
  @moduledoc false
  def init do
    unless Process.whereis(Telegex.Finch) do
      {:ok, _} = Finch.start_link(name: Telegex.Finch)
    end
  end
end
