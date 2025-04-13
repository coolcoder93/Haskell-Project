#!/bin/sh

HFLAGS="-XHaskell98 -XNoNPlusKPatterns -Wall -Wextra"

cd source/
set -xe
ghc $HFLAGS -lglfw -lGL -DGL_DEBUG --make Main.hs -o ../game.exe
