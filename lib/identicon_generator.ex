defmodule IdenticonGenerator do
  @moduledoc """
    Documentation for IdenticonGenerator.
  """

  @doc """
  Generates indenticons.

  ## Examples

      iex> IdenticonGenerator.main("Test")
      :ok
  """

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
  Generates hex list to be used to generate the image.

  ## Examples

      iex> IdenticonGenerator.hash_input("Hayden")
      %Identicon.Image{
        color: nil,
        grid: nil,
        hex: [148, 180, 14, 255, 245, 194, 211, 91, 98, 67, 120, 76, 136, 175, 232],
        pixel_map: nil
      }
  """

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list
    |> Enum.slice(0, 15)
    %Identicon.Image{hex: hex}
  end

  @doc """
  Sets color of squares based on the hex_list.

  ## Examples

      iex> hex_list = %Identicon.Image{color: nil,grid: nil,hex: [148, 180, 14, 255, 245, 194, 211, 91, 98, 67, 120, 76, 136, 175, 232],pixel_map: nil}
      iex> IdenticonGenerator.pick_color(hex_list)
      %Identicon.Image{
        color: {148, 180, 14},
        grid: nil,
        hex: [148, 180, 14, 255, 245, 194, 211, 91, 98, 67, 120, 76, 136, 175, 232],
        pixel_map: nil
      }

  """

  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image| color: {r, g, b }}
  end

  @doc """
  Assigns each of the 25 squares a value based on the hex_list.

  ## Examples
      iex> hex_list = %Identicon.Image{color: {148, 180, 14}, grid: nil, hex: [148, 180, 14, 255, 245, 194, 211, 91, 98, 67, 120, 76, 136, 175, 232], pixel_map: nil}
      iex> IdenticonGenerator.build_grid(hex_list)
      %Identicon.Image{
        color: {148, 180, 14},
        grid: [
          {148, 0},
          {180, 1},
          {14, 2},
          {180, 3},
          {148, 4},
          {255, 5},
          {245, 6},
          {194, 7},
          {245, 8},
          {255, 9},
          {211, 10},
          {91, 11},
          {98, 12},
          {91, 13},
          {211, 14},
          {67, 15},
          {120, 16},
          {76, 17},
          {120, 18},
          {67, 19},
          {136, 20},
          {175, 21},
          {232, 22},
          {175, 23},
          {136, 24}
        ],
        hex: [148, 180, 14, 255, 245, 194, 211, 91, 98, 67, 120, 76, 136, 175, 232],
        pixel_map: nil
      }

  """

  def build_grid(%Identicon.Image{hex: hex_list} = image) do
    grid =
      hex_list
      |> Enum.chunk_every(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  @doc """
  Takes a row of three items and returns five with the first and second duplicated and flipped. [1,2,3] to [1,2,3,2,1]

  ## Examples
      iex> IdenticonGenerator.mirror_row([1,2,3])
      [1,2,3,2,1]
  """

  def mirror_row(row) do
    [first, second | _tail ] = row
    row ++ [second, first]
  end

  @doc """
  Removes all odd valued tuples from the grid. Odd valued squares will not be filled in.

  ## Examples
      iex> hex_list = %Identicon.Image{color: {148, 180, 14},grid: [{148, 0},{180, 1},{14, 2},{180, 3},{148, 4},{255, 5},{245, 6},{194, 7},{245, 8},{255, 9},{211, 10},{91, 11},{98, 12},{91, 13},{211, 14},{67, 15},{120, 16},{76, 17},{120, 18},{67, 19},{136, 20},{175, 21},{232, 22},{175, 23},{136, 24}],hex: [148, 180, 14, 255, 245, 194, 211, 91, 98, 67, 120, 76, 136, 175, 232],pixel_map: nil}
      iex> IdenticonGenerator.filter_odd_squares(hex_list)
      %Identicon.Image{
        color: {148, 180, 14},
        grid: [
          {148, 0},
          {180, 1},
          {14, 2},
          {180, 3},
          {148, 4},
          {194, 7},
          {98, 12},
          {120, 16},
          {76, 17},
          {120, 18},
          {136, 20},
          {232, 22},
          {136, 24}
        ],
        hex: [148, 180, 14, 255, 245, 194, 211, 91, 98, 67, 120, 76, 136, 175, 232],
        pixel_map: nil
      }

  """

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end
    %Identicon.Image{image | grid: grid}
  end

  @doc """
  Generates a pixel map of where the squares will be placed in the image.

  ## Examples
      iex> hex_list = %Identicon.Image{color: {148, 180, 14},grid: [{148, 0},{180, 1},{14, 2},{180, 3},{148, 4},{194, 7},{98, 12},{120, 16},{76, 17},{120, 18},{136, 20},{232, 22},{136, 24}],hex: [148, 180, 14, 255, 245, 194, 211, 91, 98, 67, 120, 76, 136, 175, 232],pixel_map: nil}
      iex> IdenticonGenerator.build_pixel_map(hex_list)
      %Identicon.Image{
        color: {148, 180, 14},
        grid: [
          {148, 0},
          {180, 1},
          {14, 2},
          {180, 3},
          {148, 4},
          {194, 7},
          {98, 12},
          {120, 16},
          {76, 17},
          {120, 18},
          {136, 20},
          {232, 22},
          {136, 24}
        ],
        hex: [148, 180, 14, 255, 245, 194, 211, 91, 98, 67, 120, 76, 136, 175, 232],
        pixel_map: [
          {{0, 0}, {50, 50}},
          {{50, 0}, {100, 50}},
          {{100, 0}, {150, 50}},
          {{150, 0}, {200, 50}},
          {{200, 0}, {250, 50}},
          {{100, 50}, {150, 100}},
          {{100, 100}, {150, 150}},
          {{50, 150}, {100, 200}},
          {{100, 150}, {150, 200}},
          {{150, 150}, {200, 200}},
          {{0, 200}, {50, 250}},
          {{100, 200}, {150, 250}},
          {{200, 200}, {250, 250}}
        ]
      }

  """

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
  Generates the Indenticon image.

  ## Examples
      iex> hex_list = %Identicon.Image{color: {148, 180, 14},grid: [{148, 0},{180, 1},{14, 2},{180, 3},{148, 4},{194, 7},{98, 12},{120, 16},{76, 17},{120, 18},{136, 20},{232, 22},{136, 24}],hex: [148, 180, 14, 255, 245, 194, 211, 91, 98, 67, 120, 76, 136, 175, 232], pixel_map: [{{0, 0}, {50, 50}},{{50, 0}, {100, 50}},{{100, 0}, {150, 50}},{{150, 0}, {200, 50}},{{200, 0}, {250, 50}},{{100, 50}, {150, 100}},{{100, 100}, {150, 150}},{{50, 150}, {100, 200}},{{100, 150}, {150, 200}},{{150, 150}, {200, 200}},{{0, 200}, {50, 250}},{{100, 200}, {150, 250}},{{200, 200}, {250, 250}}]}
      iex> image = IdenticonGenerator.draw_image(hex_list)
      iex> byte_size(image)
      1603   
  """  

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)
    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  @doc """
  Saves the Indenticon image.

  ## Examples
      iex> hex_list = %Identicon.Image{color: {148, 180, 14},grid: [{148, 0},{180, 1},{14, 2},{180, 3},{148, 4},{194, 7},{98, 12},{120, 16},{76, 17},{120, 18},{136, 20},{232, 22},{136, 24}],hex: [148, 180, 14, 255, 245, 194, 211, 91, 98, 67, 120, 76, 136, 175, 232], pixel_map: [{{0, 0}, {50, 50}},{{50, 0}, {100, 50}},{{100, 0}, {150, 50}},{{150, 0}, {200, 50}},{{200, 0}, {250, 50}},{{100, 50}, {150, 100}},{{100, 100}, {150, 150}},{{50, 150}, {100, 200}},{{100, 150}, {150, 200}},{{150, 150}, {200, 200}},{{0, 200}, {50, 250}},{{100, 200}, {150, 250}},{{200, 200}, {250, 250}}]}
      iex> image = IdenticonGenerator.draw_image(hex_list)
      iex> IdenticonGenerator.save_image(image, "Hayden")
      :ok
  """  

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
  
end
