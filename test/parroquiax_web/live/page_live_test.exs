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

  test "displays existing QR entries on mount", %{
    conn: conn,
    sandbox_owner: sandbox_owner
  } do
    {:ok, lv, _html} = live(conn, "/", session: %{"ecto_sandbox_owner" => sandbox_owner})
    qr_entry = Repo.insert!(%QrEntry{} |> QrEntry.changeset(@create_attrs))
    updated_html = render(lv) # Re-render the LiveView to pick up the new entry

    assert updated_html =~ "QR:</strong> #{qr_entry.qr}</p>"
    assert updated_html =~ "Location: #{qr_entry.location}"
    assert length(Floki.find(updated_html, "#qr-entries li")) == 1
  end

  test "displays new QR entries via PubSub", %{conn: conn, sandbox_owner: sandbox_owner} do
    {:ok, lv, html} = live(conn, "/", session: %{"ecto_sandbox_owner" => sandbox_owner})
    assert length(Floki.find(html, "#qr-entries li")) == 0

    new_qr_entry = Repo.insert!(%QrEntry{} |> QrEntry.changeset(@create_attrs))

    Phoenix.PubSub.broadcast(
      Parroquiax.PubSub,
      "new_qr_entry",
      new_qr_entry
    )

    updated_html = render(lv)

    assert updated_html =~ "QR:</strong> #{new_qr_entry.qr}</p>"
    assert updated_html =~ "Location:</strong> #{new_qr_entry.location}</p>"
    assert updated_html =~ "<li class=\"mb-2 p-2 border rounded-lg shadow-sm\"><p><strong>QR:</strong> #{new_qr_entry.qr}</p>"
  end
end
