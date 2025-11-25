defmodule EatsbotWeb.EmailTemplates do
  @moduledoc """
  HTML templates for emails.
  """
  use EatsbotWeb, :html

  def send_magic_link(assigns) do
    ~H"""
    <h2>
      Hello, {@email}! Click
      <a href={url(~p"/auth/user/magic_link/?token=#{@token}")}>
        this link
      </a>
      to sign in.
    </h2>
    If the link doesn't work, manually enter: <br />
    <a href={url(~p"/auth/user/magic_link/?token=#{@token}")}>
      {url(~p"/auth/user/magic_link/?token=#{@token}")}
    </a>
    """
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end
end
