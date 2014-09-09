defmodule Phoenix.Plugs.SessionFetcher do
  alias Plug.Conn

  @moduledoc """
  Plug to fetch Conn Session

  ## Examples

      plug Phoenix.Plugs.SessionFetcher

  """
  @token_length 32

  def init(opts), do: opts

  # TODOS:
  # 1. Check if CSRF token is present every time fetching a session. If it isn't,
  #    generate token and add as key to session
  # 2. Store token in a process so it can be accessed from view/helpers
  # 3. Create helper for hidden_field to be inserted in a form
  # 4. Create helper for meta_tag
  # 5. Add plug to verify CSRF authenticity token matches session csrf token
  # ref: https://gist.github.com/Myuzu/7367461

  def call(conn, _) do
    conn  = Conn.fetch_session(conn)
    token = Conn.get_session(conn, :csrf_token)
    ensure_csrf_token(conn, token)
  end

  def ensure_csrf_token(conn, nil) do
    Conn.put_session(conn, :csrf_token, generate_token(@token_length))
  end

  def ensure_csrf_token(conn, _token) do
    conn
  end

  def generate_token(n) when is_integer(n) do
    :crypto.strong_rand_bytes(n)
      |> :base64.encode_to_string
      |> to_string
  end
end
