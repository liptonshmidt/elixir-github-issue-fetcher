defmodule CliTest do
  use ExUnit.Case
  doctest Issues

  import Issues.CLI, only: [parse_args: 1, sort_into_desc_order: 1]

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

  test "sorts into desc order correctly" do
    result = sort_into_desc_order(fake_created_at_list([3, 1, 2]))

    issues = for issue <- result, do: Map.get(issue, "created_at")

    assert issues == [3, 2, 1]
  end

  defp fake_created_at_list(values) do
    for value <- values,
        do: %{"created_at" => value, "other_data" => "data"}
  end
end
