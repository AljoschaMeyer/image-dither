Dither = require './index'

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
    options = {foo: 'bar'}
    dither = new Dither options
    expect(dither.options).toBe options

  it 'has a dither method', ->
    dither = new Dither
    expect(typeof dither.dither).toBe 'function'

  it 'has a ditherInplace method', ->
    dither = new Dither
    expect(typeof dither.ditherInplace).toBe 'function'
