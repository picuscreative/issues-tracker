defmodule Issues.GithubIssues do
  @user_agent [ "User-agent": "Elixir dave@pragprog.com"]

  def fetch(user, project) do
    case HTTPotion.get(issues_url(user, project), @user_agent) do
      %HTTPotion.Response{body: body, headers: _headers, status_code: status}
      when status in 200..299 ->
        { :ok, body }
      %HTTPotion.Response{body: body, headers: _headers, status_code: status} ->
        { :error, body }
    end
  end

  def issues_url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end
end