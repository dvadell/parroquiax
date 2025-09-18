defmodule ParroquiaxWeb.PageController do
  use ParroquiaxWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
