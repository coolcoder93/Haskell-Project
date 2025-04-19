#!/bin/sh

HFLAGS="-XHaskell98 -XNoNPlusKPatterns -XBangPatterns -Wall -Wextra"

PLATFORM_FLAGS=""
if [ "$(uname)" = "Darwin" ]; then
    PLATFORM_FLAGS="-lglfw3 -framework OpenGL -framework Cocoa -framework IOKit"
else
    # TODO: Make it so that you specify debug/release as an argument
    PLATFORM_FLAGS="-lglfw -lGL -DGL_DEBUG"
fi

cd source/
set -xe
ghc $HFLAGS $PLATFORM_FLAGS --make Main.hs -o ../game.exe
