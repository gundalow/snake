package main

import "fmt"
import "C"

//export Hello
func Hello() {
	fmt.Println("Hello from Go shared library!")
}

func main() {
	fmt.Println("Hello from Go!")
}
