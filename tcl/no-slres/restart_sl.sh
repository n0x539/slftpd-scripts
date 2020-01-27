#!/bin/bash
# bins needed: ps grep sed awk 
# start your slftp with screen/tmux/...: "until false;do sleep 2;cd ~/bin/;./slftp_x64;done"
###
# config
###
SLBIN="slftp_x64"
###
# end of config
###

ps x | grep ${SLBIN} | grep -v grep | sed 's/\s/_/g'
kill -9 $(ps x | grep ${SLBIN} | grep -v grep | awk {'print $1'})
echo "--killed--"
sleep 2
ps x | grep ${SLBIN} | grep -v grep | sed 's/\s/_/g'

#EoF# /1337? nah.. not a byte.
