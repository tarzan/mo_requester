defmodule MoRequesterTest do
  use ExUnit.Case
  doctest MoRequester

  test "does a request" do
    assert {"Ok", "0"} == MoRequester.request()
  end

  test "does 5 sync requests within 2 secs" do
    assert {time, values} = MoRequester.sync_requests(5)
    assert time < 2_000_000
    assert values == 1..5 |> Enum.to_list() |> Enum.map(fn _ -> {"Ok", "0"} end)
  end

  test "does 5 async requests within 2 secs" do
    assert {time, values} = MoRequester.async_requests(5)
    assert time < 2_000_000
    assert values == 1..5 |> Enum.to_list() |> Enum.map(fn _ -> {"Ok", "0"} end)
  end

  test "does 100 async requests within 5 secs" do
    assert {time, values} = MoRequester.async_requests(100)
    assert time < 5_000_000
    assert values == 1..100 |> Enum.to_list() |> Enum.map(fn _ -> {"Ok", "0"} end)
  end
end
