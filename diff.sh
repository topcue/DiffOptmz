#!/bin/bash

WORKSPACE="$HOME/DiffOptmz"
PATH_A=$WORKSPACE/$1
PATH_B=$WORKSPACE/$2

if [ $# -eq 2 ]; then
  for file in `find $PATH_A/ -type f -printf '%P\n'`; do
    hashA=`md5sum $PATH_A/$file | awk '{print $1}'`
    hashB=`md5sum $PATH_B/$file | awk '{print $1}'`
    if test $hashA != $hashB; then
      echo "<> $file"
    else
      echo "== $file"
    fi
  done
fi

# EOF

