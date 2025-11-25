defmodule Mix.Tasks.Generate.Delivery.EnvTest do
  use Eatsbot.DataCase, async: false
  import ExUnit.CaptureIO

  setup do
    # create temp dir for test isolation
    tmp_dir = Path.join(System.tmp_dir!(), "delivery_env_test")
    File.mkdir_p!(tmp_dir)
    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    {:ok, tmp_dir: tmp_dir}
  end

  test "generates .env files in specified directory", %{tmp_dir: tmp_dir} do
    output =
      capture_io(fn ->
        Mix.Tasks.Generate.Delivery.Env.run([tmp_dir])
      end)

    assert File.exists?(Path.join(tmp_dir, "generated_env.bru"))
    assert output == ""
  end
end
