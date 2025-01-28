defmodule TelegramBotTest do
  use ExUnit.Case
  doctest TelegramBot

  test "greets the world" do
    assert TelegramBot.hello() == :world
  end
end
