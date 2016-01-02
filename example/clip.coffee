# An example showcasing the effect of clipping errors.
Dither = require '../index'

Jimp = require 'jimp'

# read the image from disk using jimp
Jimp.read 'example.jpg', (err, image) ->
  # generate a random rgba color palette used by the findColor function
  palette = []
  palette.push [0, 0, 0, 255]
  palette.push [255, 255, 255, 255]
  palette.push [Math.floor(Math.random() * 255), Math.floor(Math.random() * 255), Math.floor(Math.random() * 255), 255] for i in [0...4]

  # create a findColor function, which expects and returns rgba colors and returns the palette color with the lowest euclidian distance.
  findColor = (rgba) ->
    bestDelta = Infinity
    bestColor = null

    for c in palette
      delta = Math.sqrt(Math.pow(c[0] - rgba[0], 2) + Math.pow(c[1] - rgba[1], 2) + Math.pow(c[2] - rgba[2], 2))
      if delta < bestDelta
        bestDelta = delta
        bestColor = c
    return bestColor

  # first dither without clipping
  # with a diffusionFactor of 1, we get visible artifacts without the clipping function
  dither = new Dither {findColor: findColor, diffusionFactor: 1}
  newData = dither.dither image.bitmap.data, image.bitmap.width

  # create a Jimp image, write the new Data to its buffer, and save to disk
  new Jimp image.bitmap.width, image.bitmap.height, (err, newImage) ->
    throw err if err?
    for i in [0...newData.length]
      newImage.bitmap.data[i] = newData[i]
    newImage.write 'unclipped.png'
    console.log 'wrote unclipped.png'

  #rgba clipping function
  clip = (buffer, index) ->
    for channelOffset in [0...4]
      buffer[index + channelOffset] = 0 if buffer[index + channelOffset] < 0
      buffer[index + channelOffset] = 255 if buffer[index + channelOffset] > 255

  # dither with the clipping function
  newData = dither.dither image.bitmap.data, image.bitmap.width, {clip: clip}

  # create a Jimp image, write the new Data to its buffer, and save to disk
  new Jimp image.bitmap.width, image.bitmap.height, (err, newImage) ->
    throw err if err?
    for i in [0...newData.length]
      newImage.bitmap.data[i] = newData[i]
    newImage.write 'clipped.png'
    console.log 'wrote clipped.png'
