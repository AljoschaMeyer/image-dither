dither = (buffer, width, options) ->
  # options fall back to the options of the dither object
  options = {} unless options?
  options.step = @options.step unless options.step?
  options.channels = @options.channels unless options.channels?
  options.findColor = @options.findColor unless options.findColor?
  options.matrix = @options.matrix unless options.matrix?

  # given the xy coordinate of a pixel, this returns the index of the first data value for this pixel in the array/buffer
  calculateIndex = (x, y) ->
    return (options.channels*x) + (options.channels*y*width)

  # create and fill the array which will store the values with diffusion applied
  d = []
  d.push buffer[i] for i in [0..buffer.length]

  # calculate image height from width and buffer size
  height = buffer.length / (options.channels * width)

  result = []

  # iterate over all pixels: left to right, top to bottom
  y = 0
  while y < height
    x = 0
    while x < width
      # index for the current pixel
      i = calculateIndex x, y

      # color of the current pixel
      currentColor = []
      currentColor.push d[i + j] for j in [0...options.channels]

      # call findColor for the current pixel to determine
      # the new color for the current pixel
      newColor = options.findColor currentColor

      # the absolute error between the original color and the new color
      q = []
      q[j] = d[i + j] - newColor[j] for j in [0...options.channels]

      # update d by diffusing the error q
      diffuseError d, q, x, y, calculateIndex, options

      applyNewColor result, width, newColor, i, options

      # end iteration
      x += options.step
    y += options.step

  return result

# modifies d by diffusing the error q for pixel xy according to options.matrix
diffuseError = (d, q, x, y, calcIndex, options) ->
  # iterate over the channels per pixel
  for channelOffset in [0...options.channels]
    # diffuse to all coordinates given in the diffusion matrix
    for entry in options.matrix
      index = calcIndex(x + (options.step * entry.x), y + (options.step * entry.y)) + channelOffset
      d[index] += (entry.factor * q[channelOffset])

# write the newColor to buffer for the current pixel i
applyNewColor = (buffer, width, newColor, i, options) ->
  #iterate over buffer indices in options.step steps
  for dx in [0...options.step]
    for dy in [0...options.step]
      di = i + (options.channels * dx) + (options.channels * width * dy)
      buffer[di + j] = newColor[j] for j in [0...options.channels]

module.exports =
  dither: dither
  diffuseError: diffuseError
  applyNewColor: applyNewColor
