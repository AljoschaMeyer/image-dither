module.exports =
class Dither

  @matrices =
    oneDimensional: false
    floydSteinberg: false
    jarvisJudiceNinke: false
    stucki: false
    atkinson: false
    burkes: false
    sierra3: false
    sierra2: false
    sierraLite: false

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
    unless options?
      @options = defaultOptions
    else
      @options = options
      @options.step = defaultOptions.step unless @options.step?
      @options.inplace = defaultOptions.inplace unless @options.inplace?
      @options.findColor = defaultOptions.findColor unless @options.findColor?
      @options.matrix = defaultOptions.matrix unless @options.matrix?


  dither: (buffer, width) ->
