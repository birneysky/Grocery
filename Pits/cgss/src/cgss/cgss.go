package main 

import "fmt"
import "net/http"


func Add(first int, second int) int {
	return first + second
}

func main() {
	fmt.Println("Hello World 你好， 世界!")
	Add(1,2)
	http.ListenAndServe(addr: "0.0.0.0:8080",handler: nil)
}