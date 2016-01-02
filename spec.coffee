Dither = require './index'
impl = require './implementation'

defaultOptions = ->
  return options =
    step: 1
    channels: 4
    diffusionFactor: 1
    clip: (buffer, index) ->
    findColor: (rgba) ->
      return [0, 0, 0, 0]
    matrix: []

describe 'The Dither class', ->
  it 'provides access to multiple diffusion matrices', ->
    expect(Dither.matrices?).toBe true

    expect(Dither.matrices.oneDimensional?).toBe true
    expect(Dither.matrices.floydSteinberg?).toBe true
    expect(Dither.matrices.jarvisJudiceNinke?).toBe true
    expect(Dither.matrices.stucki?).toBe true
    expect(Dither.matrices.atkinson?).toBe true
    expect(Dither.matrices.burkes?).toBe true
    expect(Dither.matrices.sierra3?).toBe true
    expect(Dither.matrices.sierra2?).toBe true
    expect(Dither.matrices.sierraLite?).toBe true

describe 'A Dither instance', ->
  it 'saves options from the constructor', ->
    options = {foo: 'bar', step: 2, findColor: 0, matrix: 2, channels: 7}
    dither = new Dither options
    expect(dither.options.step).toBe 2

  it 'uses default options', ->
    options = {foo: 'bar'}
    dither = new Dither options
    expect(dither.options.step?).toBe true
    expect(dither.options.findColor?).toBe true
    expect(dither.options.diffusionFactor?).toBe true
    expect(dither.options.clip?).toBe true
    expect(dither.options.matrix?).toBe true
    expect(dither.options.channels?).toBe true

  it 'has a dither method', ->
    dither = new Dither
    expect(typeof dither.dither).toBe 'function'

describe 'The dither function', ->
  it 'calls handlePixel on every step-th pixel', ->
    buffer = []
    buffer.push i for i in [0...64]
    dither = new Dither
    spyOn(impl, 'handlePixel')
    for step in [1...5]
      options = defaultOptions()
      options.step = step
      impl.dither buffer, 8, options
    expect(impl.handlePixel.calls.length).toBe 25
  it 'returns a new buffer', ->
    buffer = []
    buffer.push i for i in [0...64]
    dither = new Dither
    expect(dither.dither buffer, 8).not.toBe buffer
  it 'does not change the original buffer', ->
    buffer = []
    buffer.push i for i in [10000...10004]
    dither = new Dither
    dither.dither buffer, 1
    expect(buffer[i]).toBe(10000 + i) for i in [0...buffer.length]

describe 'The handlePixel function', ->
    it 'calls findColor for the pixel', ->
      result = []
      buffer = []
      buffer.push i for i in [0...64]
      options = defaultOptions()
      spyOn(options, 'findColor').andCallThrough()

      for x in [0...8]
        for y in [0...8]
          impl.handlePixel x, y, buffer, result, 1, options
          for i in options.findColor.mostRecentCall.args.length
            expect(options.findColor.mostRecentCall.args[i]).toBe 4*x*y
      expect(options.findColor.calls.length).toBe 64

describe 'The applyNewColor function', ->
  it 'writes the content of d into buffer for options.step == 1', ->
    buffer = []
    d = [0, 1, 2, 3]
    for j in [0...16]
      impl.applyNewColor buffer, 8, d, j*4, {step: 1, channels: 4}
      expect(buffer[j * 4]).toEqual d[0]
      expect(buffer[j * 4 + 1]).toEqual d[1]
      expect(buffer[j * 4 + 2]).toEqual d[2]
      expect(buffer[j * 4 + 3]).toEqual d[3]
  it 'correctly writes in steps', ->
    for step in [1...8]
      buffer = []
      d = [Math.random()]
      for j in [0...16]
        impl.applyNewColor buffer, 8, d, j*4*step, {step: step, channels: 4}
        for deltaStep in [0...step]
          expect(buffer[(j + deltaStep) * 4]).toEqual d[0]
          expect(buffer[(j + deltaStep) * 4 + 1]).toEqual d[1]
          expect(buffer[(j + deltaStep) * 4 + 2]).toEqual d[2]
          expect(buffer[(j + deltaStep) * 4 + 3]).toEqual d[3]

describe 'The error diffusion function', ->
  it 'diffuses the correct error witht the correct factor to the correct pixels', ->
    width = 8
    matrix = []
    for x in [0..2]
      for y in [0..2]
        entry =
          x: x
          y: y
          factor: x * y
        matrix.push entry

    for channels in [1...5]
      d = []
      original = []
      for i in [0...1000]
        d[i] = i
        original[i] = i

      q = []
      q[c] = c for c in [0...channels]
      options = defaultOptions()
      options.channels = channels
      options.matrix = matrix

      impl.diffuseError d, q, 0, 0, 8, options
      for entry in options.matrix
        for c in [0...channels]
          expect(d[impl.calculateIndex(entry.x, entry.y, width, channels) + c]).toBe(original[impl.calculateIndex(entry.x, entry.y, width, channels) + c] + entry.factor * q[c])
