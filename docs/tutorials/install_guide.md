---
icon: lucide/rocket
title: installing numluau
description: installation tutorial
---
numluau is designed to work with standalone luau.
It is reccomended to use numluau with a runtime like lune or lute for proper compatability.

### installing via pesde
1. first install and setup [pesde](https://pesde.dev/)
2. run this command in your IDE/terminal

```powershell
pesde add chocolate_bar2410/numluau
```
this should import the library into your package folder

!!! info
    its best practice to add a `numluau` alias to your luaurc file
    ```json
        "aliases": {
            "numluau" = "path.to.library"
        }
    ```