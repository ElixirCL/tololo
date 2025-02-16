defmodule TololoCore.Location do
  @moduledoc """
  Contains location functions and useful data structures for geoposition
  """

  @earth_radius_in_meters 6_371_000

  @spec distance({float(), float()}, {float(), float()}) :: float()
  @doc """
  Haversine formula is the most common method for calculating distances between geopoints,
  providing accurate results for most scenarios

  - See: [Wikipedia](https://en.wikipedia.org/wiki/Haversine_formula#:~:text=The%20law%20of%20haversines,-Spherical%20triangle%20solved&text=Since%20this%20is%20a%20unit,radius%20R%20of%20the%20sphere).)

  """
  def distance({lat1, lon1}, {lat2, lon2}) do
    # You need the latitude and longitude of both points in decimal degrees
    dlat = deg2rad(lat2 - lat1)
    dlon = deg2rad(lon2 - lon1)

    a =
      :math.pow(:math.sin(dlat / 2), 2) +
        :math.cos(deg2rad(lat1)) * :math.cos(deg2rad(lat2)) *
          :math.pow(:math.sin(dlon / 2), 2)

    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))

    # To convert the calculated distance to meters, you need to multiply the result by the Earth's average radius (approximately 6,371,000 meters)
    @earth_radius_in_meters * c
  end

  # Convert degrees to radians
  defp deg2rad(deg), do: deg * :math.pi() / 180
end
