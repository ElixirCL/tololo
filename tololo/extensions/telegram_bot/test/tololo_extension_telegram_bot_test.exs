defmodule TololoExtensionTelegramBotTest do
  use ExUnit.Case
  doctest TololoExtensionTelegramBot

  test "greets the world" do
    assert TololoExtensionTelegramBot.hello() == :world
  end
end
