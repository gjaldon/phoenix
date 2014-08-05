Code.require_file "plug_helper.exs", __DIR__
Logger.configure(level: :warn)
Mix.shell(Mix.Shell.Process)
ExUnit.start
