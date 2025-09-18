defmodule Parroquiax.Repo do
  use Ecto.Repo,
    otp_app: :parroquiax,
    adapter: Ecto.Adapters.Postgres
end
