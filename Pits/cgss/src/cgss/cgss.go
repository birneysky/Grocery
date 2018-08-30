package main

import (
	"fmt"
	"two"
	"one"
	"mlib"
	"strings"
	"net/http"
	"io/ioutil"
	"time"
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


	var manager *mlib.MusicManager = mlib.NewMusicManager()
	manager.Add(&mlib.MusicEntry{"1","我就是我","张国荣","香港","流行音乐粤语"})
	manager.Add(&mlib.MusicEntry{"2","忘情水","刘德华","香港","流行音乐国语"})
	manager.Add(&mlib.MusicEntry{"3","十年","陈奕迅","香港","流行音乐国语"})
	manager.Add(&mlib.MusicEntry{"4","曾经的你","许巍","内地","流行音乐国语"})
	manager.Add(&mlib.MusicEntry{"5","双杰伦","周杰棍","台湾","流行音乐国语"})

	//http.HandleFunc("/ws",wsHandler)

	//error := http.ListenAndServe(":8080",nil)
	//fmt.Print(error)

	go httpPost()

	time.Sleep(1000*time.Second)
	fmt.Println(" ttt exit")
}

const data = `------WebKitFormBoundarymVsj1pWgFHfrafqZ
Content-Disposition: form-data; name=\"K_code\"


------WebKitFormBoundarymVsj1pWgFHfrafqZ
Content-Disposition: form-data; name=\"market\"

sz
------WebKitFormBoundarymVsj1pWgFHfrafqZ
Content-Disposition: form-data; name=\"type\"

hq
------WebKitFormBoundarymVsj1pWgFHfrafqZ
Content-Disposition: form-data; name=\"code\"

000651
------WebKitFormBoundarymVsj1pWgFHfrafqZ
Content-Disposition: form-data; name=\"orgid\"

gssz0000651
------WebKitFormBoundarymVsj1pWgFHfrafqZ
Content-Disposition: form-data; name=\"minYear\"

2016
------WebKitFormBoundarymVsj1pWgFHfrafqZ
Content-Disposition: form-data; name=\"maxYear\"

2018
------WebKitFormBoundarymVsj1pWgFHfrafqZ
Content-Disposition: form-data; name=\"hq_code\"

000651
------WebKitFormBoundarymVsj1pWgFHfrafqZ
Content-Disposition: form-data; name=\"hq_k_code\"


------WebKitFormBoundarymVsj1pWgFHfrafqZ
Content-Disposition: form-data; name=\"cw_code\"

000651
------WebKitFormBoundarymVsj1pWgFHfrafqZ
Content-Disposition: form-data; name=\"cw_k_code\"


------WebKitFormBoundarymVsj1pWgFHfrafqZ
Content-Disposition: form-data; name=\"hq_code\"


------WebKitFormBoundarymVsj1pWgFHfrafqZ
Content-Disposition: form-data; name=\"hq_k_code\"


------WebKitFormBoundarymVsj1pWgFHfrafqZ
Content-Disposition: form-data; name=\"cw_code\"


------WebKitFormBoundarymVsj1pWgFHfrafqZ
Content-Disposition: form-data; name=\"cw_k_code\"


------WebKitFormBoundarymVsj1pWgFHfrafqZ--
`


func httpPost(){
	reader := strings.NewReader(data);
	response,err := http.Post("http://www.cninfo.com.cn/cninfo-new/data/download",
		"multipart/form-data; boundary=----WebKitFormBoundarymVsj1pWgFHfrafqZ",
		reader)
	defer response.Body.Close()
	if err != nil {
		fmt.Println(err)
	}
	body, _ := ioutil.ReadAll(response.Body)
	fmt.Println("body:",string(body))
	fmt.Println("header:",response.Header)

	//http.NewRequest()
}

