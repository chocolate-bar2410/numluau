---
title: creating the data
description: create a bitmap page 1
---

To start we will be creating a 100 x 100 8 bit image.  
This image will use 3 colour channels for red/green/blue, so we will require a array thats 3 x 100 x 100.


```luau
local numluau = require("@numluau")
-- makes print out more readable
numluau.set_printoptions({ precision = 2, suppress = true }) 

local WIDTH = 100
local HEIGHT = 100
local MAX_RGB = 0xFF
local image: numluau.ndArray<number> = numluau.zeros(3, HEIGHT, WIDTH)
```

For now we'll just make this image all magenta.

```luau

local R = image[1]
local G = image[2]
local B = image[3]

R[":"] = MAX_RGB
G[":"] = 0
B[":"] = MAX_RGB
```

??? info "source code"
    ```luau
    local numluau = require("@numluau")

    -- makes print out more readable
    numluau.set_printoptions({ precision = 2, suppress = true }) 

    local WIDTH = 100
    local HEIGHT = 100
    local MAX_RGB = 0xFF
    local image: numluau.ndArray<number> = numluau.zeros(3, HEIGHT, WIDTH)
   
    local R = image[1]
    local G = image[2]
    local B = image[3]

    R[":"] = MAX_RGB
    G[":"] = 0
    B[":"] = MAX_RGB

    ```

