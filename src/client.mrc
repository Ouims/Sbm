alias sbmclientconnect {
  sockclose sbmclient
  hadd sbm sockstate -1
  sockopen -46 sbmclient $1-2
  sockmark sbmclient $3
}
on *:sockopen:sbmclient:{
  if (!$sockerr) {
    sockwrite -n $sockname NICK $sock($sockname).mark
    sockwrite -n $sockname OWNER $hget(sbmserv,owner)
  }
  else {
    hadd sbm sockstate $sockerr $sock($sockname).wserr $sock($sockname).wsmsg
    if ($hget(sbmserv)) sbmserv stop
  }
}
on *:sockread:sbmclient:{
  if (!$sockerr) {
    var %a
    sockread %a
    if (!$sockbr) return
    tokenize 32 %a
    echo -s serv - $1-

    if ($1 === WELCOME) {
      hadd -m sbm nick $2
      sockmark $sockname $2
      sbmchangeview lobby
      sbmaddtext $asctime($ctime,[HH:nn:ss]) * Welcome to the server, users connected: $str($chr(160),3) $hget(sbm,nicks)
    }
    elseif ($1 == nicks) {
      hadd sbm $1-
    }
    elseif ($1 == mypid) {
      hadd sbm $1-
    }
    elseif ($1 == nicksid) {
      hadd sbm $1-
    }
    elseif ($1 == flushbonuses) {
      ; echo -s $1-
      if (!$hget(sbm,item $+ $2)) && (!$hget(sbm,item $+ $mid($2,2))) {
        echo -s * sbm: missed a bonus in time
      }
      else hadd sbm flushbonuses $+ $2-
    }
    elseif ($1 == bomb) {
      ;echo -s $1-
      hadd sbm item $+ $2-6 $ticks $8
      hadd sbm items $2 $hget(sbm,items)
      hadd sbmmap $+($calc($3 // 16),.,$calc($4 // 16)) 99
    }
    elseif ($1 == addidsitems) {
      hadd sbm items $hget(sbm,items) $2-
    }
    elseif ($1 == delidsitems) {
      tokenize 32 $2-
      sbmdelidsitems $*
    }
    elseif ($1 == setidsitems) {
      hadd sbm items $2-
    }
    elseif ($1 == join) {
      sbmaddtext $asctime($ctime,[HH:nn:ss]) * $2 joined the server
    }
    elseif ($1 == owner) hadd sbm owner 1
    elseif ($1 == quit) {
      sbmaddtext $asctime($ctime,[HH:nn:ss]) * $2 left the server
    }
    elseif ($1 == map) {
      tokenize 92 $2-
      hadd -m sbmmap $*
      window -pdBfCfh +l @sbmbuf -1 -1 800 400
      window -pdh @sbmtiles -1 -1 800 800
      drawsize @sbmtiles 1088 124
      drawpic -c @sbmtiles 0 0 $qt($scriptdirassets\sbm.png)
      drawrect -fr @sbmbuf 3168272 0 0 0 800 400
      noop $hfind(sbmmap,*,0,w,sbmdrawmap $1)
      sbmchangeview game
    }
    elseif ($1 == positions) {
      set %sbmticks $ticks
      tokenize 92 $2-
      sbmadditem $* 
    }
    elseif ($1 == nick_error) {
      hadd sbm sockstate -2
      ;if ($hget(sbmserv)) sbmserv stop
    }
    elseif ($1 == text) {
      sbmaddtext $+([,$asctime($2,HH:nn:ss),]) $+(<,$3,>) $4-
      if ($hget(sbmoptions,flashonhl)) && ($3 != $hget(sbm,nick)) && ($regex($4-,/(?:\B@|\b)\Q $+ $replacecs($hget(sbm,nick),\E,\E\\E\Q) $+ \E\b/Si)) flash @sbm
    }
    elseif ($1 == player) { echo -s here $2-
      hadd sbm player $+ $2-
    }
  }
} 
on *:sockclose:sbmclient:{
  sbmchangeview $iif($hget(sbmserv),create,connect)
  if ($hget(sbmserv)) sbmserv stop
  if ($hget(sbm,sockstate) != -2) hadd sbm sockstate -3 $sockerr $sock($sockname).wsmsg
}
alias sbmadditem {
  if (4* iswm $1) {
    if ($hget(sbm,item $+ $1) == $null) {
      hadd sbm item $+ $1-5 $ticks $7
      hadd sbm items $hget(sbm,items) $1
    }
    else hadd sbm item $+ $1-
  }
  else hadd sbm item $+ $1-
}
alias sbmdelitem hdel sbm item $+ $1- 
alias sbmdelidsitems hadd sbm items $remtok($hget(sbm,items),$1,32) | hdel sbm item $+ $1 
alias sbmdrawmap {
  var %h $hget(sbmmap,$1),%v $1
  tokenize 46 $1
  if (%h == 3) drawpic -ct @sbmbuf 3168272 $calc($1 * 16 + 300) $calc($2 * 16) $calc(16 * 57) $calc(6 * 16) 16 16 $qt($scriptdirassets\sbm.png)
  elseif (%h == 1) {
    drawpic -ct @sbmbuf 3168272 $calc($1 * 16 + 300) $calc($2 * 16) $calc(16 * 58) $calc(6 * 16) 16 16 $qt($scriptdirassets\sbm.png)
    ;if ($hget(sbmmap,$+($1,.,$calc($2 + 1))) == $null) && ($2 < $gettok($hget(sbmmap,mapsize),2,32)) drawpic -c @sbmbuf $calc($1 * 16 + 300) $calc($2 * 16 + 16) $calc(16 * 58) $calc(6 * 16) 16 16 $qt($scriptdirassets\sbm.png)
  }
}