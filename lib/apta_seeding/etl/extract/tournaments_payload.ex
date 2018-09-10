defmodule AptaSeeding.ETL.Extract.TournamentsPayload do

  @doc """
  This takes in a map that gets converted to json, but they are really post params
  Then, we make a request to their api service:

  Ex:
    root_url: "https://platformtennisonline.org"
    api_url: "/services/2015ServiceRanking.asmx/GetRanking"
    post_params: {"stype":2,"rtype":1,"sid":10,"rnum":0,"copt":3,"xid":0}
  """
  def call(request_target) do
    # request_target
    # |> prepare_request
    # |> make_request()
    # |> parse_response_json()
    # |> parse_html()
    # |> prepare_output()

    :tournaments_payload
  end

  @doc """
  This function takes in a binary (html doc) and returns a data structure from it (map).
  """
  def parse_html(html) do
    :parse_html
  end
end
