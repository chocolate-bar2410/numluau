---
icon: octicons/download-24
title: installing numluau
description: installation tutorial
---
numluau is designed to work with standalone luau.
Its reccomended to install numluau using a package manager like [pesde](https://pesde.dev/) or [lpm](https://luaupm.com/)

## installing for pesde

1. first install and setup using either [pesde](https://pesde.dev/) or [lpm](https://luaupm.com/)
2. run this command in your IDE/terminal

=== "pesde"
    ```
    pesde add chocolate_bar2410/numluau
    ```
=== "lpm"
    ```
    lpm add chocolatebar2410/numluau
    ```

this should import the library into your package folder


!!! info
    its best practice to add a `numluau` alias to your luaurc file
    ```json
        "aliases": {
            "numluau" = "path.to.library"
        }
    ```