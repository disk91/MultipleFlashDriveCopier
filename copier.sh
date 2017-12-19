#!/bin/bash
if [ $# -ne 1 ] ; then
  echo $0 source_file_location_dir
  return 1
fi
source="$1"

# mount the device given as parameter and copy the file... at end unmount
run() {

  tmp=`mktemp -d`
  mount $1 $tmp
  cp -R $source/* $tmp/
  umount $tmp
  rmdir $tmp
}

# scan for new device
mounted=""
available=""
running=""
while true ; do
  # ####
  # CHECK FOR DEVICE CONNECTION
  available=`ls /dev/sd*1 2> /dev/null`
  for a in $available ; do
    found=0
    for m in $mounted ; do
       if [ $a == $m ] ; then
         found=1
       fi
    done
    if [ $found -ne 1 ] ; then
       echo "new device $a detected"
       mounted="$mounted $a"
       run $a &
       running="$running $!"
    fi
  done
  # ####
  # CHECK FOR COPY PROCESS STATUS
  found=0
  for p in $running ; do
     if kill -0 $p 2>/dev/null ; then
        found=$(( $found + 1 ))
     fi
  done
  if [ $found -eq 0 ] ; then
     echo '*** ALL STICKS HAVE BEEN FLASHED ***'
  else
     echo " Running... $found"
  fi

  # ####
  # CHECK FOR REMOVED DEVICES
  m2=""
  for m in $mounted ; do
    found=0
    for a in $available ; do
       if [ $a == $m ] ; then
          m2="$m2 $m"
          found=1
       fi
    done
    if [ $found -ne 1 ] ; then
      echo "device retired $m"
      # action
    fi
  done
  mounted=$m2
  if [ -z "$mounted" ] ; then
    echo '*** ALL KEY REMOVED ***'
  fi
  sleep 2

done



