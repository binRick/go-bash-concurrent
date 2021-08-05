#!/usr/bin/env bash
set -e -o pipefail
cd "$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
source .concurrent.lib.sh
source .optparse.bash
source .ansi.sh

optparse.define short=C long=concurrent-build desc="Build Container Concurrency" variable=CONCURRENT_BUILD value=1 default=0
parse_args(){ source $(optparse.build); }
create_vm(){ sleep $@; }
restore_data(){ sleep $@; }
my_sleep(){ sleep $@; }

{{range  .Sections}}
__{{.Fxn}}(){
  ansi --{{.FxnTitleColor}} --{{.FxnTitleStyle}} "$(printf "%s" "{{.FxnTitle}}")"
  true
}
# /{{ . }}
{{end}}
__do_main
__do_main(){
  __pre && __main && __post
}

do_concurrent() {
    local args=(
        - "Creating VM"                                         create_vm    3.0
        - "Creating ramdisk"                                    my_sleep     0.1
        - "Enabling swap"                                       my_sleep     0.1
        - "Populating VM with world data"                       restore_data 5.0
        - "Spigot Pulling docker image for build"              my_sleep     0.5
        - "Spigot Building JAR"                                my_sleep     6.0
        - "Pulling remaining docker images"                     my_sleep     2.0
        - "Launching services"                                  my_sleep     0.2

        --require "Creating VM"
        --before  "Creating ramdisk"
        --before  "Enabling swap"

        --require "Creating ramdisk"
        --before  "Populating VM with world data"
        --before  "Spigot Pulling docker image for build"

        --require "Spigot Pulling docker image for build"
        --before  "Spigot Building JAR"
        --before  "Pulling remaining docker images"

        --require "Populating VM with world data"
        --require "Spigot Building JAR"
        --require "Pulling remaining docker images"
        --before  "Launching services"
    )

    concurrent "${args[@]}"
}

#do_concurrent
parse_args
__do_main
