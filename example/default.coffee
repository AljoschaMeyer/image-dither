# An example demonstrating the most basic usage of the module.
Dither = require '../index'

Jimp = require 'jimp'

# read the image from disk using jimp
Jimp.read 'example.jpg', (err, image) ->
  throw err if err?

  defaultDither = new Dither
  newData = defaultDither.dither image.bitmap.data, image.bitmap.width
  # create a Jimp image, write the new Data to its buffer, and save to disk
  new Jimp image.bitmap.width, image.bitmap.height, (err, newImage) ->
    throw err if err?
    for i in [0...newData.length]
      newImage.bitmap.data[i] = newData[i]
    newImage.write 'default.png'
    console.log 'wrote default.png'
