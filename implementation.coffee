dither = (buffer, width, options) ->
  # options fall back to the options of the dither object
  options = {} unless options?
  options.step = @options.step unless options.step?
  options.inplace = @options.inplace unless options.inplace?
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

  # create buffer for the result if not operating inplace
  newBuffer = [] unless options.inplace

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
      diffuseError d, q, options

      # write new color to output buffer
      if options.inplace
        applyNewColor buffer, width, newColor, i, options
      else
        applyNewColor newBuffer, width, newColor, i, options

      # end iteration
      x += options.step
    y += options.step

  if options.inplace
    return buffer
  else
    return newBuffer

# modifies d by diffusing the error q according to options.matrix
diffuseError = (d, q, options) ->
  true

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
