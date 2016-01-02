dither = (buffer, width, options) ->
  # options fall back to the options of the dither object
  options = {} unless options?
  options.step = @options.step unless options.step?
  options.channels = @options.channels unless options.channels?
  options.diffusionFactor = @options.diffusionFactor unless options.diffusionFactor?
  options.clip = @options.clip unless options.clip?
  options.findColor = @options.findColor unless options.findColor?
  options.matrix = @options.matrix unless options.matrix?

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
      impl.handlePixel x, y, d, result, width, options
      x += options.step
    y += options.step
  return result

# given the xy coordinate of a pixel, this returns the index of the first data value for this pixel in the array/buffer
calculateIndex = (x, y, width, channels) ->
  return (channels*x) + (channels*y*width)

# does or calls all actions that need to be done per pixel of the image
handlePixel = (x, y, d, result, width, options) ->
  # index for the current pixel in d
  i = calculateIndex x, y, width, options.channels

  # color of the current pixel
  currentColor = []
  currentColor.push d[i + j] for j in [0...options.channels]

  # call findColor for the current pixel to determine
  # the new color for the current pixel
  newColor = options.findColor currentColor

  # the absolute error between the original color and the new color
  q = []
  q[j] = (d[i + j] - newColor[j]) * options.diffusionFactor for j in [0...options.channels]

  # update d by diffusing the error q
  diffuseError d, q, x, y, width, options

  applyNewColor result, width, newColor, i, options

# modifies d by diffusing the error q for pixel xy according to options.matrix
diffuseError = (d, q, x, y, width, options) ->
  for entry in options.matrix
    index = calculateIndex x + (options.step * entry.x), y + (options.step * entry.y), width, options.channels
    for channelOffset in [0...options.channels]
      d[index + channelOffset] += (entry.factor * q[channelOffset])
    options.clip d, index

# write the newColor to buffer for the current pixel i
applyNewColor = (buffer, width, newColor, i, options) ->
  #iterate over buffer indices in options.step steps
  for dx in [0...options.step]
    for dy in [0...options.step]
      di = i + (options.channels * dx) + (options.channels * width * dy)
      buffer[di + j] = newColor[j] for j in [0...options.channels]

module.exports = impl =
  dither: dither
  handlePixel: handlePixel
  diffuseError: diffuseError
  applyNewColor: applyNewColor
  calculateIndex: calculateIndex
