defmodule Transmitter.CouchDB do
  use GenServer

  def db(name), do: GenServer.call(__MODULE__, {:db, name})

  def start_link() do
    GenServer.start_link(__MODULE__, {}, [name: __MODULE__])
  end

  def init(args) do
    user = System.get_env("COUCHDB_USER")
    pass = System.get_env("COUCHDB_PASSWORD")
    server = CouchDB.connect("couchdb", 5984, "http", user, pass)
    {:ok, server}
  end

  def handle_call({:db, name}, _from, server) do
    {:reply, CouchDB.Server.database(server, name), server}
  end
end
