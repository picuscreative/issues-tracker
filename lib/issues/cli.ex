defmodule Issues.CLI do
  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a
  table of the last _n_ issues in a github project
  """

  def main(argv) do
    argv
      |> parse_args
      |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.
  Otherwise it is a github user name, project name, and (optionally)
  the number of entries to format.
  Return a tuple of `{ user, project, count }`, or `:help` if help was given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean],
                                     aliases:  [ h:    :help   ])
    case parse do
      { [ help: true ], _, _ } -> :help
      { _, [ user, project, count ], _ } -> { user, project, count }
      { _, [ user, project ], _ } -> { user, project, @default_count }
      _ -> :help
    end
  end

  @doc """
  Return usage for process command if help was given.
  """
  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  @doc """
  `{ user, project, count }` is tuple with username, project name and issues count.
  """
  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
      |> decode_response
      |> convert_to_list_of_hashdicts
      |> sort_into_ascending_order
      |> Enum.take(count)
  end

  def convert_to_list_of_hashdicts(list) do
    for value <- list, do: (for {k,v} <- value, do: Map.put(%{}, String.to_atom(k), v) )
  end

  def sort_into_ascending_order(list_of_issues) do
    Enum.sort list_of_issues
  end

  defp decode_response({:ok, body}), do: JSON.decode(body)

  defp decode_response({:error, body}) do
    error = JSON.decode(body)["message"]
    IO.puts "Error fetching from Github: #{error}"
    System.halt(2)
  end
end
