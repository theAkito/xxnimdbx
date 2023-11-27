#! /bin/bash -e

nim doc --project --index:on --git.url:https://github.com/theAkito/xxnimdbx --git.commit:main --outdir:htmldocs xxnimdbx.nim
rm -f htmldocs/xxnimdbx/private/libmdbx.*
