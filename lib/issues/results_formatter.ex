defmodule Issues.ResultsFormatter do
  def format(data) do
    Enum.each data, fn issue ->
      issue = List.to_tuple(issue)
      IO.puts "-----Issue #{elem(issue,5)[:created_at]}-----";
      IO.puts "#{elem(issue,15)[:title]}"
    end
  end
end
