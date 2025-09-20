defmodule Parroquiax.Location do
  @moduledoc """
  Represents a location.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :location, :string
    field :current_epoch, :integer, read_after_writes: true

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:location])
    |> validate_required([:location])
  end
end
