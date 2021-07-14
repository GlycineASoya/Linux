#!/bin/bash 
get_subdirs () {
  #false - get the list of subdirs with the files inside
  #true - get all subdirs
  needWriteToResult=false
  for dir in $(du -sch $1/* 2>>/dev/null | grep $2 | awk '{print $2}')
  do
    if [ $dir != "total" ]
    then
      if [ -d "$dir" ]
      then
        needWriteToResult=false
        get_subdirs "$dir"
      else
        needWriteToResult=true
      fi
    fi
  done
  if [ $needWriteToResult == true ]
  then
      subdirs+=$1$'\n'
      needWriteToResult=false
  fi
}

if [ "$1" == "--help" ]
then
  echo -e "Units are K, M, G,  T,  P,
       E, Z, Y (powers of 1024) or KB, MB, ... (powers of 1000).
       (man du for more)"
  exit 1
elif [ "$#" != "2" ]
then
  echo -e "Usage of the script:\t$0 basedir size-limit\n"
  exit 1
else
  if [[ "$1" == */ ]]
  then
    basedir="${1:0:-1}"
  else
    basedir="$1"
  fi
  size_limit="$2"
fi

get_subdirs "$basedir" "$size_limit"
for subdir in $subdirs
do
  echo "$subdir"
  find $subdir -maxdepth 1 -type f -ctime +30 -delete
  find $subdir -maxdepth 1 -type f -regextype sed -regex "./core\.[0-9][0-9]*" -delete
done