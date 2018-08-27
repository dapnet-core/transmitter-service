defmodule Transmitter.Router do
  use Plug.Router

  plug Transmitter.Plug.Api

  plug :match
  plug :dispatch

  get "/transmitters" do
    options = %{"include_docs" => true, "limit" => 20}
    |> Map.merge(conn.query_params)

    {:ok, results} = Transmitter.CouchDB.db("transmitters")
    |> CouchDB.Database.all_docs(options)

    transmitters = results
    |> Poison.decode!
    |> Map.update("rows", [], fn rows ->
      rows
      |> Stream.map(&(Map.get(&1, "doc")))
      |> Stream.map(fn transmitter ->
        transmitter |> Map.merge(%{
            "status" => "offline",
            "address" => "44.1.2.3",
            "device" => "UniPager 2.0.0"
        })
      end)
    end)

    send_resp(conn, 200, Poison.encode!(transmitters))
  end

  get "/transmitters/:id" do
    transmitters = []
    send_resp(conn, 200, Poison.encode!(transmitters))
  end

  post "/transmitters/_bootstrap" do
    {transmitter, params, conn} = transmitter_auth(conn)

    if transmitter do
      nodes = case HTTPoison.get("http://cluster/cluster/nodes") do
                {:ok, response} -> Poison.decode!(response.body)
                _ -> %{}
              end

      response = %{
        "timeslots" => Map.get(transmitter, "timeslots"),
        "nodes" => nodes
      }

      send_resp(conn, 200, Poison.encode!(response))
    else
      send_resp(conn, 403, "Forbidden")
    end
  end

  post "/transmitters/_heartbeat" do
    {transmitter, params, conn} = transmitter_auth(conn)

    if transmitter do
      response = %{"status" => "ok"}
      send_resp(conn, 200, Poison.encode!(response))
    else
      send_resp(conn, 403, "Forbidden")
    end
  end

  def transmitter_auth(conn) do
    {:ok, body, conn} = read_body(conn)
    case Poison.decode(body) do
      {:ok, params} ->
        id = Map.get(params, "callsign")
        auth_key = Map.get(params, "auth_key")

        db = Transmitter.CouchDB.db("transmitters")
        case CouchDB.Database.get(db, id) do
          {:ok, result} ->
            transmitter = result |> Poison.decode!
            {correct_auth_key, transmitter} = transmitter |> Map.pop("auth_key")

            if auth_key == correct_auth_key do
              {transmitter, params, conn}
            else
              {nil, params, conn}
            end
          _ ->
            {nil, params, conn}
        end
      _ ->
        {nil, nil, conn}
    end
  end
end
