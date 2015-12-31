module.exports =
class Dither
  constructor: (@options) ->

  dither: (buffer, width) ->

  ditherInplace: (buffer, width) ->

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
