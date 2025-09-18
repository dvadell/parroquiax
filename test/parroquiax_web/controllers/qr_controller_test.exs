defmodule ParroquiaxWeb.QrControllerTest do
  use ParroquiaxWeb.ConnCase

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
