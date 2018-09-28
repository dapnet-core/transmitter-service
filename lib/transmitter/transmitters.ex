defmodule Transmitter.Transmitters do
  use Plug.Router

  plug DapnetService.Plug.Api

  plug :match
  plug :dispatch

  get "/" do
    options = %{"include_docs" => true, "limit" => 20}
    |> Map.merge(conn.query_params)

    {:ok, results} = DapnetService.CouchDB.db("transmitters")
    |> CouchDB.Database.view("transmitters", "byId", options)

    transmitters = results
    |> Poison.decode!
    |> Map.update("rows", [], fn rows ->
      Stream.map(rows, &(Map.get(&1, "doc")))
      |> Stream.map(fn transmitter ->
        status = Transmitter.Database.get(transmitter["_id"])
        online = status["last_seen"] != nil && Timex.diff(status["last_seen"], Timex.now(), :minutes) < 2
        status = Map.put(status, "online", online)
        Map.put(transmitter, "status", status)
      end)
    end)

    send_resp(conn, 200, Poison.encode!(transmitters))
  end

  get "/_map" do
    {:ok, results} = DapnetService.CouchDB.db("transmitters")
    |> CouchDB.Database.view("transmitters", "map")
    send_resp(conn, 200, results)
  end

  get "/:id" do
    result = DapnetService.CouchDB.db("transmitters")
    |> CouchDB.Database.get(id)

    case result do
      {:ok, data} ->
        send_resp(conn, 200, data)
      _ ->
        send_resp(conn, 404, "Not found")
    end
  end

  defp auth_permission(conn, perm) do
    case HTTPoison.get("http://auth/users/permission/{perm}") do
      {:ok, response} -> Poison.decode!(response.body)
      _ -> false
    end
  end
end
