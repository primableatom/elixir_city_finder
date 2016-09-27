defmodule CityFinder.CLI do
  @city_finder_url "http://maps.googleapis.com/maps/api/geocode/json?latlng="
  
  def main(argv) do
    argv
    |> parse_args
    |> process
    |> fetch_city
    |> parse_city
    |> IO.puts
  end
  
  
  def parse_args(argv) do
    result = OptionParser.parse(
      argv,
      switches: [help: :boolean],
      aliases: [h: :help]
    )
    case result do
      {[help: true], _, _} -> :help
      {_,[latlng],_} -> String.split(latlng, ",")
      {_,_,_} -> :help
    end
  end
  
  def process(:help) do
    IO.puts """
    Usage: city_finder <lat,lng>
    """
    System.halt(0)
  end
  
  def process([_lat]) do
    IO.puts """
    Usage: city_finder <lat,lng>
    """
    System.halt(0)
  end
  
  def process([lat, lng]) do
    %{lat: lat, lng: lng}
  end
  
  def fetch_city(%{lat: lat, lng: lng}) do
    response = HTTPotion.get(@city_finder_url <> "#{lat},#{lng}")
    case response do
      %{status_code: 200, body: body} -> JSON.decode(body)
      %{status_code: _} -> :error
    end
  end
  
  def parse_city({:ok, %{"results" => [%{"address_components" => address_component} | _rest], "status" => "OK"}}) do
    address_component
    |> Enum.filter(fn(address) -> address["types"] == ["locality", "political"] end)
    |> List.first
    |> Map.get("long_name")
  end
  
  def parse_city({:ok, %{"results" => [], "status" => "ZERO_RESULTS"}}) do
    "Couldn't find city"
  end
  
  def parse_city({:ok, %{"results" => [], "error_message" => error, "status" => "INVALID_REQUEST"}}) do
    error
  end
  
  def parse_city(:error) do
    "Something went wrong"
  end
  
  
  
end
