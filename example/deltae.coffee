# A more complex example using the LAB colorspace
Dither = require '../index'

convert = require 'color-convert'
deltaE = require 'delta-e'
Jimp = require 'jimp'

# read the image from disk using jimp
Jimp.read 'example.jpg', (err, image) ->
  # generate a random lab color palette used by the findColor function
  palette = []
  rgbColors = []
  rgbColors.push [0, 0, 0]
  rgbColors.push [255, 255, 255]
  rgbColors.push [Math.floor(Math.random() * 255), Math.floor(Math.random() * 255), Math.floor(Math.random() * 255)] for i in [0...4]
  for rgb in rgbColors
    lab = convert.rgb2lab rgb
    palette.push {L: lab[0], A: lab[1], B: lab[2]}

  # create a findColor function, which expects and returns LAB colors and returns the palette color with the lowest cielab2000 deltaE.
  findColor = (lab) ->
    bestDelta = Infinity
    bestColor = null

    for c in palette
      delta = deltaE.getDeltaE00 {L: lab[0], A: lab[1], B: lab[2]}, c
      if delta < bestDelta
        bestDelta = delta
        bestColor = c
    return [bestColor.L, bestColor.A, bestColor.B]

  # convert the image data from rgba to lab
  labData = []
  for i in [0...image.bitmap.data.length/4]
    lab = convert.rgb2lab [image.bitmap.data[i * 4], image.bitmap.data[i * 4 + 1], image.bitmap.data[i * 4 + 2]]
    labData[i * 3] = lab[0]
    labData[i * 3 + 1] = lab[1]
    labData[i * 3 + 2] = lab[2]

  dither = new Dither {findColor: findColor, channels: 3}
  newData = dither.dither labData, image.bitmap.width

  # convert newData back to rgba
  newRgbaData = []
  for i in [0...newData.length/3]
    rgba = convert.lab2rgb [newData[i * 3], newData[i * 3 + 1], newData[i * 3 + 2]]
    newRgbaData[i * 4] = rgba[0]
    newRgbaData[i * 4 + 1] = rgba[1]
    newRgbaData[i * 4 + 2] = rgba[2]
    newRgbaData[i * 4 + 3] = 255

  # create a Jimp image, write the new Data to its buffer, and save to disk
  new Jimp image.bitmap.width, image.bitmap.height, (err, newImage) ->
    throw err if err?
    for i in [0...newRgbaData.length]
      newImage.bitmap.data[i] = newRgbaData[i]
    newImage.write 'deltae.png'
    console.log 'wrote deltae.png'
