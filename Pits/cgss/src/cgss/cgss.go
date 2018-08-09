package main

import (
	"fmt"
	"net/http"
	"github.com/gorilla/websocket"
)

func Add(first int, second int) int {
	return first + second
}

var (
	upgrader = websocket.Upgrader{
		CheckOrigin: func(r *http.Request) bool {
			return true
		},
	}
)

func wsHandler(w http.ResponseWriter, r* http.Request) {
	var(
		conn *websocket.Conn
		err error
		data []byte
	)
	//w.Write([]byte("hello"))
	if conn, err = upgrader.Upgrade(w,r,nil); err != nil {
		return
	}

	for{
		/// Text Binary
		if _,data,err = conn.ReadMessage(); err != nil {
			goto ERR
		}
		if err = conn.WriteMessage(websocket.TextMessage,data); err != nil {
			goto ERR
		}
	}

	ERR:
		conn.Close()
}

func main() {
	//time.Sleep(10*time.Second)
	fmt.Println("Hello World 你好， 世界!  are you ok ")
	//Add(1,2)
	//http.ListenAndServe(addr: "0.0.0.0:8080",handler: nil)
	//http.ListenAndServe(addr:"xxxxx",handler:nil)
	http.HandleFunc("/ws",wsHandler)

	error := http.ListenAndServe(":8080",nil)
	fmt.Print(error)

}