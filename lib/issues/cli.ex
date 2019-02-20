defmodule Issues.CLI do
  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a
  table of the last _n_ issues in a github project
  """


  def run(argv) do
    argv 
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.
  Otherwise it is a github user name, project name, 
  and (optionally)?  the number of entries to format.
  Return a tuple of `{ user, project, count }`, or `:help` if help was given.
  """
  def parse_args(argv) do
    OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    |> elem(1)
    |> args_to_internal_representation
  end

  def args_to_internal_representation([user, project, count]) do
    {user, project, String.to_integer(count)}
  end

  def args_to_internal_representation([user, project]) do
    {user, project, @default_count}
  end

  def args_to_internal_representation(_) do
    :help
  end

  def process(:help) do
    IO.puts """
      usage:  issues <user> <project> [ count | #{@default_count} ]
    """

    System.halt(0)
  end

  def process([user, project, count]) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> sort_into_desc_order
    |> last(count)
    |> print_as_table
  end

  def decode_response({:ok, body}), do: body
  def decode_response({:error, error}) do
    IO.puts "Error fetching from Github: #{error["message"]}"
    System.halt(2)
  end

  def sort_into_desc_order(list_of_issues) do
    list_of_issues
    |> Enum.sort(fn i1, i2 -> i1["created_at"] >= i2["created_at"] end)
  end

  def last(list, count) do
    list
    |> Enum.take(count)
    |> Enum.reverse
  end

  @id_column_size 12
  @created_at_column_size 25
  @title_column_size 80

  def print_as_table(issues) do
    print_table_header()
    for issue <- issues, do: print_row(issue)
  end

  def print_table_header do
    IO.puts column_headers()
    IO.puts headers_border()
  end

  def column_headers do
    " #" <> String.duplicate(" ", @id_column_size - String.length(" #")) <> "|" <>
    " created_at" <> String.duplicate(" ", @created_at_column_size - String.length(" created_at")) <> "|" <>
    " title" <> String.duplicate(" ", @title_column_size - String.length(" title"))
  end

  def headers_border do
    String.duplicate("-", @id_column_size) <> "+" <>
    String.duplicate("-", @created_at_column_size) <> "+" <>
    String.duplicate("-", @title_column_size)
  end

  def print_row(issue) do
    id_val = issue["id"]
    created_at_val = issue["created_at"]
    title_val = issue["title"]
    IO.puts(
      " " <> Kernel.inspect(id_val) <> String.duplicate(" ", @id_column_size - String.length(Kernel.inspect id_val) - 1) <> "|"
      <> " " <> created_at_val <> String.duplicate(" ", @created_at_column_size - String.length(created_at_val) - 1) <> "|"
      <> " " <> title_val <> String.duplicate(" ", @title_column_size - String.length(title_val) - 1)
    )
  end
end
