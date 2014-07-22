defmodule Phoenix.Plugs.Builder do
  alias Phoenix.Controller.Connection

  @moduledoc """
  Provides Plug.Builder wrapper that injects local `:scoped` plug to conditionally
  execute plugs based on Controller action of Conn

  ## Examples

      plug :assign_layout, "print"
      plug :scoped, {:authenticate, only: [:create, update]}
      plug :action
      plug :scoped, {:render, except: [:edit]}

  """
  defmacro __using__(_) do
    quote do
      use Plug.Builder
      import unquote(__MODULE__)

      def scoped(conn, {plug, actions}), do: scoped(conn, {plug, [], actions})
      def scoped(conn, {plug, opts, only: actions}) when is_list actions do
        if not(Connection.action_name(conn) in actions) do
          if module_plug?(plug) do
            apply(plug, :call, [conn, opts])
          else
            apply(__MODULE__, plug, [conn, opts])
          end
        else
          conn
        end
      end
      def scoped(conn, {plug, opts, except: actions}) when is_list actions do
        if Connection.action_name(conn) in actions do
          if module_plug?(plug) do
            apply(plug, :call, [conn, opts])
          else
            apply(__MODULE__, plug, [conn, opts])
          end
        else
          conn
        end
      end
      def scoped(_conn, {_plug, _opts, _}) do
        raise "Excepted scoped plug to define `:only` or `:except` actions list"
      end
    end
  end

  @doc """
  Returns true if provided atom Plug is a Module

  ## Examples

      iex> Builder.module_plug? Authenticate
      true

      iex> Builder.module_plug? :authenticate
      false

  """
  def module_plug?(plug) do
    match?('Elixir.' ++ _rest, Atom.to_char_list(plug))
  end
end
