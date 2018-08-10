package main

import (
	"fmt"

	"two"
	"one"
)

func Add(first int, second int) int {
	return first + second
}



//func wsHandler(w http.ResponseWriter, r* http.Request) {
//	w.Write([]byte("hello"))
//
//}


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



type File struct {

}

func (f *File) Read(buf []byte) (n int, err error) {
	return 0,nil
}

func (f* File) Write(buf []byte) (n int, err error) {
	return 0, nil
}

func (f* File) Seek(off int64, whence int) (pos int64, err error) {
	return 0,nil
}

func (f* File) Close() error {
	return nil
}

type IFile interface {
	Read(buf []byte) (n int, err error)
	Write(buf []byte) (n int, err error)
	Seek(off int64,whence int) (pos int64, err error)
	Close() error
}

type IReader interface {
	Read(buf []byte) (n int, err error)
}

type IWriter interface{
	Write(buf []byte) (n int, err error)
}

type ICloser interface {
	Close() error
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
	fmt.Println("a = ",a)

	//// key为string value为 UserInfo
	var infos map[string] UserInfo
	infos = make(map[string] UserInfo)
	infos["123455"] = UserInfo{"12345","Tom cat","romm 302"}
	infos["1"] = UserInfo{"1","toney","shen zheng shi "}

	person, ok := infos["1234"]
	if ok {
		fmt.Println("Found person",person.Name,"with ID 1234")
	} else {
		fmt.Println("Did not find person with ID 1234.")
	}


	var (
		file1 IFile
		file2 IReader
		file3 IWriter
		file4 ICloser
	)

	file1 = new(File)
	file2 = new(File)
	file3 = new(File)
	file4 = new(File)

	file1.Close()
	file2.Read([]byte("123"))
	file3.Write([]byte("456"))
	file4.Close()

	/*

	在Go 语言中，这个两个接口(IStream,ReadWriter)实际上并无区别 ,因为
	1.任何实现了one.ReadWriter接口的类，均实现了two.IStream
	2.任何one.ReadWriter接口对象可以赋值给two.IStream  反之也是可以的
	3.在任何地方使用one.ReadWriter接口与使用two.IStream并无差异
	所以以下代码可以编译过
	*/

	var (
		file5 two.IStream
		file6 one.ReadWriter
	)

	file5 = new(File)
	file5.Write([]byte("80"))
	file6 = file1

	file5 = file6


	//http.HandleFunc("/ws",wsHandler)

	//error := http.ListenAndServe(":8080",nil)
	//fmt.Print(error)

}