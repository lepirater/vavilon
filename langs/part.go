package main

import "C"

//export go_part
func go_part(op C.int, a, b C.double) C.double {
	switch op {
	case 0:
		return a + b
	case 1:
		return a - b
	case 2:
		return a * b
	case 3:
		return a / b
	}
	return 0
}

func main() {}
