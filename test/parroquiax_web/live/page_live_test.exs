defmodule ParroquiaxWeb.PageLiveTest do
  use ParroquiaxWeb.ConnCase

  import Phoenix.LiveViewTest
  alias Ecto.Adapters.SQL.Sandbox
  alias Parroquiax.QrEntry
  alias Parroquiax.Repo

  @create_attrs %{qr: "qr_code_1", location: "location_1", date: DateTime.utc_now()}

  setup %{conn: conn} do
    :ok = Sandbox.checkout(Parroquiax.Repo)
    {:ok, conn: conn, sandbox_owner: self()}
  end

  test "displays new QR entries via PubSub", %{conn: conn, sandbox_owner: sandbox_owner} do
    {:ok, lv, html} = live(conn, "/", session: %{"ecto_sandbox_owner" => sandbox_owner})
    assert Floki.find(html, "#qr-entries li") == []

    new_qr_entry = Repo.insert!(%QrEntry{} |> QrEntry.changeset(@create_attrs))

    Phoenix.PubSub.broadcast(
      Parroquiax.PubSub,
      "new_qr_entry",
      new_qr_entry
    )

    updated_html = render(lv)

    assert updated_html =~ "QR:</strong> #{new_qr_entry.qr}</p>"
    assert updated_html =~ "Location:</strong> #{new_qr_entry.location}</p>"

    assert updated_html =~
             "<li class=\"mb-2 p-2 border rounded-lg shadow-sm\"><p><strong>QR:</strong> #{new_qr_entry.qr}</p>"
  end
end
