module.exports =
class Dither

  @matrices = require './matrices'

  defaultFindColor = (rgb) ->
    if (rgb[0] * 0.3 + rgb[1] * 0.59 + rgb[2] * 0.11) < 127
      return [0, 0, 0, 100]
    else
      return [100, 100, 100, 100]

  defaultOptions =
    step: 1
    inplace: false
    findColor: defaultFindColor
    matrix: @matrices.floydSteinberg

  constructor: (options) ->
    @options = defaultOptions
    if options?
      @options.step = options.step if options.step
      @options.inplace = options.inplace if options.inplace
      @options.findColor = options.findColor if options.findColor
      @options.matrix = options.matrix if options.matrix

  dither: (buffer, width) ->
