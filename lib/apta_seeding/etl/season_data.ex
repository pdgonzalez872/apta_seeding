defmodule AptaSeeding.ETL.SeasonData do

  @doc """
  This takes in a map that gets converted to json, but they are really post params
  Then, we make a request to their api service:

  Ex:
    root_url: "https://platformtennisonline.org"
    api_url: "/services/2015ServiceRanking.asmx/GetRanking"
    post_params: {"stype":2,"rtype":1,"sid":10,"rnum":0,"copt":3,"xid":0}

  I came up with this after looking at how the website worked. I started with
  their url and also looked at their JS. That's where the bulk of the fetching was done.
  """
  def call(tournament_params_to_post) do
    tournament_params_to_post
    |> init()
    |> extract()
    |> transform()
    |> load()
  end

  def init(args) do
    {:ok, %{step: :initialized, args: args}}
  end

  @doc """
  We make the request to the third party api here.
  """
  def extract({:ok, state}) do
    api_call_response = "yay response"

    state = state
            |> Map.put(:step, :extract)
            |> Map.put(:api_call_response, api_call_response)

    {:ok, state}
  end

  @doc """
  We take in a response from the 3rd party server and
  put it in a format we like.
  """
  def transform({:ok, state}) do
    tournaments = []

    state = state
            |> Map.put(:step, :transform)
            |> Map.put(:tournaments, tournaments)

    {:ok, state}
  end

  @doc """
  We don't do anything with the data, just pass it along.
  """
  def load({:ok, state}) do
    state = state
            |> Map.put(:step, :load)

    {:ok, state}
  end

  @doc """
  This function takes in a binary (html doc) and returns a data structure from it (map).
  """
  def parse_html(html) do
    :parse_html
  end
end
