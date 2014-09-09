defmodule Phoenix.Plugs.CsrfProtection do
  alias Plug.Conn

  @moduledoc """
  Plug to fetch Conn params and merge any named parameters from route definition

  Plugged automatically by Phoenix.Controller

  ## Examples

      plug Phoenix.Plugs.ParamsFetcher

  """
  @methods ~w(GET HEAD)

  def init(opts), do: opts

  def call(%Conn{method: method} = conn, _opts) when method in @methods do
    conn
  end

  def call(conn, opts) do
    if verified_request?(conn) do
      conn
    else
      raise "Foo"
    end
  end

  def verified_request?(conn) do
    # !protect_against_forgery? || request.get? || request.head? ||
    #       valid_authenticity_token?(session, form_authenticity_param) ||
    #       valid_authenticity_token?(session, request.headers['X-CSRF-Token'])
    authenticity_token_valid?(conn)
  end

  def authenticity_token_valid?(conn) do
    real_csrf_token(conn) == conn.params["csrf_token"]
  end

  def real_csrf_token(conn) do
    Conn.get_session(conn, :csrf_token)
  end
end
