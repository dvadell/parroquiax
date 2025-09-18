defmodule Parroquiax.QrEntry do
  @moduledoc """
  Represents a QR entry.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "qr_entries" do
    field :qr, :string
    field :location, :string
    field :date, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(qr_entry, attrs) do
    qr_entry
    |> cast(attrs, [:qr, :location, :date])
    |> validate_required([:qr, :location, :date])
  end
end
