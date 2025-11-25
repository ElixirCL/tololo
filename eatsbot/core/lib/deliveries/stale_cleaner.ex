defmodule EatsbotCore.Deliveries.StaleCleaner do
  use GenServer
  require Logger
  alias EatsbotCore.Deliveries
  alias EatsbotCore.Deliveries.Delivery

  @actor Deliveries.Actors.admin()
  @days Application.compile_env(:eatsbot, :days_for_stale, 2)

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    if @days != 0 do
      run_cleanup()
      schedule_next_run()
    end

    {:ok, nil}
  end

  @impl true
  def handle_info(:run_cleanup, state) do
    run_cleanup()
    schedule_next_run()
    {:noreply, state}
  end

  defp schedule_next_run do
    now = NaiveDateTime.utc_now()
    next_run = next_x00_time(now)

    delay = NaiveDateTime.diff(next_run, now, :millisecond)
    Process.send_after(self(), :run_cleanup, delay)
  end

  # get next x:00 time
  defp next_x00_time(now) do
    next_hour = NaiveDateTime.add(now, 3600 - rem(now.minute * 60 + now.second, 3600), :second)
    NaiveDateTime.truncate(next_hour, :second)
  end

  defp run_cleanup do
    Logger.info("Running Delivery cleanup at #{NaiveDateTime.utc_now()}")

    Delivery.get_pending_stale!(nil, actor: @actor)
    |> Enum.each(fn delivery ->
      try do
        make_stale!(delivery)
      rescue
        e ->
          Logger.error("Delivery not updated to stale: #{Exception.message(e)}")
      end
    end)

    Logger.info("Delivery cleanup done at #{NaiveDateTime.utc_now()}")
  end

  defp update_state!(delivery, state), do: Delivery.update_state!(delivery, state, actor: @actor)

  defp make_stale!(%{state: "Init"} = delivery),
    do: delivery |> update_state!("Delivery_Aborted") |> make_stale!()

  defp make_stale!(%{state: "In_Preparation"} = delivery),
    do: delivery |> update_state!("Delivery_Aborted") |> make_stale!()

  defp make_stale!(%{state: "Delivery_Aborted"} = delivery),
    do: delivery |> update_state!("Stale_Delivery_Aborted") |> make_stale!()

  defp make_stale!(%{state: "Ready_To_Pickup"} = delivery),
    do: delivery |> update_state!("Delivery_Aborted") |> make_stale!()

  defp make_stale!(%{state: "In_Delivery"} = delivery),
    do: delivery |> update_state!("Delivery_With_Problems") |> make_stale!()

  defp make_stale!(%{state: "Delivery_With_Problems"} = delivery),
    do: delivery |> update_state!("Stale_Delivery_With_Problems") |> make_stale!()

  defp make_stale!(%{state: "Delivery_Done"} = delivery),
    do: delivery |> update_state!("Stale_Delivery_Done") |> make_stale!()

  defp make_stale!(delivery), do: delivery
end
