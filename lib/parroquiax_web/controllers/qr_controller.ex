defmodule ParroquiaxWeb.QrController do
  use ParroquiaxWeb, :controller

  alias Parroquiax.QrEntry
  alias Parroquiax.Repo

  def create(conn, %{"qr" => qr, "location" => location} = params) do
    datetime_str = params["date"]

    datetime =
      if datetime_str do
        case DateTime.from_iso8601(datetime_str) do
          {:ok, datetime, _offset} -> datetime
          {:error, _} -> nil # Invalid datetime format
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
        |> QrEntry.changeset(%{qr: qr, location: location, date: datetime})

      case Repo.insert(changeset) do
        {:ok, qr_entry} ->
          conn
          |> put_status(:created)
          |> json(%{
            message: "QR entry created successfully",
            id: qr_entry.id,
            qr: qr_entry.qr,
            location: qr_entry.location,
            date: qr_entry.date
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