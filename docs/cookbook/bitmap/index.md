---
title: create a bitmap image
description: tutorial on image processing
---

For this tutorial we will be learning how numluau can be used for image processing.
Not only will we make a bitmap image but we'll also implement several effects useful for image processing.

## ingredient list
- numluau
- lune runtime
    - you can use another runtime but this tutorial will assume your using lune.

## why bitmap?

Bitmaps image (or .bmp files) are a image format that store raw image data without any compression.
other file formats like .png or .jpeg while more popular, require heavy math and complicated algorithms which are out of scope for a tutorial like this.

While making this tutorial i considered using netpbm's .ppm file format, which is also a raw image fileformat thats easier to implement.
But the downside is that .ppm require an external program to view on most operating systems.
