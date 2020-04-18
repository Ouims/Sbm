alias sbmserv {
  if ($1 == stop) || ($2 == restart) { 
    sockclose sbmclient?*
    sockclose sbmserv
    hfree -w sbmservmap
    hfree -w sbmserv
    .timersbmserv off
    if ($1 == stop) return
  }
  if ($1 != stop) {
    socklisten -p sbmserv $1
    ;  if ($scon(1).status == connected) { scon 1 | msg #mirc sbm:// $+ $ip $+ :8000 }
    hadd -m sbmserv owner $md5($ticks)
    hadd sbmserv state lobby
  }
}
on *:socklisten:sbmserv:{
  hinc -m sbmserv connect
  var %c sbmwclient $+ $hget(sbmserv,connect)
  sockaccept %c
}
on *:sockclose:sbmclient?*:{
  sbmserv_quit $sock($sockname).mark
}
on *:sockwrite:sbmwclient?*:{
  if ($sock($sockname).sq == 0) {
    if ($istok($hget(sbmserv,quit),$sockname,32)) {
      hadd sbmserv quit $remtok($hget(sbmserv,quit),$sockname,32)
      sockclose $sockname
    }
  }
}
on *:sockread:sbmwclient?*:{
  if (!$sockerr) {
    var %a
    sockread %a
    if (!$sockbr) return
    tokenize 32 %a
    if ($1 === NICK) {
      if ($istok($hget(sbmserv,nicks),$2,32)) || ($2 == $null) || (!$isutf($2)) || ($regex($2,/[ \x01–\x1F]|\xED[\xA0-\xAF][\x80-\xBF]|\xED[\xB0-\xBF][\x80-\xBF]/)) {
        sockwrite -n $sockname nick_error
        hadd sbmserv quit $hget(sbmserv,quit) $sockname
      }
      else {
        var %n $2,%id $md5($ticks)
        hadd sbmserv nicks $hget(sbmserv,nicks) %n
        hadd sbmserv nicksid $hget(sbmserv,nicksid) %id
        sockmark $sockname %id
        if ($sock(sbmclient?*,0)) sockwrite -n sbmclient?* join %n
        sockrename $sockname $remove($sockname,w)
        sockwrite -n sbmclient?* nicks $hget(sbmserv,nicks)
        sockwrite -n sbmclient?* nicksid $hget(sbmserv,nicksid)
        if ($hget(sbmserv,player1) != $null) sockwrite -n sbmclient?* player 1 $sbmserv_gnfid($v1)
        if ($hget(sbmserv,player2) != $null) sockwrite -n sbmclient?* player 2 $sbmserv_gnfid($v1)
        if ($hget(sbmserv,player3) != $null) sockwrite -n sbmclient?* player 3 $sbmserv_gnfid($v1)
        if ($hget(sbmserv,player4) != $null) sockwrite -n sbmclient?* player 4 $sbmserv_gnfid($v1)
        sockwrite -n $sockname WELCOME %n
      }
    }
    else {
      if (!$istok($hget(sbmserv,quit),$sockname,32)) sockclose $sockname
    }
  }
}
alias sbmserv_quit {
  sockclose $sbmserv_gsfid($1)
  var %n $findtok($hget(sbmserv,nicksid),$1,32),%nick $sbmserv_gnfid($1)
  hadd sbmserv nicksid $deltok($hget(sbmserv,nicksid),%n,32)
  hadd sbmserv nicks $deltok($hget(sbmserv,nicks),%n,32)
  var %a 1
  while (%a <= 4) {
    if ($hget(sbmserv,player $+ %a) == $1) { 
      hdel sbmserv player $+ %a
      sockwrite -n sbmclient?* player %a
      break
    }
    inc %a
  }
  if ($1) {
    sockwrite -n sbmclient?* quit %nick
    sockwrite -n sbmclient?* nicks $hget(sbmserv,nicks)
    sockwrite -n sbmclient?* nicksid $hget(sbmserv,nicksid)
  }
  if ($hget(sbmserv,ownerid) == $1) sbmserv stop
}
alias sbmserv_gnfid return $gettok($hget(sbmserv,nicks),$findtok($hget(sbmserv,nicksid),$1,32),32)
alias sbmserv_gsfid {
  var %a 1,%v
  while ($sock(sbmclient?*,%a) != $null) {
    %v = $v1
    if ($sock($v1).mark == $1) return %v
    inc %a 
  }
}
on *:sockread:sbmclient?*:{
  if (!$sockerr) {
    var %a
    sockread %a
    if (!$sockbr) return
    tokenize 32 %a
    var %id $sock($sockname).mark,%nick $sbmserv_gnfid(%id)
    ;  echo -st client ( $+ %nick $+ ) - $1- -- %id == $hget(sbmserv,ownerid) $hget(sbmserv,state)
    if ($1 == owner) {
      echo -s $2 == $hget(sbmserv,owner)
      if ($2 == $hget(sbmserv,owner)) {
        hadd sbmserv ownerid %id
        sockwrite -n $sockname owner
      }
    }
    elseif ($1 == moved) {
      if (!$istok($hget(sbmserv,stack $+ %id),$2,32)) {
        if ($2 == 32) hadd sbmserv stack $+ %id $hget(sbmserv,stack $+ %id) $2
        else hadd sbmserv stack $+ %id $2 $hget(sbmserv,stack $+ %id)
      }
    }
    elseif ($1 == moveu) {
      hadd sbmserv stack $+ %id $remtok($hget(sbmserv,stack $+ %id),$2,32)

    }
    elseif ($1 == leavek) hadd sbmserv stack $+ %id
    elseif ($1 == ready) && ($hget(sbmserv,state) != ready) && ($hget(sbmserv,ownerid) == %id) {
      hadd sbmserv state ready
      sbmserv_makemap
      ;noop $hfind(sbmservmap,3,w,0,hadd sbmservmap $1 0).data
      noop $hfind(sbmservmap,*,0,w,var %map %map $1 $hget(sbmservmap,$1) $+ \)
      var %a 4
      while (%a) {
        if ($hget(sbmserv,player $+ %a)) {
          hadd sbmserv items $hget(sbmserv,items) %a
          hadd -m sbmserv fire $+ %a 2
          hadd -m sbmserv bomb $+ %a 500
          hadd -m sbmserv nbbomb $+ %a 500
          hadd -m sbmserv speed $+ %a 1
          sockwrite -n $sbmserv_gsfid($v1) mypid %a
          hadd sbmserv item $+ %a $gettok(16 16 0\208 176 0\208 16 0\16 176 0,%a,92)
        }
        dec %a
      }
      sockwrite -n $matchkey map %map
      sockwrite -n $matchkey setidsitems $hget(sbmserv,items)
      sbmserv_mainloop
    }
    elseif ($1 === TEXT) sockwrite -n sbmclient?* text $ctime $iif(%id == $hget(sbmserv,ownerid),~) $+ %nick $2-
    elseif ($1 == slpl) {
      if ($3) {
        if ($hget(sbmserv,player $+ $2) == $null) {
          hadd sbmserv player $+ $2 %id
          sockwrite -n $matchkey player $2 %nick
        }
      }
      else {
        if ($hget(sbmserv,player $+ $2) == %id) {
          hadd sbmserv player $+ $2
          sockwrite -n $matchkey player $2
        }
      }
    }
  }
  else mpserv_quit $sock($sockname).mark
}
alias sbmserv_sendsockdata {
  tokenize 32 $hget(sbmserv,items)
  sbmserv_getsockdataitems $*
  sockwrite -n sbmclient*? positions %sbmservsockdata
}
alias sbmserv_getsockdataitems if (4?* iswm $1) return | set -u %sbmservsockdata $addtok(%sbmservsockdata,$1 $hget(sbmserv,item $+ $1),92)
alias sbmserv_mainloop {
  var %t $ticks
  tokenize 32 $hget(sbmserv,items)
  sbmserv_handleitems $*
  var %s 1
  hadd sbmserv gameticks $ticks
  sbmserv_handlebombs
  sbmserv_handlefires
  if (%s) sbmserv_sendsockdata
  ; echo -s $calc($ticks - %t)
  .timersbmserv -ho 1 0 if (!$isalias(sbmserv_mainloop)) .timersbmserv -ho 1 0 $!timer(sbmserv).com $(|) else sbmserv_mainloop
}
alias sbmserv_handleitems {
  var %id $1,%debug 1
  if ($1 isnum 1-4) {
    tokenize 32 $hget(sbmserv,item $+ $1)
    var %speed $hget(sbmserv,speed $+ %id),%m $gettok($hget(sbmserv,stack $+ $hget(sbmserv,player $+ %id)),1,32),%ans 1,%ans1 -1
    var %x $1,%y $2
    if (%m == 37) dec %x %speed
    elseif (%m == 39) inc %x %speed
    if (%m == 38) dec %y %speed
    elseif (%m == 40) inc %y %speed
    if (%m != 32) {
      if (%m != $null) sbmserv_movep $+ $replace(%m,37,left,39,right,38,up,40,down) %ans %ans1 %x %y %speed %id
      hadd sbmserv item $+ %id $gettok($hget(sbmserv,item $+ %id),1-2,32) %m
    }
    if ($istok($hget(sbmserv,stack $+ $hget(sbmserv,player $+ %id)),32,32)) && ($hget(sbmserv,bomb $+ %id)) {
      var %+x 7,%+y 7
      if (%m == 38) inc %+y
      elseif (%m == 37) inc %+x
      tokenize 32 $hget(sbmserv,item $+ %id)
      var %idb 4 $+ %id $+ $ticks,%x $calc(($1 + %+x) // 16), %y $calc(($2 + %+y) // 16)
      if (!$hget(sbmservmap,$+(%x,.,%y))) {
        if (%debug) echo -s drop bomb at %x %y
        hadd sbmserv bombs $addtok($hget(sbmserv,bombs),%idb,32)
        hadd sbmservmap $+(%x,.,%y) 99
        hdec sbmserv bomb $+ %id
        hadd sbmserv item $+ %idb $hget(sbmserv,fire $+ %id) 9 %x %y $ticks %id
        sockwrite -n sbmclient?* bomb %idb $hget(sbmserv,fire $+ %id) 9 %x %y $ticks %id
      }
    }
  }
}
alias sbmserv_handlefires {
  tokenize 32 $hget(sbmserv,fires)
  sbmserv_handlefire $*
}
alias sbmserv_handlefire {
  var %id $1
  if ($calc($ticks - $hget(sbmserv,fireticks $+ %id)) >= 600) {
    echo -s sexplode $ticks
    var %h $gettok($hget(sbmserv,fire $+ %id),1,46)
    hdel sbmservmap $+($calc($gettok(%h,1,32) // 16),.,$calc($gettok(%h,2,32) // 16))
    hdel sbmserv fire $+ %id
    hdel sbmserv fireticks $+ %id
    tokenize 92 $hget(sbmserv,flushbonuses $+ %id)
    hadd sbmservmap $*
    hdel sbmserv flushbonuses $+ %id
    hadd sbmserv fires $remtok($hget(sbmserv,fires),%id,32)
    return
  }
}
alias sbmserv_handlebombs {
  tokenize 32 $hget(sbmserv,bombs)
  sbmserv_handlebomb $*
}
alias sbmserv_handlebomb {
  var %id $1,%id1 $6
  tokenize 32 $hget(sbmserv,item $+ $1)
  if ($calc($ticks - $5) >= 235) {
    if ($2 == 1) {
      var %list1
      ;a corriger: les bombes qui exploses avant doivent être modifié a la fin pour le prochain cycle
      var %a $3 - 1,%c $1 - 1
      while (%c) && ($hget(sbmservmap,$+(%a,.,$4)) != 1) {
        if ($v1 == 3) {
          %list1 = $addtok(%list1,%a $4,46)
          break 
        }
        elseif ($v1 > 3) {
          if ($v1 == 99) noop $hfind(sbmserv,^\d+ \d+ %a $4 \d+$,0,r,hadd sbmserv $1 $puttok($puttok($hget(sbmserv,$1),1,2,32),$calc($ticks -40),5,32)).data
          else hdel sbmservmap $+(%a,.,$4)
          break      
        }
        dec %a
        dec %c
      }
      var %a $3 + 1,%c $1 - 1
      while (%c) && ($hget(sbmservmap,$+(%a,.,$4)) != 1) {
        if ($v1 == 3) {
          %list1 = $addtok(%list1,%a $4,46)
          var %no 1
          break 
        }
        elseif ($v1 > 3) {
          if ($v1 == 99) noop $hfind(sbmserv,^\d+ \d+ %a $4 \d+$,0,r,hadd sbmserv $1 $puttok($puttok($hget(sbmserv,$1),1,2,32),$calc($ticks -40),5,32)).data
          else hdel sbmservmap $+(%a,.,$4)
          break      
        }
        inc %a
        dec %c
      }
      var %a $4 - 1,%c $1 - 1
      while (%c) && ($hget(sbmservmap,$+($3,.,%a)) != 1) {
        if ($v1 == 3) {
          %list1 = $addtok(%list1,$3 %a,46) 
          break
        }
        elseif ($v1 > 3) {
          if ($v1 == 99) noop $hfind(sbmserv,^\d+ \d+ $3 %a \d+$,0,r,hadd sbmserv $1 $puttok($puttok($hget(sbmserv,$1),1,2,32),$calc($ticks -40),5,32)).data
          else hdel sbmservmap $+($3,.,%a)
          break      
        }
        dec %a
        dec %c
      }
      var %a $4 + 1,%c $1 - 1
      while (%c) && ($hget(sbmservmap,$+($3,.,%a)) != 1) {
        if ($v1 == 3) {
          %list1 = $addtok(%list1,$3 %a,46)
          break
        }
        elseif ($v1 > 3) {
          if ($v1 == 99) noop $hfind(sbmserv,^\d+ \d+ $3 %a \d+$,0,r,hadd sbmserv $1 $puttok($puttok($hget(sbmserv,$1),1,2,32),$calc($ticks -40),5,32)).data
          else hdel sbmservmap $+($3,.,%a)
          break      
        }
        inc %a
        dec %c
      }
      if ($hget(sbmserv,bomb $+ $6) < $hget(sbmserv,nbbomb $+ $6)) hinc sbmserv bomb $+ $6
      hdel sbmserv item $+ %id
      hdel sbmservmap $+($3,.,$4)
      hadd sbmserv bombs $remtok($hget(sbmserv,bombs),%id,32)
      hadd sbmserv fires $addtok($hget(sbmserv,fires),5 $+ %id,32)
      ;rebuild %list for collision
      ;hadd sbmserv fire $+ 5 $+ %id %list
      hadd sbmserv fireticks $+ 5 $+ %id $ticks
      tokenize 46 %list1
      sbmserv_addbonuses %id $*
      if ($regsubex($hget(sbmserv,flushbonuses $+ 5 $+ %id),/(?:^|\\)\d+\.\d+(?=\\|$)/,)) sockwrite -n sbmclient?* flushbonuses 6 $+ %id $v1
      return
    }
    hadd sbmserv item $+ %id $1 $calc($2 - 1) $3-4 $ticks $6
  }
}
alias sbmserv_addbonuses {
  if ($r(0,1)) {
    var %a $hfind(sbmservmap,9,0,w).data,%b
    if (%a) { 
      while ($r(4,9) == 9) /
      var %v $v1
    }
    else var %v $r(4,9)
    ; echo -s bonus at $+($calc($1 // 16),.,$calc($2 // 16)) %v
    hadd sbmserv flushbonuses $+ 5 $+ $1 $addtok($hget(sbmserv,flushbonuses $+ 5 $+ $1),$2. $+ $3 %v,92)
  }
  else hadd sbmserv flushbonuses $+ 5 $+ $1 $addtok($hget(sbmserv,flushbonuses $+ 5 $+ $1),$2. $+ $3,92)
}
alias sbmserv_movepleft {
  var %id $6
  var %x1 $hget(sbmservmap,$+($calc($3 // 16),.,$calc(($4 + 1) // 16)))
  var %x2 $hget(sbmservmap,$+($calc($3 // 16),.,$calc(($4 + 14) // 16)))
  var %x $3,%y $4
  if (%x1) || (%x2) {
    var %l $calc(($4 + 14) // 16 * 16 - $4)
    var %l1 $calc(($4 + 1) // 16 * 16 - $4)
    if (%x1) && ((!%x2) || (%x2 > 3)) && (%l1 < $2) var %m down
    elseif (%x2) && ((!%x1) || (%x1 > 3)) && (%l > $1) var %m up
    if (99 99 == %x1 %x2) var %b $calc(($3 // 16 + 1) * 16 - $3)
    elseif (%x1 isnum 4-15) var %i $+($calc($3 // 16),.,$calc(($4 + 1) // 16)) $v1
    elseif (%x2 isnum 4-15) var %i %i $+ @ $+ $+($calc($3 // 16),.,$calc(($4 + 14) // 16)) $v1
    if (%b == $null) %x = $calc(($3 // 16 + 1) * 16)
    elseif (%b isnum 1-11) %x = $calc(($3 // 16 + 1) * 16 + 1)
    if (%m == up) {
      dec %y $5
      sbmserv_movepup 100 -100 %x %y $5 %id
    }
    elseif (%m == down) {
      inc %y $5
      sbmserv_movepdown 100 -100 %x %y $5 %id
    }
    else hadd sbmserv item $+ %id %x %y $gettok($hget(sbmserv,item $+ %id),3,32)
    tokenize 64 %i
    sbmserv_handlebonuses %id $*
    return
  }
  elseif (16 \\ $4) {
    if (16 // $floor($calc($v2 + 1))) %y = $v2
    else %y = $calc($v2 -2)
  }
  hadd sbmserv item $+ %id %x %y $gettok($hget(sbmserv,item $+ %id),3,32)
}
alias sbmserv_movepright {
  var %id $6
  var %x1 $hget(sbmservmap,$+($calc(($3 + 16) // 16),.,$calc(($4 + 1) // 16)))
  var %x2 $hget(sbmservmap,$+($calc(($3 + 16) // 16) ,.,$calc(($4 + 14) // 16)))
  var %x $3,%y $4
  if (%x1) || (%x2) {
    var %l $calc(($4 + 14) // 16 * 16 - $4)
    var %l1 $calc(($4 + 1) // 16 * 16 - $4)
    if (%x1) && ((!%x2) || (%x2 > 3)) && (%l1 < $2) var %m down
    elseif (%x2) && ((!%x1) || (%x1 > 3)) && (%l > $1) var %m up
    if (99 99 == %x1 %x2) var %b $3 - $calc($3 // 16 * 16)
    if (%b == $null) {
      if (%x1 isnum 4-15) var %i $+($calc(($3 + 16) // 16),.,$calc(($4 + 1) // 16)) $v1
      elseif (%x2 isnum 4-15) var %i %i $+ @ $+ $+($calc(($3 + 16) // 16),.,$calc(($4 + 14) // 16)) $v1
      var %x = $calc($3 // 16 * 16)
    }
    elseif (%b isnum 1-11) var %x = $calc($3 // 16 * 16 + 1)
    if (%m == up) {
      dec %y $5
      sbmserv_movepup 100 -100 %x %y $5 %id
    }
    elseif (%m == down) {
      inc %y $5
      sbmserv_movepdown 100 -100 %x %y $5 %id
    }
    else hadd sbmserv item $+ %id %x %y $gettok($hget(sbmserv,item $+ %id),3,32)
    tokenize 64 %i
    sbmserv_handlebonuses %id $*
    return
  }
  elseif (16 \\ $4) {
    if (16 // $floor($calc($v2 + 1))) %y = $v2
    else %y = $calc($v2 -2)     
  }
  hadd sbmserv item $+ %id %x %y $gettok($hget(sbmserv,item $+ %id),3,32)
}
alias sbmserv_movepup {
  var %x1 $hget(sbmservmap,$+($calc(($3 + 1) // 16),.,$calc($4 // 16)))
  var %x2 $hget(sbmservmap,$+($calc(($3 + 14) // 16) ,.,$calc($4 // 16)))
  var %id $6
  var %x $3,%y $4
  if (%x1) || (%x2) {
    var %l $calc(($3 + 14) // 16 * 16 - $3)
    var %l1 $calc(($3 + 1) // 16 * 16 - $3)
    if (%x1) && ((!%x2) || (%x2 > 3)) && (%l1 < $2) var %m right
    elseif (%x2) && ((!%x1) || (%x1 > 3)) && (%l > $1) var %m left
    if (99 99 == %x1 %x2) var %b $calc(($4 // 16 + 1) * 16) - $4
    if (%b == $null) {
      if (%x1 isnum 4-15) var %i $+($calc(($3 + 1) // 16),.,$calc($4 // 16)) $v1
      elseif (%x2 isnum 4-15) var %i %i $+ @ $+ $+($calc(($3 + 14) // 16),.,$calc($4 // 16)) $v1
      var %y = $calc(($4 // 16 + 1) * 16)
    }
    elseif (%b isnum 1-11) var -s %y = $calc(($4 // 16 + 1) * 16 + 1)
    if (%m == left) {
      dec %x $5
      sbmserv_movepleft 100 -100 %x %y $5 %id
    }
    elseif (%m == right) {
      inc %x $5
      sbmserv_movepright 100 -100 %x %y $5 %id
    }
    else hadd sbmserv item $+ %id %x %y $gettok($hget(sbmserv,item $+ %id),3,32)
    tokenize 64 %i
    sbmserv_handlebonuses %id $*
    return
  }
  elseif (16 \\ $3) {
    if (16 // $floor($calc($v2 + 1))) %x = $v2
    else %x = $calc($v2 -2)     
  }
  hadd sbmserv item $+ %id %x %y $gettok($hget(sbmserv,item $+ %id),3,32)
}
alias sbmserv_movepdown {
  var %id $6
  var %x1 $hget(sbmservmap,$+($calc(($3 + 1) // 16),.,$calc(($4 + 16) // 16)))
  var %x2 $hget(sbmservmap,$+($calc(($3 + 14) // 16),.,$calc(($4 + 16) // 16)))
  var %x $3,%y $4
  if (%x1) || (%x2) {
    var %l $calc(($3 + 14) // 16 * 16 - $3)
    var %l1 $calc(($3 + 1) // 16 * 16 - $3)
    if (%x1) && ((!%x2) || (%x2 >= 4)) && (%l1 < $2) var %m right
    elseif (%x2) && ((!%x1) || (%x1 >= 4)) && (%l > $1) var %m left
    if (99 99 == %x1 %x2) var -s %b $4 - $calc(($4 // 16) * 16)
    if (%b == $null) {
      if (%x1 isnum 4-15) var %i $+($calc(($3 + 1) // 16),.,$calc(($4 + 16) // 16)) $v1
      elseif (%x2 isnum 4-15) var %i %i $+ @ $+ $+($calc(($3 + 14) // 16),.,$calc(($4 + 16) // 16)) $v1
      %y = $calc($4 // 16 * 16) 
    }
    elseif (%b isnum 1-11) %y = $calc(($4 // 16 + 0) * 16 + 1)
    if (%m == left) {
      dec %x $5
      sbmserv_movepleft 100 -100  %x %y $5 %id
    }
    elseif (%m == right) {
      inc %x $5
      sbmserv_movepright 100 -100 %x %y $5 %id
    }
    else hadd sbmserv item $+ %id %x %y $gettok($hget(sbmserv,item $+ %id),3,32)
    tokenize 64 %i
    sbmserv_handlebonuses %id $*
    return
  }
  elseif (16 \\ $3) {
    if (16 // $floor($calc($v2 + 1))) %x = $v2
    else %x = $calc($v2 -2)     
  }
  hadd sbmserv item $+ %id %x %y $gettok($hget(sbmserv,item $+ %id),3,32)
}
alias sbmserv_handlebonuses {
  var %d $2,%n $3,%id $1
  tokenize 46 $2
  if ($hget(sbmservmap,$+($1,.,$calc($2 - 1))) == 1) ;send clear drawpic -c @bbb $calc($1 * 16) $calc($2 * 16) $calc(16 * 28) 16 16 16 $qt($scriptdirbbt.png)
  else ;... drawrect -fr @bbb 3168272 0 $calc($1 * 16) $calc($2 * 16) 16 16
  var %w $findtok($hget(sbmserv,bonuses),$wildtok($hget(sbmserv,bonuses),$calc($1 * 16) $calc($2 * 16) &,1,46),46)
  hadd sbmserv bonuses $deltok($hget(sbmserv,bonuses),%w,46)
  hdel sbmservmap %d
  if (%n == 4) { hinc sbmserv nbbomb $+ %id | hinc sbmserv bomb $+ %id }
  elseif (%n == 5) hinc sbmserv fire $+ %id
  ;elseif (%n == 6) hinc bb speed 0.5
  elseif (%n == 7) hadd sbmserv cankick $+ %id 1
  elseif (%n == 8) hadd sbmserv canthrow $+ %id 1

}
alias sbmserv_makemap {
  .hmake sbmservmap
  ;1 = wall
  ;2 = free to use
  ;3 = destructible wall
  ;4-9 = bonuses: bomb,fire,roller, cankick, canthrow, skull
  ;99 = bomb
  var %x 0,%y 0
  while (%x < 15) { hadd sbmservmap $+(%x,.,%y) 1 | inc %x }
  inc %y
  var %n 5
  while (%n) {
    hadd sbmservmap $+(0,.,%y) 1 | hadd sbmservmap $+(14,.,%y) 1
    %x = 1
    while (%x < 14) { hadd sbmservmap $+(%x,.,%y) 3 | inc %x }


    inc %y
    %x = 0
    while (%x < 15) { 
      if (%x !& 1) hadd sbmservmap $+(%x,.,%y) 1
      else hadd sbmservmap $+(%x,.,%y) 3
      inc %x 1
    } 
    inc %y
    dec %n
  }
  hadd sbmservmap $+(0,.,%y) 1 | hadd sbmservmap $+(14,.,%y) 1
  %x = 1
  while (%x < 14) { hadd sbmservmap $+(%x,.,%y) 3 | inc %x }

  inc %y
  %x = 0
  while (%x < 15) { hadd sbmservmap $+(%x,.,%y) 1 | inc %x }
  tokenize 32 1.1 2.1 3.1 1.2 1.3 13.1 12.1 11.1 13.2 13.3 1.11 2.11 3.11 1.10 1.9 13.11 12.11 11.11 13.10 13.9
  hdel sbmservmap $*
  hadd sbmservmap mapsize 15 13
}