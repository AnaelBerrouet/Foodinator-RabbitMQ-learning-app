defmodule Foodinator.Repo do
  use Ecto.Repo,
    otp_app: :foodinator,
    adapter: Ecto.Adapters.Postgres
end
