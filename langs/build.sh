#!/bin/bash
set -e
# all shi tested on fedora linux
# also now you gay, go kiss your dad or bro
zig build-lib part.zig -static -O ReleaseFast -femit-bin=libzigpart.a
dmd -betterC -c part.d -of=dpart.o && echo "d done"
go build -buildmode=c-shared -o libgopart.so part.go && echo "go done"
nim c --header:nim.h --app:lib --noMain -o:libnimpart.so part.nim && echo "nim done"
rustc --crate-type=staticlib -o librustpart.a part.rs
