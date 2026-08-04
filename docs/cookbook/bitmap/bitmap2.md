---
title: encoding the bitmap
description: create a bitmap page 2
---

<figure markdown="span">
![bitmap file layout](https://libsiowdujmvaygtfygf.supabase.co/storage/v1/object/sign/images/public/bitmap_format_thumb-17671694278025016541.png?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV85MzRlMGFiYi00Yzk2LTQ4OWMtOWJhMC1jMWRlZjlhMGQwZTIiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJpbWFnZXMvcHVibGljL2JpdG1hcF9mb3JtYXRfdGh1bWItMTc2NzE2OTQyNzgwMjUwMTY1NDEucG5nIiwic2NvcGUiOiJkb3dubG9hZCIsImlhdCI6MTc4NTgxNjkyNiwiZXhwIjoxNzg1OTAzMzI2fQ.agn64J7paEYWYu3oJKzsjoCXP7rxU1rK3TSjRUiM2mU){width=700,loading=lazy}

<figcaption> 
the file structure of a bitmap image. Courtesy to this 
<a href="https://www.0de5.net/stimuli/a-reintroduction-to-programming/memory/binary-formats-through-bitmap-images"> webpage </a>.
</figcaption>
</figure>

Now to actually view our image we're going to have to convert this into a bitmap.
For this we'll take advantage of luau's buffer objects.

Create a new module called `bmp.luau`, this will be what we'll use to create our image.

The bit_depth is just how many bits are used per pixel.

```luau
local fs = require("@lune/fs")
local numluau = require("@numluau")

return function(file_path : string,image: numluau.ndArray<number>, bit_depth: number)
    local bytes_per_pixel = bit_depth // 8
    local height = image.Shape[2]
	local width = image.Shape[3]

    -- The row strides of the data of our final image data.
    local row_stride = ((width * bit_depth + 31) // 32) * 4

    -- The ammount of padding thats applied to each row.
	local padding = row_stride - (width * bytes_per_pixel)

	local header_size = 54
	local data_size = row_stride * height
    local file_size = header_size + data_size

	local result = buffer.create(file_size)
```

## creating the metadata
For reference please look at the image provided at the start of this page for the file layout.

Now the first part of our file is the metadata, this tells us properties of the file including its width, height, bit depth and file size.

Every bitmap file must start with the hex numberes 0x42 0x4D (or BM in ascii), This allows programs to identify what file they're parsing.
This is then followed by the file size.

```luau
    buffer.writestring(result, 0, "BM")
	buffer.writeu32(result, 2, file_size)
```

bytes 0x06 -> 0x09 are used as alignment bytes, These are bytes that are left empty.  
bitmap requires this to keep our header aligned across byte boundaries.

Next is the data offset, this points to the start of the data portion of our file. This is always byte 54 (or 0x36 since we're working with hexadecimal)
Followed by the header size, this is always 40 bytes.

This is followed by our width and height.

```luau
	buffer.writeu32(result, 10, 0x36)
	buffer.writeu32(result, 14, 0x28)

	buffer.writeu32(result, 0x0012, width)
	buffer.writeu32(result, 0x0016, height)
```

byte 0x001A - 0x001B is called biPlanes, this must always be 1.  
This is a historical artifact from when certain displays had multiple seperate colour planes.

This is then followed by the bitdepth and the size of our padded image data.

```luau
	buffer.writeu16(result, 0x001A, 1)
	buffer.writeu16(result, 0x001C, bit_depth)

	buffer.writeu32(result, 0x0022, data_size)
```

## inserting our image data

Sadly while this is raw image data, we cannot just insert our image data directly.
While we are inserting our data, we must pad out each row so its properly aligned across the byte boundaries.

Bitmap files enforces as it allowed old computers to parse data easier.

Bitmap files go from bottom -> top and order the colour channels as blue/green/red.  
So we must account for this in our code.

```luau
    local offset = header_size

    local R = image[1]
	local G = image[2]
	local B = image[3]

    -- to account for bitmaps sorting rows from bottom -> top
	for y = height, 1, -1 do
        -- to reduce the ammount of metamethods called
		local R_row = R[y]
		local G_row = G[y]
		local B_row = B[y]

		for x = 1, width do
            -- bitmaps use a BGR order so we must insert our colours the opposite to what we're used to
			buffer.writeu8(result, offset, B_row[x])
			buffer.writeu8(result, offset + 1, G_row[x])
			buffer.writeu8(result, offset + 2, R_row[x])

			offset += bytes_per_pixel
		end

		offset += padding
	end
```

Finally we must write this to a file, `lune` lets us directly upload a buffer so we dont need to convert it to a string.
Most runtimes should support this, but runtimes like `lute` require you to convert the buffer to a string.

```luau
    fs.writeFile(file_path,result)
end
```

Now in our main script we can now load our image data to a file on our system.

```luau
local numluau = require("@numluau")
local bmp = require("./bmp")
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

local BIT_DEPTH = 24 -- each byte is 8 bits, every pixel uses 3 bytes

bmp("./image.bmp",image,BIT_DEPTH)
```

Now we should be able to now generate a image and export it.

??? info "source code"
    ```luau
    local fs = require("@lune/fs")
    local numluau = require("@numluau")

    return function(file_path : string,image: numluau.ndArray<number>, bit_depth: number)
        local bytes_per_pixel = bit_depth // 8
        local height = image.Shape[2]
        local width = image.Shape[3]

        -- The row strides of the data of our final image data.
        local row_stride = ((width * bit_depth + 31) // 32) * 4

        -- The ammount of padding thats applied to each row.
        local padding = row_stride - (width * bytes_per_pixel)

        local header_size = 54
        local data_size = row_stride * height
        local file_size = header_size + data_size

        local result = buffer.create(file_size)
        buffer.writestring(result, 0, "BM")
        buffer.writeu32(result, 2, file_size)
        buffer.writeu32(result, 10, 0x36)
        buffer.writeu32(result, 14, 0x28)

        buffer.writeu32(result, 0x0012, width)
        buffer.writeu32(result, 0x0016, height)
        buffer.writeu16(result, 0x001A, 1)
        buffer.writeu16(result, 0x001C, bit_depth)

        buffer.writeu32(result, 0x0022, data_size)
        local offset = header_size

        local R = image[1]
        local G = image[2]
        local B = image[3]

        -- to account for bitmaps sorting rows from bottom -> top
        for y = height, 1, -1 do
            -- to reduce the ammount of metamethods called
            local R_row = R[y]
            local G_row = G[y]
            local B_row = B[y]

            for x = 1, width do
                -- bitmaps use a BGR order so we must insert our colours the opposite to what we're used to
                buffer.writeu8(result, offset, B_row[x])
                buffer.writeu8(result, offset + 1, G_row[x])
                buffer.writeu8(result, offset + 2, R_row[x])

                offset += bytes_per_pixel
            end

            offset += padding
        end

        fs.writeFile(file_path,result)
    end
    ```