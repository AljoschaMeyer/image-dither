dither = (buffer, width, options) ->
  # options fall back to the options of the dither object
  options = {} unless options?
  options.step = @options.step unless options.step?
  options.findColor = @options.findColor unless options.findColor?
  options.matrix = @options.matrix unless options.matrix?

  # given the xy coordinate of a pixel, this returns the index of the first data value for this pixel in the array/buffer
  calculateIndex = (x, y) ->
    return (4*x) + (4*y*width)

  # create and fill the array which will store the values with diffusion applied
  d = []
  d.push buffer[i] for i in [0..buffer.length]

  # calculate image height from width and buffer size
  height = buffer.length / (4 * width)

  result = []

  # iterate over all pixels: left to right, top to bottom
  y = 0
  while y < height
    x = 0
    while x < width
      # index for the current pixel
      i = calculateIndex x, y

      # indices for the different channels of the current pixel
      r = i
      g = i + 1
      b = i + 2
      a = i + 3

      # call findColor for the current pixel to determine
      # the new color for the current pixel
      newColor = options.findColor [d[r], d[g], d[b], d[a]]

      # the absolute error between the original color and the new color
      q = []
      q[r] = d[r] - newColor[0]
      q[g] = d[g] - newColor[1]
      q[b] = d[b] - newColor[2]

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
  for channelOffset in [0...4]
    # diffuse to all coordinates given in the diffusion matrix
    for entry in options.matrix
      d[calcIndex(x + (options.step * entry.x), y + (options.step * entry.y)) + channelOffset] += entry.factor * q[channelOffset]

# write the newColor to buffer for the current pixel i
applyNewColor = (buffer, width, newColor, i, options) ->
  #iterate over buffer indices in options.step steps
  for dx in [0...options.step]
    for dy in [0...options.step]
      di = i + (4 * dx) + (4 * width * dy)
      buffer[di + j] = newColor[j] for j in [0...4]

module.exports =
  dither: dither
  diffuseError: diffuseError
  applyNewColor: applyNewColor
