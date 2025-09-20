defmodule ParroquiaxWeb.PageLiveTest do
  use ParroquiaxWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Parroquiax.Location
  alias Parroquiax.QrEntry
  alias Parroquiax.Repo

  @topic Parroquiax.PubSub

  setup do
    Repo.insert!(%Location{location: "loc1", current_epoch: 1})
    Repo.insert!(%Location{location: "loc2", current_epoch: 2})

    Repo.insert!(%QrEntry{qr: "qr1", location: "loc1", epoch: 1, date: ~U[2023-01-01 23:00:07Z]})
    Repo.insert!(%QrEntry{qr: "qr2", location: "loc1", epoch: 0, date: ~U[2023-01-01 23:00:07Z]})
    Repo.insert!(%QrEntry{qr: "qr3", location: "loc2", epoch: 2, date: ~U[2023-01-01 23:00:07Z]})
    Repo.insert!(%QrEntry{qr: "qr4", location: "loc2", epoch: 1, date: ~U[2023-01-01 23:00:07Z]})

    :ok
  end

  test "mount correctly filters qr_entries" do
    {:ok, view, _html} = live(build_conn(), "/")

    assert length(Floki.find(render(view), "li[data-testid=qr-entry]")) == 1
    assert render(view) =~ "qr3"
    refute render(view) =~ "qr1"
  end

  test "handle_info updates qr_entries with matching entry" do
    {:ok, view, _html} = live(build_conn(), "/")

    new_qr_entry = %QrEntry{
      qr: "new_qr",
      location: "loc2",
      epoch: 2,
      date: ~U[2023-01-01 23:00:07Z]
    }

    Phoenix.PubSub.broadcast(@topic, "new_qr_entry", new_qr_entry)

    assert length(Floki.find(render(view), "li[data-testid=qr-entry]")) == 2
    assert render(view) =~ "new_qr"
    assert render(view) =~ "qr3"
  end

  test "handle_info does not update qr_entries with non-matching entry" do
    {:ok, view, _html} = live(build_conn(), "/")

    new_qr_entry = %QrEntry{
      qr: "new_qr",
      location: "loc1",
      epoch: 0,
      date: ~U[2023-01-01 23:00:07Z]
    }

    Phoenix.PubSub.broadcast(@topic, "new_qr_entry", new_qr_entry)

    assert length(Floki.find(render(view), "li[data-testid=qr-entry]")) == 1
    refute render(view) =~ "new_qr"
    assert render(view) =~ "qr3"
  end
end