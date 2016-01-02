module.exports =
class Dither

  @matrices = require './matrices'

  defaultFindColor = (rgb) ->
    if (rgb[0] * 0.3 + rgb[1] * 0.59 + rgb[2] * 0.11) < 127
      return [0, 0, 0, 255]
    else
      return [255, 255, 255, 255]

  defaultOptions =
    step: 1
    channels: 4
    diffusionFactor: 0.9
    clip: (buffer, index) ->
    findColor: defaultFindColor
    matrix: @matrices.floydSteinberg

  constructor: (options) ->
    @options =
      step: defaultOptions.step
      channels: defaultOptions.channels
      diffusionFactor: defaultOptions.diffusionFactor
      clip: defaultOptions.clip
      findColor: defaultOptions.findColor
      matrix: defaultOptions.matrix
    if options?
      @options.step = options.step if options.step?
      @options.channels = options.channels if options.channels?
      @options.diffusionFactor = options.diffusionFactor if options.diffusionFactor?
      @options.clip = options.clip if options.clip?
      @options.findColor = options.findColor if options.findColor?
      @options.matrix = options.matrix if options.matrix?

  dither: require('./implementation').dither
