defmodule ParroquiaxWeb.PageLiveTest do
  use ParroquiaxWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Parroquiax.Location
  alias Parroquiax.QrEntry
  alias Parroquiax.Repo

  @topic Parroquiax.PubSub

  setup do
    {:ok, loc1} = Repo.insert(%Location{location: "loc1"})
    {:ok, loc2} = Repo.insert(%Location{location: "loc2"})

    Repo.insert!(%QrEntry{qr: "qr1", location: "loc1", epoch: loc1.current_epoch, date: ~U[2023-01-01 23:00:07Z]})
    Repo.insert!(%QrEntry{qr: "qr2", location: "loc1", epoch: loc1.current_epoch, date: ~U[2023-01-01 23:00:07Z]})
    Repo.insert!(%QrEntry{qr: "qr3", location: "loc2", epoch: loc2.current_epoch, date: ~U[2023-01-01 23:00:07Z]})
    Repo.insert!(%QrEntry{qr: "qr4", location: "loc2", epoch: loc1.current_epoch, date: ~U[2023-01-01 23:00:07Z]})

    {:ok, %{loc1: loc1, loc2: loc2}}
  end

  test "mount correctly filters qr_entries", %{loc1: _loc1, loc2: _loc2} do
    {:ok, view, _html} = live(build_conn(), "/")
    rendered_view = render(view)

    # Presentes (current epoch: loc2.current_epoch)
    presentes_ul = Floki.find(rendered_view, "ul#presentes-entries")
    assert length(Floki.find(rendered_view, "ul#presentes-entries li[data-testid=qr-entry]")) == 1
    assert presentes_ul |> Floki.text() =~ "qr3"
    refute presentes_ul |> Floki.text() =~ "qr1"
    refute presentes_ul |> Floki.text() =~ "qr2"
    refute presentes_ul |> Floki.text() =~ "qr4"

    # Ausentes (not in current epoch, but in database)
    ausentes_ul = Floki.find(rendered_view, "ul#ausentes-entries")
    assert length(Floki.find(rendered_view, "ul#ausentes-entries li[data-testid=qr-entry]")) == 3
    assert ausentes_ul |> Floki.text() =~ "qr1"
    assert ausentes_ul |> Floki.text() =~ "qr2"
    assert ausentes_ul |> Floki.text() =~ "qr4"
    refute ausentes_ul |> Floki.text() =~ "qr3"
  end

  test "handle_info updates qr_entries with matching entry", %{loc2: loc2} do
    {:ok, view, _html} = live(build_conn(), "/")

    new_qr_entry = %QrEntry{
      qr: "new_qr",
      location: "loc2",
      epoch: loc2.current_epoch,
      date: ~U[2023-01-01 23:00:07Z]
    }

    Phoenix.PubSub.broadcast(@topic, "new_qr_entry", new_qr_entry)
    rendered_view = render(view)

    assert length(Floki.find(rendered_view, "ul#presentes-entries li[data-testid=qr-entry]")) == 2
    assert rendered_view =~ "new_qr"
    assert rendered_view =~ "qr3"

    assert length(Floki.find(rendered_view, "ul#ausentes-entries li[data-testid=qr-entry]")) == 3
  end

  test "handle_info does not update qr_entries with non-matching entry", %{loc1: loc1} do
    {:ok, view, _html} = live(build_conn(), "/")

    new_qr_entry = %QrEntry{
      qr: "new_qr_non_matching",
      location: "loc1",
      epoch: loc1.current_epoch - 1,
      date: ~U[2023-01-01 23:00:07Z]
    }

    Phoenix.PubSub.broadcast(@topic, "new_qr_entry", new_qr_entry)
    rendered_view = render(view)

    presentes_ul = Floki.find(rendered_view, "ul#presentes-entries")
    assert length(Floki.find(rendered_view, "ul#presentes-entries li[data-testid=qr-entry]")) == 1
    refute presentes_ul |> Floki.text() =~ "new_qr_non_matching"
    assert rendered_view =~ "qr3"

    assert length(Floki.find(rendered_view, "ul#ausentes-entries li[data-testid=qr-entry]")) == 4
    assert rendered_view =~ "new_qr_non_matching"
  end

  test "toggles expand/collapse on click", %{loc2: loc2} do
    {:ok, view, _html} = live(build_conn(), "/")
    rendered_view = render(view)

    # Find the first "Presentes" item
    presentes_item_selector = "ul#presentes-entries li[data-testid=qr-entry]"
    presentes_item_elements = Floki.find(rendered_view, presentes_item_selector)
    presentes_item = hd(presentes_item_elements)

    # Assert it's initially collapsed (location and date not visible)
    refute Floki.text(presentes_item) =~ "Location:"
    refute Floki.text(presentes_item) =~ "Date:"

    # Click to expand
    clickable_selector = "ul#presentes-entries li[data-testid=qr-entry] > div"
    rendered_view_after_click = view |> element(clickable_selector) |> render_click()

    # Assert it's now expanded
    assert Floki.text(rendered_view_after_click) =~ "Location: #{loc2.location}"
    assert Floki.text(rendered_view_after_click) =~ "Date:"

    # Click to collapse again
    rendered_view_after_second_click =
      view |> element(clickable_selector) |> render_click()

    # Assert it's collapsed again
    refute Floki.text(rendered_view_after_second_click) =~ "Location:"
    refute Floki.text(rendered_view_after_second_click) =~ "Date:"
  end

  test "modal is not visible on mount", %{} do
    {:ok, view, _html} = live(build_conn(), "/")
    modal = Floki.find(render(view), "#delete-modal")
    classes = hd(Floki.attribute(modal, "class"))
    assert "modal" in String.split(classes)
    refute "modal-open" in String.split(classes)
  end

  test "deletes a presente entry", %{loc2: loc2} do
    {:ok, view, _html} = live(build_conn(), "/")

    presente_entry = Repo.get_by!(QrEntry, qr: "qr3", epoch: loc2.current_epoch)

    assert Repo.get(QrEntry, presente_entry.id) != nil

    # Click "Borrar" link
    view
    |> element(~s(a[phx-value-id="#{presente_entry.id}"]))
    |> render_click()

    modal = Floki.find(render(view), "#delete-modal")
    classes = hd(Floki.attribute(modal, "class"))
    assert "modal-open" in String.split(classes)

    # Click "Borrar" in modal
    view
    |> element(~s(#delete-modal button[phx-click="delete_confirmed"]))
    |> render_click()

    refute render(view) =~ "qr3"
    assert Repo.get(QrEntry, presente_entry.id) == nil

    modal_after_click = Floki.find(render(view), "#delete-modal")
    classes_after_click = hd(Floki.attribute(modal_after_click, "class"))
    refute "modal-open" in String.split(classes_after_click)
  end

  test "cancels deleting a presente entry", %{loc2: loc2} do
    {:ok, view, _html} = live(build_conn(), "/")

    presente_entry = Repo.get_by!(QrEntry, qr: "qr3", epoch: loc2.current_epoch)

    assert Repo.get(QrEntry, presente_entry.id) != nil

    # Click "Borrar" link
    view
    |> element(~s(a[phx-value-id="#{presente_entry.id}"]))
    |> render_click()

    modal = Floki.find(render(view), "#delete-modal")
    classes = hd(Floki.attribute(modal, "class"))
    assert "modal-open" in String.split(classes)

    # Click "Cancelar" in modal
    view
    |> element(~s(#delete-modal button[phx-click="cancel_delete"]))
    |> render_click()

    assert render(view) =~ "qr3"
    assert Repo.get(QrEntry, presente_entry.id) != nil

    modal_after_click = Floki.find(render(view), "#delete-modal")
    classes_after_click = hd(Floki.attribute(modal_after_click, "class"))
    refute "modal-open" in String.split(classes_after_click)
  end

  test "deletes an ausente entry", %{} do
    {:ok, view, _html} = live(build_conn(), "/")

    assert Repo.get_by(QrEntry, qr: "qr1") != nil

    # Click "Borrar" link
    view
    |> element(~s(a[phx-value-qr="qr1"]))
    |> render_click()

    modal = Floki.find(render(view), "#delete-modal")
    classes = hd(Floki.attribute(modal, "class"))
    assert "modal-open" in String.split(classes)

    # Click "Borrar" in modal
    view
    |> element(~s(#delete-modal button[phx-click="delete_confirmed"]))
    |> render_click()

    refute render(view) =~ "qr1"
    assert Repo.get_by(QrEntry, qr: "qr1") == nil

    modal_after_click = Floki.find(render(view), "#delete-modal")
    classes_after_click = hd(Floki.attribute(modal_after_click, "class"))
    refute "modal-open" in String.split(classes_after_click)
  end
end
