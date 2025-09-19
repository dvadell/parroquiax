defmodule Parroquiax.Location do
  @moduledoc """
  Represents a location.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :location, :string
    field :current_epoch, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:location, :current_epoch])
    |> validate_required([:location, :current_epoch])
  end
end
