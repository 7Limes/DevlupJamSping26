#!/bin/bash

RAYLIB_LIB="./lib"
MINGW_CC="x86_64-w64-mingw32-gcc"

rm build/windows/*.o

odin build game \
  -target:windows_amd64 \
  -build-mode:obj \
  -use-single-module \
  -out:build/windows/game.o

${MINGW_CC} build/windows/game.o lib/raygui-windows.o \
  -L${RAYLIB_LIB} \
  -lraylib \
  -lrayguidll \
  -lgdi32 -lwinmm -lopengl32 -luser32 -lshell32 \
  -lbcrypt \
  -static-libgcc \
  -o game.exe