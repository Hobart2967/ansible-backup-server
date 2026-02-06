#!/bin/bash

main () {
  if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters. Usage: ./provision.sh <ip> <user> <keePassKdbxFile>"
    return
  fi

  echo "Provisioning machine '$1'"
  ssh-copy-id $2@$1
  ansible-playbook -i "$1," provision-machine.yml --user $2 --diff --ask-become-pass --extra-vars "machine=$1"
}


DIR=$(pwd)
setup

cd $DIR
main "$@"