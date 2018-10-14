defmodule Transmitter.Bootstrap do
  use Plug.Router

  plug DapnetService.Plug.Api

  plug :match
  plug :dispatch

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

      ip_addr = Plug.Conn.get_req_header(conn, "x-forwarded-for")

      data = %{
        "_id" => transmitter["_id"],
        "node" => System.get_env("NODE_NAME"),
        "connected_since" => Timex.now(),
        "last_seen" => Timex.now(),
        "addr" => ip_addr,
        "software" => Map.get(params, "software"),
      }

      data = Transmitter.Database.update(transmitter["_id"], data)
      Transmitter.RabbitMQ.publish_heartbeat(data)

      send_resp(conn, 200, Poison.encode!(response))
    else
      send_resp(conn, 403, "Forbidden")
    end
  end

  post "/transmitters/_heartbeat" do
    {transmitter, params, conn} = transmitter_auth(conn)

    if transmitter do
      data = %{
        "last_seen" => Timex.now(),
        "addr" => conn.remote_ip
      }

      data = Transmitter.Database.update(transmitter["_id"], data)
      Transmitter.RabbitMQ.publish_heartbeat(data)

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

        if id != nil and auth_key != nil do
          db = DapnetService.CouchDB.db("transmitters")
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
        else
          {nil, params, conn}
        end
      _ ->
        {nil, nil, conn}
    end
  end
end
