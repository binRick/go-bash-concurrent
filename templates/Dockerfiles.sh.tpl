#!/usr/bin/env bash
set -e -o pipefail
cd $(dirname "${BASH_SOURCE[0]}")
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.concurrent.lib.sh"

create_vm(){ sleep $@; }
restore_data(){ sleep $@; }
my_sleep(){ sleep $@; }

__pre() {
# title: {{ printf "%s" .Pre.Title }}
  true
}
__main() {
# title: {{ printf "%s" .Main.Title }}
  true
}
__post() {
# title: {{ printf "%s" .Post.Title }}
  true
}
__pre && __main && __post

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
