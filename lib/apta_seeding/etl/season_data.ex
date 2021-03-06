defmodule AptaSeeding.ETL.SeasonData do
  require Logger

  @doc """
  This takes in a map that gets converted to json, but they are really post params
  Then, we make a request to their api service:

  Ex:
    root_url: "https://platformtennisonline.org"
    api_url: "/services/2015ServiceRanking.asmx/GetRanking"
    post_params: %{"stype":2,"rtype":1,"sid":10,"rnum":0,"copt":3,"xid":0}

  I came up with this after looking at how the website worked. I started with
  their url and also looked at their JS. That's where the bulk of the fetching was done.

  To see the JS code:
  - visit: https://platformtennisonline.org/Ranking.aspx?stype=2&rtype=1&sid=13&copt=3
  - Inspect |> Sources |> js folder |> RankingDisplay.js
  - The fetching function is on line 74 of that file.
  """
  def call(tournament_params_to_post) do
    tournament_params_to_post
    |> init()
    |> extract()
    |> transform()
    |> load()
  end

  def init(params) do
    {:ok, %{step: :season_init, params: params}}
  end

  @doc """
  We make the request to the third party api here.
  """
  @spec extract(tuple()) :: tuple()
  def extract({:ok, state}) do
    {:ok, body} =
      state.params
      |> create_season_url()
      |> make_request()

    state =
      state
      |> Map.put(:step, :season_extract)
      |> Map.put(:api_call_response_body, body)

    {:ok, state}
  end

  @doc """
  We take in a response from the 3rd party server and
  put it in a format we like.
  """
  def transform({:ok, state}) do
    tournaments =
      state.api_call_response_body
      |> parse_html()
      |> Enum.map(fn el ->
        Map.merge(state.params, el)
      end)

    state =
      state
      |> Map.put(:step, :season_transform)
      |> Map.put(:tournaments, tournaments)

    {:ok, state}
  end

  @doc """
  We don't do anything with the data, just pass it along.
  Keeping this function here to finish the ETL pattern.
  """
  def load({:ok, state}) do
    state =
      state
      |> Map.put(:step, :season_load)

    {:ok, state}
  end

  @doc """
  Finds the tournament data inside the html.
  """
  @spec parse_html(binary()) :: nonempty_list(map())
  def parse_html(html) do
    html
    |> Floki.find("div.expandobtn.expb")
    |> Enum.map(fn season_tournament_div ->
      parse_tournament(season_tournament_div)
    end)
  end

  @doc false
  defp parse_tournament(el) do
    {_, [_, {"xid", xid}],
     [{_, _, [{_, _, [{_, _, [tournament_date]}, {_, _, [tournament_name]}, _, _]}]}, _]} = el

    %{tournament_name: tournament_name, tournament_date: tournament_date, xid: xid}
  end

  # map
  def add_season_params_to_tournaments(el, season_params) do
    require IEx
    IEx.pry()
    el
  end

  @doc """
  This is what a param looks like
  %{"copt" => 3, "rnum" => 0, "rtype" => 1, "sid" => 8, "stype" => 2, "xid" => 0}

  This is what this function should return
  "https://platformtennisonline.org/Ranking.aspx?stype=2&rtype=1&sid=8&copt=3"
  """
  def create_season_url(%{} = params) do
    root = "https://platformtennisonline.org/"

    custom =
      "Ranking.aspx?stype=#{params.stype}&rtype=#{params.rtype}&sid=#{params.sid}&copt=#{
        params.copt
      }"

    root <> custom
  end

  def make_request(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
