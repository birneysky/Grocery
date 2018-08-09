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


type Interger int

func (a Interger) Less(b Interger) bool {
	return a < b
}

func (a Interger) Add(b Interger) Interger {
	return  a + b
}

func (a *Interger)Sub(b Interger)  {
	  *a -= b
}



type UserInfo struct {
	ID string
	Name string
	Address string
}

func main() {
	//time.Sleep(10*time.Second)
	fmt.Println("Hello World 你好， 世界!  are you ok ")
	var a Interger = 5
	if a.Less(2) {
		a.Add(2)
	} else {
		a.Sub(4)
	}
	fmt.Print("a = ",a)

	//// key为string value为 UserInfo
	var infos map[string] UserInfo
	infos = make(map[string] UserInfo)
	infos["123455"] = UserInfo{"12345","Tom cat","romm 302"}
	infos["1"] = UserInfo{"1","toney","shen zheng shi "}
	

	http.HandleFunc("/ws",wsHandler)

	error := http.ListenAndServe(":8080",nil)
	fmt.Print(error)

}