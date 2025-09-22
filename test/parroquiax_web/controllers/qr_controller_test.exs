defmodule ParroquiaxWeb.QrControllerTest do
  use ParroquiaxWeb.ConnCase

  alias Parroquiax.Location
  alias Parroquiax.QrEntry
  alias Parroquiax.Repo

  @valid_attrs %{"qr" => "some qr", "location" => "some location"}
  @iso_datetime "2023-01-01T23:00:07Z"

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create qr_entry" do
    test "creates qr_entry and returns created when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/qr", @valid_attrs)
      assert %{"id" => id} = json_response(conn, 201)
      assert %{"message" => "QR entry created successfully"} = json_response(conn, 201)

      qr_entry = Repo.get!(QrEntry, id)
      assert qr_entry.qr == "some qr"
      assert qr_entry.location == "some location"
      assert qr_entry.epoch == 0
    end

    test "creates qr_entry with date and returns created when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/qr", Map.put(@valid_attrs, "date", @iso_datetime))
      assert %{"id" => id} = json_response(conn, 201)
      assert %{"message" => "QR entry created successfully"} = json_response(conn, 201)

      qr_entry = Repo.get!(QrEntry, id)
      assert qr_entry.qr == "some qr"
      assert qr_entry.location == "some location"
      {:ok, expected_datetime, _offset} = DateTime.from_iso8601(@iso_datetime)
      assert qr_entry.date == expected_datetime
    end

    test "creates qr_entry with epoch from location", %{conn: conn} do
      {:ok, location} = Repo.insert(%Location{location: "some location"})

      conn = post(conn, ~p"/api/qr", @valid_attrs)
      assert %{"id" => id} = json_response(conn, 201)
      assert %{"message" => "QR entry created successfully"} = json_response(conn, 201)

      qr_entry = Repo.get!(QrEntry, id)
      assert qr_entry.qr == "some qr"
      assert qr_entry.location == "some location"
      assert qr_entry.epoch == location.current_epoch
    end

    test "discards duplicate qr_entry and returns ok", %{conn: conn} do
      # First request: create the entry
      conn = post(conn, ~p"/api/qr", @valid_attrs)
      assert %{"id" => _id} = json_response(conn, 201)

      # Second request with the same data: should be discarded
      conn = post(conn, ~p"/api/qr", @valid_attrs)
      assert %{"message" => "Duplicate QR code. Entry discarded."} = json_response(conn, 200)

      # Verify that only one entry exists in the database
      assert Repo.all(QrEntry) |> Enum.count() == 1
    end

    test "returns bad request when qr is missing", %{conn: conn} do
      conn = post(conn, ~p"/api/qr", %{"location" => "some location"})
      assert %{"error" => "Missing required fields: qr and location"} = json_response(conn, 400)
    end

    test "returns bad request when location is missing", %{conn: conn} do
      conn = post(conn, ~p"/api/qr", %{"qr" => "some qr"})
      assert %{"error" => "Missing required fields: qr and location"} = json_response(conn, 400)
    end

    test "returns bad request when date is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/qr", Map.put(@valid_attrs, "date", "invalid-date"))

      assert %{"error" => "Invalid datetime format. Please use ISO 8601 format."} =
               json_response(conn, 400)
    end
  end
end
