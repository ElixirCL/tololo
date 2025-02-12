defmodule TololoCore.Location do
  # in meters
  @earth_radius 6_371_000

  def distance({lat1, lon1}, {lat2, lon2}) do
    dlat = deg2rad(lat2 - lat1)
    dlon = deg2rad(lon2 - lon1)

    a =
      :math.pow(:math.sin(dlat / 2), 2) +
        :math.cos(deg2rad(lat1)) * :math.cos(deg2rad(lat2)) *
          :math.pow(:math.sin(dlon / 2), 2)

    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    @earth_radius * c
  end

  defp deg2rad(deg), do: deg * :math.pi() / 180
end
