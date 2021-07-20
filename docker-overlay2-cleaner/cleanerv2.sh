#!/bin/bash
get_subdirs () {
  for dir in $(du -sch $1/* | grep $2 | awk '{print $2}')
  do
    if [ $dir != "total" ]
    then
      if [ -d "$dir" ]
      then
        get_subdirs "$dir" "$2"
      fi
    fi
  done
  if [[ $1 =~ "/tmp" ]]
  then
      subdirs+=$1$'\n'
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

if [ -d /var/log/docker-overlay2 ]
then
  mkdir -p /var/log/docker-overlay2
fi

get_subdirs "$basedir" "$size_limit"
for subdir in $subdirs
do
  #add -v option
  #DEBUG option
  #printf "$(find $subdir -maxdepth 1 -type f -ctime +30 -printf '$(date) Ctime: %Cd/%Cm/%Cy\t%k KB\t%p\n')" | gawk '{ print strftime("%Y-%m-%d %H:%M:%S\t"), $0 }'
  printf "$(find $subdir -maxdepth 1 -type f -ctime +30 -printf 'Ctime: %Cd/%Cm/%Cy\t%k KB\t%p\n')" | gawk '{ print strftime("%Y-%m-%d %H:%M:%S\t"), $0 }' >> /var/log/docker-overlay2/output.log
  find $subdir -maxdepth 1 -type f -ctime +30 -delete
  find $subdir -maxdepth 1 -type f -regextype sed -regex "./core\.[0-9][0-9]*" -delete
done