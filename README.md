# Image - Dither

[![Build Status](https://travis-ci.org/AljoschaMeyer/image-dither.svg)](https://travis-ci.org/AljoschaMeyer/image-dither)

Low level engine for error diffusion image dithering. Takes a buffer or an array of rgba values and applies dithering. Options for dithering include the error diffusion matrix (some common matrices are built-in), color palette, color distance metric and output 'pixel' size.

## Warning
This implementation works, but does a lot of suboptimal things. It should clearly use streams, but it doesn't. It should be implemented in a functional way, but it isn't. Some simple optimizations could have been done, but they weren't.

If you happen to know of an alternative to this modules, please tell me about it and I'll gladly deprecate this. That being said, this still gets the job done of dithering an image with arbitrary diffusion matrices.

### Installation

```bash
npm install image-dither
npm install vorpal
```

### Getting Started

```js
var Dither = require('image-dither');

var options = {matrix: Dither.matrices.atkinson};
var dither = new Dither(options);
var img = magicallyRetrieveBuffer('path/to/img.png');
var imgWidth = magicallyRetrieveWidth('path/to/img.png');

var ditheredImg = dither.dither(img, imgWidth);
```

### Usage
The `example` folder contains helpful examples demonstrating basic usage as well as more complex stuff.

`require('image-dither')` returns the `Dither` class, whose instances provide the following methods:

##### dither(buffer, width, options)
This method takes a buffer or array representing the image to dither. The buffer is expected to consecutively store the channel values for all pixels. An example is the buffer used by [jimp](https://www.npmjs.com/package/jimp). The second argument is the width of the image - the engine needs to know where new lines start.

Returns an array of the channel values for all pixels of the new image and does not modify the passed buffer directly.

#### Options
The following options can be set by passing an `options` object to the `Dither` constructor, by accessing the `options` object exposed by each `Dither` instance, or by passing an `options` object to the `dither()`method.

The options passed to the methods only apply to this method call, and overrule the options set for the `Dither` instance.

##### step
The height and length for a 'pixel' in the output. Bigger step means lower resolution. Defaults to 1.

##### channels
The number of channels per pixel stored in the buffer. Defaults to 4.

##### diffusionFactor
The diffused error is multiplied with this factor before being added. Defaults to 0.9, which looks better most of the time.

##### clip(buffer, index)
This is called after setting the channel-values for a pixel in the error buffer, and can be used to e.g. clip values to fit into the color space dimensions. `buffer[index]` is the value for the first channel, `buffer[index+1]` for the second channel, and so on. Does nothing by default.

##### findColor(channelarray)
This function is called once for each pixel with the pixel's color (error diffusion included) and should return the color to use in the output image. Colors are passed (and expected) as an array with the values for each channel.

The implementation of this function is left to the user, and determines palette choice and color distance metric.

The default function expects and returns rgba values from 0 to 255 and returns either `0,0,0,255` or `255,255,255,255`, based on brightness.

##### matrix
The error diffusion matrix. The following matrices, all taken from [this helpful article on dithering](http://www.tannerhelland.com/4660/dithering-eleven-algorithms-source-code/), are built in:
- `Dither.matrices.atkinson`
- `Dither.matrices.burkes`
- `Dither.matrices.floydSteinberg`
- `Dither.matrices.jarvisJudiceNinke`
- `Dither.matrices.oneDimensional`
- `Dither.matrices.sierraLite`
- `Dither.matrices.sierra2`
- `Dither.matrices.sierra3`
- `Dither.matrices.stucki`
- `Dither.matrices.none`

Defaults to `Dither.matrices.floydSteinberg`.

To specify your own error diffusion matrices, take a look at the implementation of the matrices above in `matrices.coffee`. That should be easier than explaining it here.
