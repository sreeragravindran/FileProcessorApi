defmodule BatchFileProcessorWeb.PageController do
  use BatchFileProcessorWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
