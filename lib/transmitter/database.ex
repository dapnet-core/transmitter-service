defmodule Transmitter.Database do
  use GenServer

  def update(id, data) do
    GenServer.call(__MODULE__, {:update, id, data})
  end

  def start_link() do
    GenServer.start_link(__MODULE__, {}, [name: __MODULE__])
  end

  def init(args) do
    :ets.new(:transmitters, [:set, :protected, :named_table])
    {:ok, nil}
  end

  def get(id) do
    case :ets.lookup(:transmitters, id) do
      [{_id, data}] -> data
      [] -> %{}
    end
  end

  def handle_call({:update, id, data}, _from, state) do
    data = get(id) |> Map.merge(data)

    :ets.insert(:transmitters, {id, data})
    {:reply, nil, state}
  end
end
