defmodule Transmitter.Router do
  use Plug.Router

  plug DapnetService.Plug.Api

  plug :match
  plug :dispatch

  match "/transmitters/_bootstrap", to: Transmitter.Bootstrap
  match "/transmitters/_heartbeat", to: Transmitter.Bootstrap

  forward "/transmitters", to: Transmitter.Transmitters
end
