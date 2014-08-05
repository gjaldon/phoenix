defmodule Phoenix.Plugs.RouterLogger do
  import Phoenix.Controller.Connection
  require Logger

  @moduledoc """
  Plug to handle request logging at the router level

  Includes basic request logging of HTTP method and conn.path_info
  """

  def init(opts), do: opts

  def call(conn, level) do
    Logger.debug """ 
    Processing by #{controller_module(conn)}.#{action_name(conn)}
        Accept: #{response_content_type(conn)}
        Paramets: #{inspect conn.params}
    """
  end
end
