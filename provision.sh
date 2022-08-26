#!/bin/bash

main () {
  if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters. Usage: ./provision.sh <ip> <user> <keePassKdbxFile>"
    return
  fi

  echo "Provisioning machine '$1'"
  ssh-copy-id $2@$1
  ansible-playbook -i "$1," provision-machine.yml --user $2 --diff --ask-become-pass --extra-vars "keepass_dbx=$3" --extra-vars "machine=$1"
}

setup() {
  pip install 'pykeepass==4.0.3' --user
  ansible-galaxy collection install viczem.keepass
}

DIR=$(pwd)
setup

cd $DIR
main "$@"