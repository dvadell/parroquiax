defmodule ParroquiaxWeb.LocationController do
  use ParroquiaxWeb, :controller

  alias Parroquiax.Location
  alias Parroquiax.Repo
  alias Phoenix.PubSub

  def create(conn, %{"location" => location_name}) do
    changeset =
      %Location{}
      |> Location.changeset(%{location: location_name})

    case Repo.insert(changeset) do
      {:ok, location} ->
        PubSub.broadcast(Parroquiax.PubSub, "reset", nil)

        dbg()
        conn
        |> put_status(:created)
        |> json(%{
          message: "Nueva ronda",
          id: location.id,
          location: location.location,
          current_epoch: location.current_epoch
        })

      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: changeset})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing required field: location"})
  end
end
