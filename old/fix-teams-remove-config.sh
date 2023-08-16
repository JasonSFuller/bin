#!/bin/bash

# old teams client on flathub (before "official" client was released) 
# ...well, she had problems and would crash, especially when the palo 
# alto would suddenly expire my session and force a login page to all 
# http traffic.  this removed the cruft and got her limping again.

while ps -ef | grep '[t]eams-for-linux'
do
  pids=$(pgrep -f teams-for-linux | tr '\n' ' ')
  echo -e "\npids = $pids\n"
  kill $pids
  sleep 1
done

rm -rf ~/.var/app/com.github.IsmaelMartinez.teams_for_linux/config/teams-for-linux

