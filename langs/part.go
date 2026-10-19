package main

import "C"
import "math"

//export go_part
func go_part(op C.int, a, b C.double) C.double {
    switch op {
    case 0: return a + b
    case 1: return a - b
    case 2: return a * b
    case 3: return a / b
    case 14: return C.double(math.Pi * float64(a) * float64(a))
    }
    return 0
}

func main() {}
