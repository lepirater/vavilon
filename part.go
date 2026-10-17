package main

import "C"
import "os"
import "strconv"

//export add
func add(a, b C.int) C.int { return a + b }

//export sub
func sub(a, b C.int) C.int { return a - b }

func main() {
    if len(os.Args) < 4 { return }
    a, _ := strconv.Atoi(os.Args[2])
    b, _ := strconv.Atoi(os.Args[3])
    switch os.Args[1] {
    case "+": os.Stdout.WriteString(strconv.Itoa(a + b))
    case "-": os.Stdout.WriteString(strconv.Itoa(a - b))
    }
}
