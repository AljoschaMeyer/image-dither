# An example showcasing the effect of different steps.
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

  for step in [1...5]
    dither = new Dither {findColor: findColor, step:step}
    newData = dither.dither image.bitmap.data, image.bitmap.width

    # create a Jimp image, write the new Data to its buffer, and save to disk
    new Jimp image.bitmap.width, image.bitmap.height, (err, newImage) ->
      throw err if err?
      for i in [0...newData.length]
        newImage.bitmap.data[i] = newData[i]
      newImage.write "step#{step}.png"
      console.log "wrote step#{step}.png"
