defmodule AptaSeeding.ETL.SeasonData do

  @doc """
  This takes in a map that gets converted to json, but they are really post params
  Then, we make a request to their api service:

  Ex:
    root_url: "https://platformtennisonline.org"
    api_url: "/services/2015ServiceRanking.asmx/GetRanking"
    post_params: {"stype":2,"rtype":1,"sid":10,"rnum":0,"copt":3,"xid":0}
  """
  def call(tournament_params_to_post) do
    tournament_params_to_post
    |> extract()
    |> transform()
    |> load()
  end

  def extract(args) do
    args
  end

  def transform(args) do
    args
  end

  def load(args) do
    args
    {:ok, args}
  end

  @doc """
  This function takes in a binary (html doc) and returns a data structure from it (map).
  """
  def parse_html(html) do
    :parse_html
  end
end
