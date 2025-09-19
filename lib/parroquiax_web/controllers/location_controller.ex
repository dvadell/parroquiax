defmodule ParroquiaxWeb.LocationController do
  use ParroquiaxWeb, :controller

  import Ecto.Query

  alias Parroquiax.Location
  alias Parroquiax.Repo

  def create(conn, %{"location" => location_name}) do
    last_location =
      Repo.one(
        from l in Location,
          where: l.location == ^location_name,
          order_by: [desc: l.current_epoch],
          limit: 1
      )

    epoch =
      if last_location do
        last_location.current_epoch + 1
      else
        1
      end

    changeset =
      %Location{}
      |> Location.changeset(%{location: location_name, current_epoch: epoch})

    case Repo.insert(changeset) do
      {:ok, location} ->
        conn
        |> put_status(:created)
        |> json(%{
          message: "Location entry created successfully",
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
