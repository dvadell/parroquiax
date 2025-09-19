defmodule ParroquiaxWeb.QrController do
  use ParroquiaxWeb, :controller

  alias Parroquiax.QrEntry
  alias Parroquiax.Repo
  alias Phoenix.PubSub

  def create(conn, %{"qr" => qr, "location" => location} = params) do
    datetime_str = params["date"]
    epoch = params["epoch"] || 0

    datetime =
      if datetime_str do
        case DateTime.from_iso8601(datetime_str) do
          {:ok, datetime, _offset} -> datetime
          # Invalid datetime format
          {:error, _reason} -> nil
        end
      else
        DateTime.utc_now() |> DateTime.truncate(:second)
      end

    if datetime == nil do
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Invalid datetime format. Please use ISO 8601 format."})
    else
      changeset =
        %QrEntry{}
        |> QrEntry.changeset(%{
          qr: qr,
          location: location,
          date: datetime,
          epoch: epoch
        })

      case Repo.insert(changeset) do
        {:ok, qr_entry} ->
          PubSub.broadcast(Parroquiax.PubSub, "new_qr_entry", qr_entry)

          conn
          |> put_status(:created)
          |> json(%{
            message: "QR entry created successfully",
            id: qr_entry.id,
            qr: qr_entry.qr,
            location: qr_entry.location,
            date: qr_entry.date,
            epoch: qr_entry.epoch
          })

        {:error, changeset} ->
          conn
          |> put_status(:bad_request)
          |> json(%{error: changeset})
      end
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing required fields: qr and location"})
  end
end
