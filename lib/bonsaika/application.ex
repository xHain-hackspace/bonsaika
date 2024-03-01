defmodule Bonsaika.Application do
  use Application

  def start(_type, _args) do
    children = [
      Bonsaika.Scheduler
    ]

    opts = [strategy: :one_for_one, name: Bonsaika.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Bonsaika.Scheduler do
  use Quantum, otp_app: :bonsaika
end
