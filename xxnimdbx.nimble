# Package

version       = "0.5.0"
author        = "Jens Alfke; Akito"
description   = "Nim bindings for libmdbx key-value database. Original author of upstream is Leonid Yuriev, the original NimDBX port was made by Jens Alfke and this fork is a revival of this project by Akito."
license       = "Apache-2.0, OpenLDAP"
installDirs   = @["xxnimdbx", "libmdbx-dist"]

# Dependencies

requires "nim == 1.6.14"
requires "nimterop >= 0.6.13"
