package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"strings"
	"text/template"
)

func (b *BashSection) FxnTitle() string {
	return b.Title
}
func (b *BashSection) FxnTitleStyle() string {
	return fmt.Sprintf(`%s`, `underline`)
}
func (b *BashSection) FxnTitleColor() string {
	return fmt.Sprintf(`%s`, `yellow`)
}
func (b *BashSection) Fxn() string {
	return strings.ToLower(b.Title)
}

type BashSection struct {
	Title string
}
type TempateObject struct {
	Pre      BashSection
	Main     BashSection
	Post     BashSection
	Sections []BashSection
}

func Must(dat interface{}, err error) interface{} {
	f(err)
	return dat
}

func f(err error) {
	if err == nil {
		return
	}
	panic(err)
}

var template_path = `../templates/Dockerfiles.sh.tpl`

func RenderTemplate() string {
	template_contents, err := ioutil.ReadFile(template_path)
	f(err)
	Template, err := template.New("TempateObject1").Parse(string(template_contents))
	//              Host:       {{ printf "%s" .TlsListenHost }}

	f(err)
	var buf bytes.Buffer
	pre := BashSection{Title: `pre`}
	_main := BashSection{Title: `Main`}
	post := BashSection{Title: `Post`}
	err = Template.Execute(&buf, TempateObject{
		Pre:      pre,
		Main:     _main,
		Post:     post,
		Sections: []BashSection{pre, _main, post},
	})

	f(err)
	r := fmt.Sprintf(`%s`, &buf)
	return r
}
