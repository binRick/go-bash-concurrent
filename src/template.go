package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"text/template"
)

type Section struct {
	Title string
}
type TempateObject struct {
	Pre  Section
	Main Section
	Post Section
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
	err = Template.Execute(&buf, TempateObject{
		Pre:  Section{Title: `P`},
		Main: Section{Title: `M`},
		Post: Section{Title: `Pose`},
	})

	f(err)
	r := fmt.Sprintf(`%s`, &buf)
	return r
}
