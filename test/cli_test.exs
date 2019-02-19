defmodule CliTest do
  use ExUnit.Case
  doctest Issues

  import Issues.CLI, only: [parse_args: 1]

  test "greets the world" do
    assert Issues.hello() == :world
  end

  test "returns :help for -h and --help options" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["-help", "anything"]) == :help
  end

  test "returns 3 values if 3 given" do
    assert parse_args(["user", "project", "99"]) == {"user", "project", 99}
  end

  test "set default count if 2 values given" do
    assert parse_args(["user", "project"]) == {"user", "project", 4}
  end
end
