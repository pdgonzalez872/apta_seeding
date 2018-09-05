defmodule AptaSeedingWeb.PageController do
  use AptaSeedingWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
