defmodule ParroquiaxWeb.LocationControllerTest do
  use ParroquiaxWeb.ConnCase

  alias Parroquiax.Location
  alias Parroquiax.Repo

  @valid_attrs %{"location" => "some location"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create location" do
    test "creates location and returns created when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/locations", @valid_attrs)
      assert %{"id" => id} = json_response(conn, 201)
      assert %{"message" => "Location entry created successfully"} = json_response(conn, 201)

      location = Repo.get!(Location, id)
      assert location.location == "some location"
      assert location.current_epoch == 1
    end

    test "creates location with same name and increments epoch", %{conn: conn} do
      conn = post(conn, ~p"/api/locations", @valid_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      location = Repo.get!(Location, id)
      assert location.location == "some location"
      assert location.current_epoch == 1

      conn = post(conn, ~p"/api/locations", @valid_attrs)
      assert %{"id" => new_id} = json_response(conn, 201)

      new_location = Repo.get!(Location, new_id)
      assert new_location.location == "some location"
      assert new_location.current_epoch == 2
    end

    test "returns bad request when location is missing", %{conn: conn} do
      conn = post(conn, ~p"/api/locations", %{})
      assert %{"error" => "Missing required field: location"} = json_response(conn, 400)
    end
  end
end
