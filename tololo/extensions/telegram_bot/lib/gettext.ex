defmodule Tololo.Extensions.TelegramBot.Cldr do
  @moduledoc """
  Config for CLDR.
  """
  use Cldr, TololoCore.CldrConfig.common(Tololo.Extensions.TelegramBot.Gettext)
end

defmodule Tololo.Extensions.TelegramBot.Gettext.Interpolation do
  @moduledoc """
  Define an interpolation module for ICU messages
  """
  use Cldr.Gettext.Interpolation, cldr_backend: Tololo.Extensions.TelegramBot.Cldr
end

defmodule Tololo.Extensions.TelegramBot.Gettext do
  @moduledoc """
  A module providing Internationalization with a gettext-based API.

  By using [Gettext](https://hexdocs.pm/gettext), your module compiles translations
  that you can use in your application. To use this Gettext backend module,
  call `use Gettext` and pass it as an option:

      use Gettext, backend: Tololo.Extensions.TelegramBot.Gettext

      # Simple translation
      gettext("Here is the string to translate")

      # Plural translation
      ngettext("Here is the string to translate",
               "Here are the strings to translate",
               3)

      # Domain-based translation
      dgettext("errors", "Here is the error message to translate")

  See the [Gettext Docs](https://hexdocs.pm/gettext) for detailed usage.
  """
  use Gettext.Backend,
    otp_app: :tololo_extension_telegram_bot,
    interpolation: Tololo.Extensions.TelegramBot.Gettext.Interpolation
end
