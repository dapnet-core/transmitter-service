defmodule Transmitter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    # List all child processes to be supervised
    children = [
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: Transmitter.Router,
        options: [port: 80]
      ),
      worker(Transmitter.CouchDB, [], restart: :permanent),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Transmitter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
