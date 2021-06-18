#!/bin/bash

usage()
{
  echo 'Usage: clone.bash <ID of original Linode> <name of new Linode> [<size of new Linode>]'
}

if [ $# -lt 2 ] || ! [[ $1 =~ ^[0-9]+$ ]]; then
  usage; exit 1
fi

if ! [[ -x "$LINODE_CLI" ]]; then
  echo Please define LINODE_CLI as full path to linode-cli executable
  exit 1
fi

echo ===========
echo clone.bash started at `date`
echo

original=$1
new_name=$2
new_size=${3:-g6-standard-2}

echo shutting down $original
$LINODE_CLI linodes shutdown $original || {
  echo shutdown failed
  exit 1
}

while : ; do
  $LINODE_CLI linodes list | grep $original | grep offline
  if [ "$?" -eq 0 ]; then
    break
  fi
  echo still shutting down
  sleep 5
done
echo shut-down of $original complete

echo cloning $original to $new_name as $new_size
$LINODE_CLI linodes clone $original --label $new_name --type $new_size

while : ; do
  $LINODE_CLI linodes list | grep $original | grep cloning
  if [ "$?" -ne 0 ]; then
    break
  fi
  echo still cloning
  sleep 5
done
echo done cloning–will boot $original up again

$LINODE_CLI linodes boot $original
