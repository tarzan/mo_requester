defmodule MoRequester do
  @moduledoc """
  Documentation for MoRequester.
  """
  import Meeseeks.XPath

  @mo_url System.get_env("MO_URL") || "<INSERT MO_URL here>"

  @doc """

  """
  def request() do
    HTTPoison.start()

    document =
      @mo_url
      |> HTTPoison.get!()
      |> Map.get(:body)
      |> Meeseeks.parse(:xml)

    result_code =
      document
      |> Meeseeks.one(xpath("/ProcessResults_Result/ResultCode/text()"))
      |> Meeseeks.tree()

    error_number =
      document
      |> Meeseeks.one(xpath("/ProcessResults_Result/ErrorNumber/text()"))
      |> Meeseeks.tree()

    {result_code, error_number}
  end

  def request(true) do
    HTTPoison.start()

    {time, %{body: response_body}} =
      :timer.tc(fn ->
        HTTPoison.get!(@mo_url)
      end)

    document =
      response_body
      |> Meeseeks.parse(:xml)

    result_code =
      document
      |> Meeseeks.one(xpath("/ProcessResults_Result/ResultCode/text()"))
      |> Meeseeks.tree()

    error_number =
      document
      |> Meeseeks.one(xpath("/ProcessResults_Result/ErrorNumber/text()"))
      |> Meeseeks.tree()

    {result_code, error_number, time}
  end

  def sync_requests(number_of_requests) do
    :timer.tc(fn ->
      1..number_of_requests
      |> Enum.to_list()
      |> Enum.map(fn _ ->
        request()
      end)
    end)
  end

  def async_requests(number_of_requests) do
    :timer.tc(fn ->
      1..number_of_requests
      |> Enum.to_list()
      |> Task.async_stream(fn _ ->
        request()
      end)
      |> Enum.map(fn {:ok, result} -> result end)
    end)
  end
end
