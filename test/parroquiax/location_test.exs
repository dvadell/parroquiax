defmodule Parroquiax.LocationTest do
  use Parroquiax.DataCase

  alias Parroquiax.Location

  @valid_attrs %{location: "some location", current_epoch: 1}
  @invalid_attrs %{current_epoch: 1}

  test "changeset with valid attributes" do
    changeset = Location.changeset(%Location{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Location.changeset(%Location{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with default epoch" do
    changeset = Location.changeset(%Location{}, %{location: "another location"})
    assert changeset.valid?
    location = Ecto.Changeset.apply_changes(changeset)
    assert location.current_epoch == 0
  end
end
