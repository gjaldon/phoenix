defmodule Phoenix.Controller.CsrfProtectionTest do
  use ExUnit.Case
  use PlugHelper
  alias Plug.Conn
  alias Phoenix.Config

  defmodule CsrfProtection.Controller do
    use Phoenix.Controller

    def create(conn, _params) do
      conn
    end

    def show(conn, _params) do
      conn
    end
  end

  defmodule CsrfProtection.Router do
    use Phoenix.Router

    plug Plug.Session,
      store: :cookie,
      key: "test_app_key",
      secret: "8Ja3xi2Tnr4=8Ja3xi2Tnr4=8Ja3xi2Tnr4=8Ja3xi2Tnr4=8Ja3xi2Tnr4=8Ja3xi2Tnr4="
    plug Phoenix.Plugs.SessionFetcher
    plug Phoenix.Plugs.CsrfProtection

    post "/create", CsrfProtection.Controller, :create
    get "/show", CsrfProtection.Controller, :show
  end

  setup do
    # Initialize session with a csrf_token
    conn = simulate_request(CsrfProtection.Router, :get, "show")
    assert !!Conn.get_session(conn, :csrf_token) == true
    :ok
  end

  test "raises error for invalid authenticity token" do
    old_conn = simulate_request(CsrfProtection.Router, :get, "show")
    params = %{first_name: "Foo", csrf_token: "12"}
    assert_raise RuntimeError, fn ->
      recycle(simulate_request(CsrfProtection.Router, :post, "create", params), old_conn)
    end
  end

  test "get requests are always valid" do
    old_conn = simulate_request(CsrfProtection.Router, :get, "show")
    new_conn = simulate_request(CsrfProtection.Router, :get, "show")
    recycle(new_conn, old_conn)
    assert Conn.get_session(old_conn, :csrf_token) == Conn.get_session(new_conn, :csrf_token)
  end

  test "post requests with valid token are allowed" do
    conn  = simulate_request(CsrfProtection.Router, :get, "show")
    token = Conn.get_session(conn, :csrf_token)
    conn = simulate_request(CsrfProtection.Router, :post, "create", %{csrf_token: token})
  end
end
