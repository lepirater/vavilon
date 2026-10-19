#!/bin/bash
set -e
# all shi tested on fedora linux
# also now you gay, go kiss your dad or bro
zig build-lib part.zig -static -O ReleaseFast -femit-bin=libzigpart.a
dmd -betterC -c part.d -of=dpart.o && echo "d done"
g++ -c part.cpp -o cpppart.o && echo "cpp done"
gnatmake -c -gnatp -O2 ada_part.adb && echo "ada done"
go build -buildmode=c-shared -o libgopart.so part.go && echo "go done"
nim c --header:nim.h --app:lib --noMain -o:libnimpart.so part.nim && echo "nim done"
rustc --crate-type=staticlib -o librustpart.a part.rs
cd ../nab
make
cd ../langs
../nab/nab -c part.nabc part.nb
gcc -c -O2 -fPIC -I../nab/src \
    ../nab/src/nab.c ../nab/src/vm.c ../nab/src/bc.c ../nab/src/verify.c ../nab/src/ffi.c
gcc -c -O2 -fPIC -I../nab/src nabwarpper.c -o nabwarpper.o
gcc -shared -o libnabpart.so nab.o vm.o bc.o verify.o ffi.o nabwarpper.o -lm -ldl
rm -f nab.o vm.o bc.o verify.o ffi.o nabwarpper.o
echo "notabyte done"
