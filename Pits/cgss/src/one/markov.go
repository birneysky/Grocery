package one

import "strings"

type Prefix []string

func (p Prefix) Strings() string {
	return strings.Join(p,"")
}

func (p Prefix) Shift(word string) {
	copy(p, p[1:])
	p[len(p)-1] = word
}

type chanin	

