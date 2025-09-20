defmodule Parroquiax.Locations do
  @moduledoc """
    Controller for Database-related Parroquiax.Location functions
  """

  import Ecto.Query
  alias Parroquiax.{Location, Repo}

  def get_current_epoch do
    case Repo.one(from l in Location, order_by: [desc: l.current_epoch], limit: 1) do
      nil -> 0
      %Location{current_epoch: current_epoch} -> current_epoch
    end
  end
end
