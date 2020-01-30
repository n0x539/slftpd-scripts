#no-slres.tcl 
# search and replace "/home/<ATUSER>/bin/restart_sl.sh" to your script :eek:

#/topic -=[ timereset : !restim ]=-  -=[ restart : !ressl !killsl ]=-  -=[ status : !status !resstat !killstat ]=-


###
# config
###

# set slnick to the nickname of slftp
set slnick      "slftpdbot"

# restart after not recieving RACE for x seconds (3600s=1h)
set restim	"3600"

# adminchan for msging site invite
# - add each site w/o bnc (chg/edit example at no:noslres:invite) 
#  _NOT_ recommended, but requested. m(
set adminchan    "#myslftpdchan"



###
# end of config
###



### base sets
set noslres     "v20121018"
set nocod       "noname"
set gsecs	"0"



### bind res
bind pub  -|- RACE              no:noslres:timerreset
bind pub  -|- !restim           no:noslres:timerreset
bind pub  -|- !ressl            no:noslres:restartslinfo
bind pub  -|- !killsl           no:noslres:restartslinfo
bind pub  -|- !status           no:noslres:status
bind pub  -|- !resstat          no:noslres:status
bind pub  -|- !killstat         no:noslres:status
bind part -|- *                 no:noslres:parted
bind sign -|- *                 no:noslres:parted
bind pubm -|- {*SITE*IS*UP*}    no:noslres:invite



### invite
proc no:noslres:invite {nick uhost handle chan arg} {
global adminchan
if {"$chan"=="$adminchan"} {
  if {[string match "*SITE1*" [lindex $arg 1]]=="1"} {
   putquick "PRIVMSG $adminchan :!raw SITE1 site invite NICK1"
  }
 }
}



### reset timer
proc no:noslres:timerreset {nick uhost handle chan arg} {
 global gsecs restim
 set gsecs "0"
# putquick "PRIVMSG $chan :\[NOSLRES\] Timer has been reseted to $restim seconds."
}



### restart sl info
proc no:noslres:restartslinfo {nick uhost handle chan arg} {
 global gsecs runcur adminchan
 set gsecs "0"
 set runcur "0"
 putquick "PRIVMSG $adminchan :\[NOSLRES\] slftp will be restarted in 10 seconds."
 putquick "PRIVMSG $adminchan :!backup"
 after 10000 no:noslres:restartslbash l a z y .
}



### restart sl bash/kill
proc no:noslres:restartslbash {nick uhost handle chan arg} {
 set bashlog [exec /home/<ATUSER>/bin/restart_sl.sh]
 if {[info exists bashlog]} {
  foreach line $bashlog {
   putquick "PRIVMSG $adminchan :\[NOSLRES\] $line"
  }
 } else {
  putquick "PRIVMSG $adminchan :\[NOSLRES\] we have a problem houston."
 }
}



### check it
proc no:noslres:whileislame {} {
global restim gsecs utimer_id runtot runcur
 if { $restim >= $gsecs } {
   incr gsecs
   incr runtot
   incr runcur
 } else {
  no:noslres:restartslinfo l a z y .
 }
 set utimer_id [utimer 1 no:noslres:whileislame]
}



### status
proc no:noslres:status {nick uhost handle chan arg} {
 global parted runcur runtot restim gsecs
 if { $parted > 0 } {
  set partedeach "[duration [expr $runtot / $parted]]"
 } else {
  set partedeach "na"
 }
 putquick "PRIVMSG $chan :\[NOSLRES\] slftp has been..."
 putquick "PRIVMSG $chan :\[NOSLRES\]  parted $parted times  ::  (each $partedeach)"
 putquick "PRIVMSG $chan :\[NOSLRES\]  up for [duration $runcur]  ::  (total [duration $runtot])"
 putquick "PRIVMSG $chan :\[NOSLRES\] slftp..."
 putquick "PRIVMSG $chan :\[NOSLRES\]  got its last RACE :: [duration $gsecs]"
 putquick "PRIVMSG $chan :\[NOSLRES\]  will be killed in :: [duration [expr $restim - $gsecs]]"
}



### parted
proc no:noslres:parted {nick uhost handle chan arg} {
 global parted slnick adminchan
 if {"$chan"=="$adminchan"} {
  if {"$nick"=="$slnick"} {
   incr parted
  }
 }
}



putlog "SLFTPD RESTARTER $noslres loaded. (coded by $nocod)"



#init
if {[info exists utimer_id]} { killutimer $utimer_id } else {
 set parted     "0"
 set runcur	"0"
 set runtot	"0"
}
set utimer_id [utimer 1 no:noslres:whileislame]



### EOF ### /1337? yea.. a bit.
