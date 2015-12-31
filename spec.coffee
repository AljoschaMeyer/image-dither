Dither = require './index'
impl = require './implementation'

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
    options = {foo: 'bar', step: 2, inplace: true, findColor: 0, matrix: 2}
    dither = new Dither options
    expect(dither.options.step).toBe 2

  it 'uses default options', ->
    options = {foo: 'bar'}
    dither = new Dither options
    expect(dither.options.step?).toBe true
    expect(dither.options.inplace?).toBe true
    expect(dither.options.findColor?).toBe true
    expect(dither.options.matrix?).toBe true

  it 'has a dither method', ->
    dither = new Dither
    expect(typeof dither.dither).toBe 'function'

describe 'The dither function', ->
  it 'calls findColor once per pixel', ->
    buffer = []
    buffer.push i for i in [0...64]
    options =
      findColor: (rgba) ->
        return rgba
    dither = new Dither

    spyOn(options, 'findColor').andCallThrough()

    dither.dither buffer, 8, options
    expect(options.findColor.calls.length).toBe (64 / 4)
  it 'returns the original buffer if options.inplace', ->
    buffer = []
    buffer.push i for i in [0...64]
    options = {inplace: true}
    dither = new Dither options
    expect(dither.dither buffer, 8).toBe buffer
  it 'returns a new buffer if not options.inplace', ->
    buffer = []
    buffer.push i for i in [0...64]
    options = {inplace: false}
    dither = new Dither options
    expect(dither.dither buffer, 8).not.toBe buffer
  it 'changes the original buffer if options.inplace', ->
    buffer = []
    buffer.push i for i in [10000...10004]
    options = {inplace: true}
    dither = new Dither options
    dither.dither buffer, 1
    expect(buffer[i]).not.toBe(10000 + i) for i in [0...buffer.length]
  it 'does not change the original buffer if not options.inplace', ->
    buffer = []
    buffer.push i for i in [10000...10004]
    options = {inplace: false}
    dither = new Dither options
    dither.dither buffer, 1
    expect(buffer[i]).toBe(10000 + i) for i in [0...buffer.length]

describe 'The applyNewColor function', ->
  it 'writes the content of d into buffer for options.step == 1', ->
    buffer = []
    d = [0, 1, 2, 3]
    for j in [0...16]
      impl.applyNewColor buffer, 8, d, j*4, {step: 1}
      expect(buffer[j * 4]).toEqual d[0]
      expect(buffer[j * 4 + 1]).toEqual d[1]
      expect(buffer[j * 4 + 2]).toEqual d[2]
      expect(buffer[j * 4 + 3]).toEqual d[3]
  it 'correctly writes in steps', ->
    for step in [1...8]
      buffer = []
      d = [Math.random()]
      for j in [0...16]
        impl.applyNewColor buffer, 8, d, j*4*step, {step: step}
        for deltaStep in [0...step]
          expect(buffer[(j + deltaStep) * 4]).toEqual d[0]
          expect(buffer[(j + deltaStep) * 4 + 1]).toEqual d[1]
          expect(buffer[(j + deltaStep) * 4 + 2]).toEqual d[2]
          expect(buffer[(j + deltaStep) * 4 + 3]).toEqual d[3]
