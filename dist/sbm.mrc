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
      view lobby
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
      drawpic -c @sbmtiles 0 0 $qt($scriptdirsbm.png)
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
    elseif ($1 == player) {
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
  if (%h == 3) drawpic -ct @sbmbuf 3168272 $calc($1 * 16 + 300) $calc($2 * 16) $calc(16 * 20) 16 16 16 $qt($scriptdirbbt.png)
  elseif (%h == 1) {
    drawpic -ct @sbmbuf 3168272 $calc($1 * 16 + 300) $calc($2 * 16) $calc(16 * 21) 16 16 16 $qt($scriptdirbbt.png)
    if ($hget(sbmmap,$+($1,.,$calc($2 + 1))) == $null) && ($2 < $gettok($hget(sbmmap,mapsize),2,32)) drawpic -c @sbmbuf $calc($1 * 16 + 300) $calc($2 * 16 + 16) $calc(16 * 20) 0 16 16 $qt($scriptdirbbt.png)
  }
}

on *:close:@sbm: {
  hfree sbm
  hfree sbmui
  hfree -w sbm*history
  hfree -w sbmmap
  hfree -w sbmoptions
  hfree sbmchat
  .timersbm off
  sockclose sbmclient
  if ($hget(sbmserv)) sbmserv stop
}

menu @sbm {
  mouse: {
    hadd sbmui mouseInControl $null

    noop $hfind(sbmui,*_type,0,w,hadd sbmui mouseInControl $iif($cooInControl($left($1,-5),$mouse.x,$mouse.y),$left($1,-5),$hget(sbmui,mouseInControl)))

    var %focus = $hget(sbmui,focus)

    if ($mouse.key & 1) {
      var %in_mouse = $hget(sbmui,mouseInControl)

      if ($hget(sbmui,$+(%focus,_type)) == edit) && (%in_mouse == %focus) {
        var %c $click(@sbm,$click(@sbm,0)).x

        if ($mouse.x <= %c) {
          var %a 1,%p $hget(sbmui,$+(%focus,_cursor)),%t $left($hget(sbmui,$+(%focus,_text)),%p)
          while (%a <= $len(%t)) && ($width($right(%t,%a),$hget(sbmui,$+(%focus,_font)),$hget(sbmui,$+(%focus,_fontsize))) <= $calc(%c - $mouse.x)) {
            inc %a
          }
          if (%a != 1) {
            hadd sbmui $+(%focus,_sel) $calc(%p - %a + 1) %p
          }
        }
        else {
          var %a 1,%p $hget(sbmui,$+(%focus,_cursor)),%t $mid($hget(sbmui,$+(%focus,_text)),%p)
          while (%a <= $len(%t)) && ($width($left(%t,%a),$hget(sbmui,$+(%focus,_font)),$hget(sbmui,$+(%focus,_fontsize))) <= $calc($mouse.x - %c)) {
            inc %a
          }
          if (%a != 1) {
            hadd sbmui $+(%focus,_sel) %p $calc(%p + %a -1)
          }
        }
      }
      elseif (%in_mouse == scroll) && ($hget(sbmui,scroll_thumb_active)) && ($hget(sbmchat,0).item) {
        hadd sbmui display_current $round($calc(($mouse.y - $hget(sbmui,scroll_y)) / $hget(sbmui,scroll_h) * $v1),0)
        hadd sbmui scroll_thumb_position $calc($hget(sbmui,scroll_thumb_jump) * $hget(sbmui,display_current))
      }
    }
  }
  leave: {
    hadd sbmui mouseInControl $null
    hadd sbmui scroll_thumb_active $false
  }
  sclick: {
    if ($hget(sbmui,mouseInControl)) {
      var %in_mouse = $v1
      var %view = $hget(sbm,view)

      if ($hget(sbmui,$+(%in_mouse,_type)) == edit) {
        hadd sbmui focus %in_mouse
        hadd sbmui drawcursor $true
        hdel sbmui $+(%in_mouse,_sel)

        if ($hget(sbmui,$+(%in_mouse,_text)) != $null) {
          var -p %t = $v1
          var %x = $hget(sbmui,$+(%in_mouse,_x))

          if ($mouse.x <= $calc(%x + 10)) hadd sbmui $+(%in_mouse,_cursor) 0
          elseif ($v1 > $calc(%x + 10 + $width(%t,$hget(sbmui,$+(%in_mouse,_font)),$hget(sbmui,$+(%in_mouse,_fontsize))))) hadd sbmui $+(%in_mouse,_cursor) $len(%t)
          else {
            var %a 1
            while (%a <= $len(%t)) && ($calc(%x + 10 + $width($left(%t,%a),$hget(sbmui,$+(%in_mouse,_font)),$hget(sbmui,$+(%in_mouse,_fontsize)))) <= $mouse.x) {
              inc %a
            }

            hadd sbmui $+(%in_mouse,_cursor) $calc(%a - 1)
          }
        }
      }

      if (%view == menu) {
        if (%in_mouse == connect) view connect
        elseif (%in_mouse == create) view create
      }
      elseif (%view == connect) {
        if (%in_mouse == back) view menu
        elseif (%in_mouse == connect) && (!$hget(sbmui,connect_disabled)) {
          sbmclientconnect $hget(sbmui,server_text) $hget(sbmui,port_text) $hget(sbmui,nick_text)
        }
      }
      elseif (%view == create) {
        if (%in_mouse == back) view menu
        elseif (%in_mouse == connect) && (!$hget(sbmui,connect_disabled)) {
          sbmserv $hget(sbmui,port_text) restart
          sbmclientconnect 127.0.0.1 $hget(sbmui,port_text) $hget(sbmui,nick_text)
        }
      }
      elseif (%view == lobby) {
        if (%in_mouse == up) && ($hget(sbmui,display_current) > 0) {
          hdec sbmui display_current
          hdec sbmui scroll_thumb_position $hget(sbmui,scroll_thumb_jump)
        }
        elseif (%in_mouse == scroll) {
          hadd sbmui display_current $round($calc(($mouse.y - $hget(sbmui,scroll_y)) / $hget(sbmui,scroll_h) * $hget(sbmchat,0).item),0)
          hadd sbmui scroll_thumb_position $calc($hget(sbmui,scroll_thumb_jump) * $hget(sbmui,display_current))
          hadd sbmui scroll_thumb_active $true
        }
        elseif (%in_mouse == down) && ($hget(sbmui,display_current) < $hget(sbmchat,0).item) {
          hinc sbmui display_current
          hinc sbmui scroll_thumb_position $hget(sbmui,scroll_thumb_jump)
        }
      }
    }
  }
  uclick: {
    hadd sbmui scroll_thumb_active $false
  }
}

on *:char:@sbm:*: {
  var %focus = $hget(sbmui,focus)

  if ($hget(sbmui,$+(%focus,_type)) == edit) {
    var -p %t = $hget(sbmui,$+(%focus,_text)),%p = $hget(sbmui,$+(%focus,_cursor))

    if ($keychar != $null) && (!$istok(8 22 9 1 13 10 24 3,$keyval,32)) {
      if ($hget(sbmui,$+(%focus,_sel))) {
        tokenize 32 $v1

        var %l $iif($1 > 0,$left(%t,$1))
        var %c $iif($keyval == 32,$chr(160),$keychar)
        var %r $mid(%t,$calc($2 + 1))

        hadd sbmui $+(%focus,_text) $+(%l,%c,%r)
        hdel sbmui $+(%focus,_sel)
      }
      else {
        var %l $iif(%p > 0,$left(%t,%p))
        var %c $iif($keyval == 32,$chr(160),$keychar)
        var %r $mid(%t,$calc(%p + 1))

        if ($width($+(%l,%c,%r),$hget(sbmui,$+(%focus,_font)),$hget(sbmui,$+(%focus,_fontsize))) > $calc($hget(sbmui,$+(%focus,_w)) - 20)) return

        hadd sbmui $+(%focus,_text) $+(%l,%c,%r)
        hinc sbmui $+(%focus,_cursor)
      }
    }
  }
}

on *:keydown:@sbm:*: {
  var %focus = $hget(sbmui,focus)

  if ($hget(sbmui,$+(%focus,_type)) == edit) {
    var -p %t = $hget(sbmui,$+(%focus,_text)),%p = $hget(sbmui,$+(%focus,_cursor))

    ;delete
    if ($keyval == 8) {
      if ($hget(sbmui,$+(%focus,_sel))) {
        tokenize 32 $v1
        var %l $iif($1 > 0,$left(%t,$1))
        var %r $mid(%t,$calc($2 + 1)) 
        hadd sbmui $+(%focus,_text) $+(%l,%r)
        hdel sbmui $+(%focus,_sel)
      }
      else {
        var %l $iif(%p > 1,$left(%t,$calc(%p - 1)))
        var %r $mid(%t,$calc(%p + 1)) 
        hadd sbmui $+(%focus,_text) $+(%l,%r)
        if (%p > 0) hdec sbmui $+(%focus,_cursor)
      }
    }
    ;control+v
    elseif ($keyval == 22) {
      if ($crlf !isin $cb) {
        if ($hget(sbmui,$+(%focus,_sel))) {
          tokenize 32 $v1
          var %cb $$regsubex($replace($cb,$chr(32),$chr(160),$chr(10),,$chr(9),,$chr(13),),/\xED[\xA0-\xAF][\x80-\xBF](?!\xED[\xB0-\xBF][\x80-\xBF]|\xED[\xB0-\xBF][\x80-\xBF](?!\xED[\xA0-\xAF][\x80-\xBF]))/,$chr(65533))
          var %l $iif($1 > 0,$left(%t,$1))
          var %r $mid(%t,$calc($2 + 1))
          var %t $+(%l,%cb,%r)
          if ($width(%t,$hget(sbmui,$+(%focus,_font)),$hget(sbmui,$+(%focus,_fontsize))) > $calc($hget(sbmui,$+(%focus,_w)) - 20)) return
          hadd sbmui $+(%focus,_text) %t
          hinc sbmui $+(%focus,_cursor) $len(%cb)
          if (%p == $2) hdec sbmui $+(%focus,_cursor) $calc($2 - $1)
          hdel sbmui $+(%focus,_sel)
        }
        else {
          var %cb $$regsubex($replace($cb,$chr(32),$chr(160),$chr(10),,$chr(9),$chr(9),$chr(13),),/\xED[\xA0-\xAF][\x80-\xBF](?!\xED[\xB0-\xBF][\x80-\xBF]|\xED[\xB0-\xBF][\x80-\xBF](?!\xED[\xA0-\xAF][\x80-\xBF]))/,$chr(65533))
          var %l $iif(%p > 0,$left(%t,%p))
          var %r $mid(%t,$calc(%p + 1))
          var %t $+(%l,%cb,%r)
          if ($width(%t,$hget(sbmui,$+(%focus,_font)),$hget(sbmui,$+(%focus,_fontsize))) > $calc($hget(sbmui,$+(%focus,_w)) - 20)) return
          hadd sbmui $+(%focus,_text) %t
          hinc sbmui $+(%focus,_cursor) $len(%t)
        }
      }
      else {
        if ($hget(sbmui,$+(%focus,_sel))) {
          tokenize 32 $v1
          var %cb $$regsubex($replace($cb,$chr(32),$chr(160),$chr(10),,$chr(9),,$chr(13),),/\xED[\xA0-\xAF][\x80-\xBF]/,$chr(65533))
          var %l $iif($1 > 0,$left(%t,$1))
          var %r $mid(%t,$calc($2 + 1))
          var %t $+(%l,%cb,%r)
          var %a 1,%b $numtok(%t,10)
          while (%a <= %b) {
            if (%focus == chat) sockwrite -n sbmclient TEXT $gettok(%t,%a,10)
            elseif ($hget(sbm,view) == connect) || ($v1 == create) {
              if ($width($gettok(%t,%a,10),$hget(sbmui,$+(%focus,_font)),$hget(sbmui,$+(%focus,_fontsize))) > $calc($hget(sbmui,$+(%focus,_w)) - 20)) return
              hadd sbmui $+(%focus,_text) $gettok(%t,%a,10)
              return
            }
            hadd -m $+(sbm,%focus,history) $calc($hget($+(sbm,%focus,history),0).item + 1) $gettok(%t,%a,10)
            inc %a
          }   
          hadd sbmui $+(%focus,_history) 0
          hadd sbmui $+(%focus,_text)
          hadd sbmui $+(%focus,_cursor) 0
          hdel sbmui $+(%focus,_sel)
        }
        else {
          var %cb $$regsubex($replace($cb,$chr(32),$chr(160),$chr(10),,$chr(9),,$chr(13),),/\xED[\xA0-\xAF][\x80-\xBF](?!\xED[\xB0-\xBF][\x80-\xBF]|\xED[\xB0-\xBF][\x80-\xBF](?!\xED[\xA0-\xAF][\x80-\xBF]))/,$chr(65533))
          var %l $iif(%p > 0,$left(%t,%p))
          var %r $mid(%t,$calc(%p + 1))
          var %t $remove($+(%l,%cb,%r),$chr(13),$chr(9))
          var %a 1,%b $numtok(%t,10)
          while (%a <= %b) {
            if (%focus == chat) sockwrite -n sbmclient TEXT $gettok(%t,%a,10)
            elseif ($hget(sbm,view) == connect) || ($v1 == create) {
              if ($width($gettok(%t,%a,10),$hget(sbmui,$+(%focus,_font)),$hget(sbmui,$+(%focus,_fontsize))) > $calc($hget(sbmui,$+(%focus,_w)) - 20)) return
              hadd sbmui $+(%focus,_text) $gettok(%t,%a,10)
              return
            }
            hadd -m $+(sbm,%focus,history) $calc($hget($+(sbm,%focus,history),0).item + 1) $gettok(%t,%a,10)

            inc %a
          }
          hadd sbmui $+(%focus,_history) 0
          hadd sbmui $+(%focus,_text)
          hadd sbmui $+(%focus,_cursor) 0
        }
      }
    }
    ;#TAB
    elseif ($keyval == 9) {
      if (%focus == chat) {
        if ($hget(sbmui,$+(%focus,_sel))) return    
        if ($regex($left($hget(sbmui,$+(%focus,_text)),$hget(sbmui,$+(%focus,_cursor))),/.*\B@(\S*)/u)) {
          if ($hget(sbm,tabcomp)) {
            hinc sbm tabc
            if ($hget(sbm,tabc) > $wildtok($hget(sbm,nicks),$v1,0,32)) hadd sbm tabc 1
            var %cb $wildtok($hget(sbm,nicks),$hget(sbm,tabcomp),$hget(sbm,tabc),32),%p1 $regml(1).pos - 1
            var %l $iif(%p1 > 0,$left(%t,%p1))
            var %r $mid(%t,$calc(%p1 + $hget(sbm,tabcompold) + 1)),%a
            var %t $+(%l,%cb,%r)
            if ($width(%t,$hget(sbmui,$+(%focus,_font)),$hget(sbmui,$+(%focus,_fontsize))) > $calc($hget(sbmui,$+(%focus,_w)) - 20)) return
            hdec sbmui $+(%focus,_cursor) $hget(tabcompold)
            hadd sbmui $+(%focus,_text) %t
            hadd sbmui $+(%focus,_cursor) $calc(%p1 + $len(%cb))
            hadd sbm tabcompold $len(%cb)
          }
          else {
            hinc sbm tabc
            if ($hget(sbm,tabc) > $wildtok($hget(sbm,nicks),$regml(1) $+ *,0,32)) hadd sbm tabc 1
            var -s %cb $wildtok($hget(sbm,nicks),$regml(1) $+ *,$hget(sbm,tabc),32),%p1 $regml(1).pos - 1
            if (%cb == $null) {
              hdel sbm tabc
              hdel sbm tabcomp
              return
            }
            var %l $iif(%p1 > 0,$left(%t,%p1))
            var %r $mid(%t, $calc( %p1 + 1 + $len($regml(1))))
            var %t $+(%l,%cb,%r)
            if ($width(%t,$hget(sbmui,$+(%focus,_font)),$hget(sbmui,$+(%focus,_fontsize))) > $calc($hget(sbmui,$+(%focus,_w)) - 20)) return
            hadd sbm tabcomp $regml(1) $+ *
            hadd sbm tabcompold $len(%cb)
            hadd sbmui $+(%focus,_text) %t
            hinc sbmui $+(%focus,_cursor) $len(%cb)
          }
        }
        else {
          hdel sbm tabc
          hdel sbm tabcomp
        }
      }
      else {
        var %l = $null

        noop $hfind(sbmui,edit,0,n,var %l = %l $iif($right($1,5) == _type,$left($1,-5))).data

        var %f $findtok(%l,%focus,32)

        ; if shift is hold
        if ($mouse.key & 4) {
          inc %f

          if (%f > $numtok(%l,32)) %f = 1
        }
        else {
          dec %f

          if (%f == 0) %f = $numtok(%l,32)
        }

        hdel sbmui $+(%focus,_sel)
        hadd sbmui focus $gettok(%l,%f,32)

        %focus = $hget(sbmui,focus)

        if ($hget(sbmui,$+(%focus,_text)) != $null) {
          hadd sbmui $+(%focus,_sel) 0 $len($v1)
          hadd sbmui $+(%focus,_cursor) $len($v1)
        }
      }      
    }
    ;ctrl A
    elseif ($keyval == 1) {
      if ($hget(sbmui,$+(%focus,_text)) != $null) {
        hadd sbmui $+(%focus,_sel) 0 $len($v1)
        hadd sbmui $+(%focus,_cursor) $len($v1)
      }
    }
    ;#arrow
    elseif ($keyval $+ $keychar == 37) {
      if ($mouse.key & 4) {
        tokenize 32 $hget(sbmui,$+(%focus,_sel))
        if ($2 > %p) {
          if (%p != $calc($iif($hget(sbmui,$+(%focus,_sel)),$gettok($hget(sbmui,$+(%focus,_sel)),2,32),%p) -1)) {
            if ($v2 <= $len(%t)) {
              hadd sbmui $+(%focus,_sel) %p $v1
            }
          }
          else hdel sbmui $+(%focus,_sel)
        }
        else {
          if ($calc($iif($hget(sbmui,$+(%focus,_sel)),$gettok($hget(sbmui,$+(%focus,_sel)),1,32),%p) -1) != %p) {
            if ($v1 >= 0) {
              hadd sbmui $+(%focus,_sel) $v1 %p
            }
          }
          else hdel sbmui $+(%focus,_sel)
        }
      }
      else {
        if ($hget(sbmui,$+(%focus,_sel))) {
          hadd sbmui $+(%focus,_cursor) $gettok($v1,1,32)
        }
        elseif (%p > 0) hdec sbmui $+(%focus,_cursor)
        hdel sbmui $+(%focus,_sel)
      }
    }
    elseif ($keyval $+ $keychar == 39) {
      if ($mouse.key & 4) {
        tokenize 32 $hget(sbmui,$+(%focus,_sel))
        if ($2 > %p) || ($1 == $null) {
          if (%p != $calc($iif($hget(sbmui,$+(%focus,_sel)),$gettok($hget(sbmui,$+(%focus,_sel)),2,32),%p) +1)) {
            if ($v2 <= $len(%t)) {
              hadd sbmui $+(%focus,_sel) %p $v1
            }
          }
        }
        else {
          if (%p != $calc($iif($hget(sbmui,$+(%focus,_sel)),$gettok($hget(sbmui,$+(%focus,_sel)),1,32),%p) +1)) {
            if ($v2 <= $len(%t)) {
              hadd sbmui $+(%focus,_sel) $v1 %p
            }
          }

          else hdel sbmui $+(%focus,_sel)
        }
      }
      else {
        if ($hget(sbmui,$+(%focus,_sel))) {
          hadd sbmui $+(%focus,_cursor) $gettok($v1,2,32)
        }
        elseif (%p < $len(%t)) hinc sbmui $+(%focus,_cursor)
        hdel sbmui $+(%focus,_sel)    
      }
    }
    elseif ($keyval $+ $keychar == 38) {
      hinc sbmui $+(%focus,_history)
      var %c $calc($hget($+(sbm,%focus,history),0).item - $hget(sbmui,$+(%focus,_history)) + 1)
      if (%c == 0) {
        hdec sbmui $+(%focus,_history)
        return 
      }
      hdel sbmui $+(%focus,_sel)
      hadd sbmui $+(%focus,_text) $hget($+(sbm,%focus,history),%c)
      hadd sbmui $+(%focus,_cursor) $len($hget(sbmui,$+(%focus,_text)))

    }
    elseif ($keyval $+ $keychar == 40) {
      hdec sbmui $+(%focus,_history)
      var %c $calc($hget($+(sbm,%focus,history),0).item - $hget(sbmui,$+(%focus,_history)) + 1)
      if (%c <= $hget($+(sbm,%focus,history),0).item) { 
        hdel sbmui $+(%focus,_sel)
        hadd sbmui $+(%focus,_text) $hget($+(sbm,%focus,history),%c)
        hadd sbmui $+(%focus,_cursor) $len($hget(sbmui,$+(%focus,_text)))
      }
      else {
        if ($hget(sbmui,$+(%focus,_history)) == -1) && ($hget(sbmui,$+(%focus,_history)) != $null) && ($hget(sbmui,$+(%focus,_text)) != $null) {
          hadd -m $+(sbm,%focus,history) $calc($hget($+(sbm,%focus,history),0).item + 1) $hget(sbmui,$+(%focus,_text))
          ;hadd -m %focus history 0
        }
        hdel sbmui $+(%focus,_sel)
        hadd sbmui $+(%focus,_text)
        hadd sbmui $+(%focus,_cursor) 0
        hadd sbmui $+(%focus,_history) 0
      }
    }
    ; delete
    elseif ($keyval == 46) && ($keychar == $null) {
      if ($hget(sbmui,$+(%focus,_sel))) {
        tokenize 32 $v1
        var %l $iif($1 > 0,$left(%t,$1))
        var %r $mid(%t,$calc($2 + 1)) 
        hadd sbmui $+(%focus,_editbox) $+(%l,%r)
        if ($2 == %p) hdec sbmui $+(%focus,_cursor) $calc($2 - $1)
        hdel sbmui $+(%focus,_sel)
      }
      else {
        var %l $iif(%p > 0,$left(%t,%p))
        var %r $mid(%t,$calc(%p + 2)) 
        hadd sbmui $+(%focus,_editbox) $+(%l,%r)
      }
    }
    ; end
    elseif ($keyval $+ $keychar == 35) {
      if ($mouse.key & 4) {
        if (%p != $len(%t)) hadd sbmui $+(%focus,_sel) %p $len(%t) 
        else hdel sbmui $+(%focus,_sel)
      }
      else hadd sbmui $+(%focus,_cursor) $len(%t)
    }
    ; home
    elseif ($keyval $+ $keychar == 36) {
      if ($mouse.key & 4) {
        if (0 != %p) hadd sbmui $+(%focus,_sel) 0 %p 
        else hdel sbmui $+(%focus,_sel)
      }
      else hadd sbmui $+(%focus,_cursor) 0
    }
    ; ENTER
    elseif ($keyval == 13) || ($keyval == 10) {
      if (%focus == chat) {
        sockwrite -n sbmclient TEXT $$hget(sbmui,$+(%focus,_text))
        if (!$hget(sbmui,$+(%focus,_history))) hadd -m $+(sbm,%focus,history) $calc($hget($+(sbm,%focus,history),0).item + 1) $hget(sbmui,$+(%focus,_text))
        hadd sbmui $+(%focus,_history) 0
        hdel sbmui $+(%focus,_sel)
        hadd sbmui $+(%focus,_text)
        hadd sbmui $+(%focus,_cursor) 0
      }
      elseif ($hget(sbmui,connect_disabled) != $null) && ($hget(sbmui,connect_disabled) == $false) {
        if ($hget(sbm,view) == create) {
          if ($hget(sbmserv)) return
          sbmserv $hget(sbmui,port_text) restart
          sbmclientconnect 127.0.0.1 $hget(sbmui,port_text) $hget(sbmui,nick_text)
        }
        else sbmclientconnect $hget(sbmui,server_text) $hget(sbmui,port_text) $hget(sbmui,nick_text)
      }
    }
    ; ctrl
    elseif ($keyval == 17) {

    }
    ; alt
    elseif ($keyval == 18) {

    }
    ;control+x
    elseif ($keyval == 24) {
      if ($hget(sbmui,$+(%focus,_sel))) {
        tokenize 32 $v1
        clipboard $mid(%t,$calc($1 + 1),$calc($2 - $1))
        var %l $iif($1 > 0,$left(%t,$1))
        var %r $mid(%t,$calc($2 + 1)) 
        hadd sbmui $+(%focus,_text) $+(%l,%r)
        hdel sbmui $+(%focus,_sel)      
        if (%p == $2) hdec sbmui $+(%focus,_cursor) $calc($2 - $1)
      }
    }
    ;control+c
    elseif ($keyval == 3) {
      if ($hget(sbmui,$+(%focus,_sel))) {
        tokenize 32 $v1
        clipboard $mid(%t,$calc($1 + 1),$calc($2 - $1))
      }
    }

    if ($hget(sbm,view) == lobby) {
      if ($keyval != 9) {
        hdel sbm tabc
        hdel sbm tabcomp
        hdel sbm tabcompold
      }
    }
  }
}

on *:keyup:@sbm:37,38,39,40,32:if ($hget(sbm,view) == game) sockwrite -n sbmclient moveu $keyval

/**
*
* Game loop.
*
* @command /loop
*
*/
alias -l loop {
  var %ww = $window(@sbm).dw
  var %wh = $window(@sbm).dh

  drawrect -rfn @sbm $hget(sbmoptions,colormainbg) 1 0 0 %ww %wh

  if (%ww != $hget(sbmui,currentWidth)) || (%wh != $hget(sbmui,currentHeight)) {
    hadd sbmui resize $true

    hadd sbmui currentWidth %ww
    hadd sbmui currentHeight %wh

    if ($hget(sbm,view) == lobby) {
      if (%wh > 480) {
        hdel sbmui display_hidden $false
        hdel sbmui up_hidden $false
        hdel sbmui scroll_hidden $false
        hdel sbmui down_hidden $false
        hdel sbmui chat_hidden $false

        hadd sbmui display_w $calc(%ww - 15)
        hadd sbmui display_h $calc(%wh - 440)
        hadd sbmui up_x $calc(%ww - 15)
        hadd sbmui scroll_x $calc(%ww - 15)
        hadd sbmui scroll_h $calc($hget(sbmui,display_h) - 45)
        hadd sbmui down_x $calc(%ww - 15)
        hadd sbmui down_y $calc(%wh - 60)
        hadd sbmui chat_y $calc(%wh - 30)
        hadd sbmui chat_w $calc(%ww - 40)

        resizeChatThumb
      }
      else {
        hadd sbmui display_hidden $true
        hadd sbmui up_hidden $true
        hadd sbmui scroll_hidden $true
        hadd sbmui down_hidden $true
        hadd sbmui chat_hidden $true
      }
    }
  }

  if ($hget(sbmui,connect_type) == menu_text) && ($hget(sbm,view) != menu) {
    hadd sbmui connect_disabled $true

    if ($iptype($hget(sbmui,server_text)) != $null) && ($regex($hget(sbmui,port_text),$sbmreg_validport)) && ($hget(sbmui,nick_text) != $null) {
      hadd sbmui connect_disabled $false
    }
  }

  if ($hget(sbm,view) == lobby) {    
    var %lines = $hget(sbmchat,0).item

    if (%lines) && (!$hget(sbmui,display_hidden)) {
      var %dy = $hget(sbmui,display_y)
      var %x = 2
      var %line = $hget(sbmui,display_current)
      var %y = $calc(%dy + $hget(sbmui,display_h) - 18)
      var %font = $hget(sbmui,display_font)
      var %fontsize = $hget(sbmui,display_fontsize)

      while (%y > %dy) && ($hget(sbmchat,%line)) {
        var -p %t = $v1
        if ($gettok($v1,2,32) == *) {
          drawtext -rnp @sbm $hget(sbmoptions,colorchatinfos) %font %fontsize %x %y $+($chr(2),%t)
        }
        else {
          drawtext -rnp @sbm 0 %font %fontsize %x %y $+($chr(2),$gettok(%t,1,32))
          drawtext -rnp @sbm 0 %font %fontsize $calc(160 - $width($+($chr(2),$gettok(%t,2,32)),%font,%fontsize)) %y $+($chr(2),$gettok(%t,2,32))
          drawtext -rnp @sbm 0 %font %fontsize 170 %y $+($chr(2),$gettok(%t,3-,32))
        }
        dec %y 18
        dec %line
      }
    }
  }

  noop $hfind(sbmui,*_type,0,w,drawControl $left($1,-5))

  hadd sbmui resize $false

  var %focus = $hget(sbmui,focus)

  if ($hget(sbmui,$+(%focus,_type)) == edit) {
    if ($calc($ticks - $hget(sbmui,cursorticks)) > 500) {
      if ($hget(sbmui,drawcursor)) hadd sbmui drawcursor $false
      else hadd sbmui drawcursor $true

      hadd sbmui cursorticks $ticks
    }
    if ($hget(sbmui,drawcursor)) {
      var %x = $iif($hget(sbmui,$+(%focus,_cursor)) > 0,$width($left($hget(sbmui,$+(%focus,_text)),$v1),$hget(sbmui,$+(%focus,_font)),$hget(sbmui,$+(%focus,_fontsize))),0)
      drawline -rn @sbm 0 1 $calc($hget(sbmui,$+(%focus,_x)) + 10 + %x) $calc($hget(sbmui,$+(%focus,_y)) + 6) $calc($hget(sbmui,$+(%focus,_x)) + 10 + %x) $calc($hget(sbmui,$+(%focus,_y)) + 21)
    }
  }

  drawdot @sbm

  .timersbm -ho 1 0 if (!$isalias(loop)) .timersbm -cho 1 0 $!timer(sbm).com $(|) else loop
}

/**
*
* Launches the game.
*
* @command /sbm
*
* @global
*
*/
alias sbm {
  if ($window(@sbm)) window -a sbm
  else {
    if ($exists($scriptdirsbm.sbm)) hload -m sbmoptions $qt($scriptdirsbm.sbm)
    else .hmake sbmoptions

    if ($hget(sbmoptions,keyleft) !isnum) hadd sbmoptions keyleft 37
    if ($hget(sbmoptions,keyright) !isnum 1-) hadd sbmoptions keyright 39
    if ($hget(sbmoptions,keyup) !isnum 1-) hadd sbmoptions keyup 38
    if ($hget(sbmoptions,keydown) !isnum 1-) hadd sbmoptions keydown 40
    if ($hget(sbmoptions,keybomb) !isnum 1-) hadd sbmoptions keybomb 32

    if ($hget(sbmoptions,colornormal) !isnum 0-16777215) hadd sbmoptions colornormal 0
    if ($hget(sbmoptions,colorhovernormal) !isnum 0-16777215) hadd sbmoptions colorhovernormal 32764
    if ($hget(sbmoptions,colorhltext) !isnum 0-16777215) hadd sbmoptions colorhltext 32764
    if ($hget(sbmoptions,colorhoverhltext) !isnum 0-16777215) hadd sbmoptions colorhoverhltext 23737
    if ($hget(sbmoptions,colorcancel) !isnum 0-16777215) hadd sbmoptions colorcancel 255
    if ($hget(sbmoptions,colorhovercancel) !isnum 0-16777215) hadd sbmoptions colorhovercancel 127
    if ($hget(sbmoptions,colormainbg) !isnum 0-16777215) hadd sbmoptions colormainbg 3168272
    if ($hget(sbmoptions,coloreditbg) !isnum 0-16777215) hadd sbmoptions coloreditbg 8355711
    if ($hget(sbmoptions,coloredittext) !isnum 0-16777215) hadd sbmoptions coloredittext 0
    if ($hget(sbmoptions,coloreditseltext) !isnum 0-16777215) hadd sbmoptions coloreditseltext 16777215
    if ($hget(sbmoptions,coloreditselbg) !isnum 0-16777215) hadd sbmoptions coloreditselbg 16515072
    if ($hget(sbmoptions,colorchatinfos) !isnum 0-16777215) hadd sbmoptions colorchatinfos 127
    if ($hget(sbmoptions,colorconnectingmsg) !isnum 0-16777215) hadd sbmoptions colorconnectingmsg 16776960
    if ($hget(sbmoptions,colorconnecterrormsg) !isnum 0-16777215) hadd sbmoptions colorconnecterrormsg 255
    if ($hget(sbmoptions,colorchatmsg) !isnum 0-16777215) hadd sbmoptions colorchatmsg 0
    if ($hget(sbmoptions,colorelevator) !isnum 0-16777215) hadd sbmoptions colorelevator 0
    if ($hget(sbmoptions,colorplay) !isnum 0-16777215) hadd sbmoptions colorplay 16515072
    if ($hget(sbmoptions,colorhoverplay) !isnum 0-16777215) hadd sbmoptions colorhoverplay 64512

    hsave sbmoptions $qt($scriptdirsbm.sbm)

    window -pdBfCfo +l @sbm -1 -1 800 600

    .hmake sbm
    hmake sbmui 1
    
    hadd sbmui originalWidth 800
    hadd sbmui originalHeight 600

    view menu

    loop
  }
}

alias sbmreg_validserver return ^(?:(?:25[0-5]|2[0-4]\d|1?\d\d?)(?:\.(?!$)|$)){4}|^(?:\w+\.)+\w+$
alias sbmreg_validport return ^(?:[1-9]|\d{1,4}|[1-5]\d{4}|6(?:[0-4]\d{3}|5(?:[0-4]\d{2}|5(?:[0-2]\d|3[0-5]))))$

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

/**
*
* Tokenizes a string based on a delimiter or quotes just as mIRC does for native commands.
*
* @identifier $getParameters
*
* @param <parameters>       String containing your parameters
* @param [delimiter=\x20]   The delimiter for your parameters
*
* @returns  String tokenized into $cr based on a specified delimiter or double quotes.
*
*/
alias -l getParameters {
  set -l %tokenized $null
  set -l %token 1
  set -l %chr $2

  if (%chr == $null) set -l %chr \x20

  set -l %regex /((?:"(?:[^"])*"|[^ $+ %chr $+ ])+)/g

  set -l %tokens $regex(tokens,$1,%regex)
  set -l %total $regml(tokens,0)

  while (%token <= %total) {
    set -l %tokenized $+(%tokenized,$cr,$regml(tokens,%token))

    inc %token
  }

  return %tokenized
}

/**
*
* Compares two numbers.
*
* @identifier $max
*
* @param <number>  first number to compare
* @param <number>  second number to compare
*
* @returns  the biggest number
*
*/
alias -l max {
  if ($1 > $2) return $1
  return $2
}

/**
*
* Compares two numbers.
*
* @identifier $min
*
* @param <number>  first number to compare
* @param <number>  second number to compare
*
* @returns  the smallest number
*
*/
alias -l min {
  if ($1 < $2) return $1
  return $2
}

/**
*
* Align helper.
*
* @identifier $align
*
* @param <available space>  available space
* @param <actual space>     space trying to be used
* @param <position>         current position
*
* @prop center              calculates the center position alignment
* @prop oppositeSide        calculates the opposite side position alignment
*
* @returns                  new position based on prop
*
*/
alias -l align {
  if ($prop == center) && ($calc(($1 - $2) / 2 + $3) > $3) return $v1
  elseif ($prop == oppositeSide) && ($calc($1 - $2 + $3) > $3) return $v1

  return $3
}

alias Lum tokenize 44 $rgb($1) | return $calc(0.2126 * $brightness($1) + 0.7152 * $brightness($2) + 0.0722* $brightness($3))
alias brightness var %res = $1 / 255 | return $iif(%res <= 0.03928, $calc(%res / 12.92), $calc((( %res + 0.055) / 1.055) ^ 2.4))
alias contrast tokenize 32 $sorttok($Lum($1) $Lum($2),32,nr) | return $calc( ($1 + 0.05) / ($2 + 0.05) )

/**
*
* Adds a control.
*
* @command /addControl
*
* @param <type>   type of control
* @param <id>     id of the control
* @param <x>      x position
* @param <y>      y position
* @param <w>      width
* @param <h>      height
* @param [N]      width of a round rect ellipse
* @param [N]      height of a round rect ellipse
* @param <font>   font
* @param <size>   font size
* @param <style>  relative: positions and resizes control relative to the window size
*                 fixed: resizes control relative to the window size and positions it relative to its size
*                 absolute_top_left: positions the top left of the control relative to the window size without resizing
*                 absolute_top_right: same as absolute_top_left but to the top right
*                 absolute_bottom_left: same as absolute_top_left but to the bottom left
*                 absolute_bottom_right: same as absolute_top_left but to the bottom right
*                 stretch: changes size without moving position
*                 static: default, position and size stay the same no matter what
* @param [text]   text of control
*
*/
alias -l addControl {
  tokenize 13 $getParameters($1-)

  hadd sbmui $+($2,_type) $1
  hadd sbmui $+($2,_x) $3
  hadd sbmui $+($2,_y) $4
  hadd sbmui $+($2,_w) $5
  hadd sbmui $+($2,_h) $6

  hadd sbmui $+($2,_ox) $3
  hadd sbmui $+($2,_oy) $4
  hadd sbmui $+($2,_ow) $5
  hadd sbmui $+($2,_oh) $6
  
  if ($7 isnum) {
    hadd sbmui $+($2,_i) $7
    hadd sbmui $+($2,_e) $8

    tokenize 13 $getParameters($1-6 $9-)
  }

  hadd sbmui $+($2,_font) $7
  hadd sbmui $+($2,_fontsize) $8

  hadd sbmui $+($2,_osize) $8

  hadd sbmui $+($2,_style) $9

  if ($10 != $null) hadd sbmui $+($2,_text) $10-

  if ($1 == edit) hadd sbmui $+($2,_bg) 8355711
}

/**
*
* Draws control.
*
* @command /drawControl
*
* @param <id>  control id
*
*/
alias -l drawControl {
  if (!$hget(sbmui,$+($1,_hidden))) {
    var %type = $hget(sbmui,$+($1,_type))
    var %x = $hget(sbmui,$+($1,_x))
    var %y = $hget(sbmui,$+($1,_y))
    var %w = $hget(sbmui,$+($1,_w))
    var %h = $hget(sbmui,$+($1,_h))
    var %i = $hget(sbmui,$+($1,_i))
    var %e = $hget(sbmui,$+($1,_e))
    var %font = $hget(sbmui,$+($1,_font))
    var %size = $hget(sbmui,$+($1,_fontsize))
    var %style = $hget(sbmui,$+($1,_style))

    if (%style != static) {
      var %ww = $window(@sbm).dw
      var %wh = $window(@sbm).dh

      if ($hget(sbmui,resize)) {
        var %oww = $hget(sbmui,originalWidth)
        var %owh = $hget(sbmui,originalHeight)

        var %ox = $hget(sbmui,$+($1,_ox))
        var %oy = $hget(sbmui,$+($1,_oy))
        var %ow = $hget(sbmui,$+($1,_ow))
        var %oh = $hget(sbmui,$+($1,_oh))
        var %osize = $hget(sbmui,$+($1,_osize))

        var %scale = $calc(1 / $max($calc(%oww / %ww),$calc(%owh / %wh)))

        if (%style == relative) {
          %x = $calc((%ox / %oww) * %ww)
          %y = $calc((%oy / %owh) * %wh)
          %w = $calc((%ow / %oww) * %ww)
          %h = $calc((%oh / %owh) * %wh)

          if (text isin %type) {
            %size = $calc(%osize * %scale)

            var %fw = $width($hget(sbmui,$+($1,_text)),%font,%size)
            var %fh = $height(SBM,%font,%size)

            %x = $calc((%w - %fw) / 2 + %x)
            %y = $calc((%h - %fh) / 2 + %y)
            %w = %fw
            %h = %fh
          }
        }
        elseif (%style == fixed) {
          %x = $calc(%ox * %scale)
          %y = $calc(%oy * %scale)
          %w = $calc(%ow * %scale)
          %h = $calc(%oh * %scale)

          var %rw = $calc((%ow / %oww) * %ww)
          var %rh = $calc((%oh / %owh) * %wh)

          %x = $calc((%rw - %w) / 2 + %x)
          %y = $calc((%rh - %h) / 2 + %y)

          if (text isin %type) {
            %size = $calc(%osize * %scale)

            %w = $width($hget(sbmui,$+($1,_text)),%font,%size)
            %h = $height(SBM,%font,%size)
          }
        }
        elseif (%style == absolute_top_left) {
          %x = $calc((%ox / %oww) * %ww)
          %y = $calc((%oy / %owh) * %wh)
        }
        elseif (%style == absolute_top_right) {
          %x = $calc(((%ox + %ow) / %oww) * %ww - %ow)
          %y = $calc((%oy / %owh) * %wh)
        }
        elseif (%style == absolute_bottom_left) {
          %x = $calc((%ox / %oww) * %ww)
          %y = $calc(((%oy + %oh) / %owh) * %wh - %oh)
        }
        elseif (%style == absolute_bottom_right) {
          %x = $calc(((%ox + %ow) / %oww) * %ww - %ow)
          %y = $calc(((%oy + %oh) / %owh) * %wh - %oh)
        }

        hadd sbmui $+($1,_x) %x
        hadd sbmui $+($1,_y) %y
        hadd sbmui $+($1,_w) %w
        hadd sbmui $+($1,_h) %h
        hadd sbmui $+($1,_fontsize) %size
      }
    }

    if (%type == menu_text) {
      var %color = $hget(sbmoptions,colorhltext)

      if ($1 == $hget(sbmui,mouseInControl)) %color = $hget(sbmoptions,colorhoverhltext)
      if ($hget(sbmui,$+($1,_disabled))) %color = 13816530

      drawtext -nr @sbm %color %font %size %x %y $hget(sbmui,$+($1,_text))
    }
    if (%type == text) drawtext -nr @sbm $hget(sbmoptions,colornormal) %font %size %x %y $hget(sbmui,$+($1,_text))
    elseif (%type == logo) drawpic -cstn @sbm 16777215 %x %y %w %h $qt($scriptdirassets\logo.png)
    elseif (%type == edit) {
      drawrect -dfrn @sbm $hget(sbmui,$+($1,_bg)) 1 %x %y %w %h %i %e

      if ($hget(sbmui,$+($1,_text))) {
        var -p %t $v1

        if ($hget(sbmui,$+($1,_sel))) {
          tokenize 32 $v1

          var %l $iif($1 > 0,$left(%t,$1))
          var %m $mid(%t,$calc($1 + 1),$calc($2 - $1))
          var %r $mid(%t,$calc($2 + 1))

          drawtext -rn @sbm $hget(sbmoptions,coloredittext) %font %size $calc(%x + 10) $calc(%y + 3) %t
          drawtext -rbn @sbm $hget(sbmoptions,coloreditseltext) $hget(sbmoptions,coloreditselbg) %font %size $calc(%x + 10 + $width(%l,%font,%size)) $calc(%y + 3) %m
        }
        else drawtext -rn @sbm $hget(sbmoptions,coloredittext) %font %size $calc(%x + 10) $calc(%y + 3) %t
      }
    }
    elseif (%type == chat) {
      drawrect -rn @sbm 0 1 %x %y %w %h
    }
    elseif (%type == elevator) {
      drawrect -rfn @sbm $hget(sbmoptions,colormainbg) 1 %x %y %w %h
      var -p %t = $hget(sbmui,$+($1,_text))
      %x = $align(%w,$width(%t,%font,%size),%x).center
      drawtext -rn @sbm $hget(sbmoptions,colorelevator) %font %size %x %y %t
    }
    elseif (%type == scroll) {
      drawrect -rfn @sbm 0 1 %x %y %w %h

      if ($hget(sbmui,$+($1,_thumb))) drawrect -rfn @sbm 16777215 1 %x $calc(%y + $hget(sbmui,$+($1,_thumb_position))) %w $v1
    }
  }
  ;drawrect -rn @sbm $rgb(220,220,220) 1 %x %y %w %h
}

/**
*
* Checks if a coordinate is within a UI control.
*
* @identifer $cooInControl
*
* @param <id>        id of the control
* @param <x>         x position of coordinate
* @param <y>         y position of coordinate
*
*/
alias -l cooInControl {
  if (!$hget(sbmui,$+($1,_hidden))) {
    if ($hget(sbmui,$+($1,_i)) != $null) {
      return $inroundrect($2,$3,$hget(sbmui,$+($1,_x)),$hget(sbmui,$+($1,_y)),$hget(sbmui,$+($1,_w)),$hget(sbmui,$+($1,_h)),$hget(sbmui,$+($1,_i)),$hget(sbmui,$+($1,_e)))
    }
    
    return $inrect($2,$3,$hget(sbmui,$+($1,_x)),$hget(sbmui,$+($1,_y)),$hget(sbmui,$+($1,_w)),$hget(sbmui,$+($1,_h)))
  }

  return $false
}

alias sbmaddtext {
  var %i = $hget(sbmchat,0).item

  hadd -m sbmchat $calc(%i + 1) $1-

  if (%i == $hget(sbmui,display_current)) hinc sbmui display_current

  resizeChatThumb
}

/**
*
* Resizes the chat's thumb.
*
* @command /resizeChatThumb
*
*/
alias -l resizeChatThumb {
  var %lines = $hget(sbmchat,0).item
  if (%lines) {
    var %height = $hget(sbmui,display_h)
    var %scroll = $hget(sbmui,scroll_h)
    var %viewing = $calc(%height / 18)
    var %lines = $calc(%lines + %viewing)
    var %content = $calc(%lines * 18)
    var %visible = $calc(%height / %content)
    var %thumb = $calc(%scroll * %visible)
    var %jump = $calc((%scroll - %thumb) / (%lines - %viewing))

    hadd sbmui scroll_thumb %thumb
    hadd sbmui scroll_thumb_jump %jump
    hadd sbmui scroll_thumb_position $calc(%jump * $hget(sbmui,display_current))
  }
  else hdel -w scroll_thumb*
}

/**
*
* Sets the view of the game.
*
* @command /view
*
* @param <name>  the name of the view
*
*/
alias -l view {
  var %ww = $hget(sbmui,originalWidth)
  var %wh = $hget(sbmui,originalHeight)

  hdel -w sbmui *_*
  hadd sbmui mouseInControl $null
  hadd sbmui focus $null
  hadd sbmui drawcursor $false

  if ($1 == menu) || ($1 == $null) {
    addControl logo logo 10 20 780 300 null null fixed

    var %text = Connect to game
    var %font = tahoma
    var %font = "segoe ui symbol"
    var %size = 55
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $calc((%ww - %w) / 2)
    var %y = 360

    addControl menu_text connect %x %y %w %h %font %size relative %text

    var %text = Create a game
    var %font = "segoe ui symbol"
    var %size = 55
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $calc((%ww - %w) / 2)
    var %y = 440

    addControl menu_text create %x %y %w %h %font %size relative %text

    var %text = Options
    var %font = impact
    var %font = "segoe ui symbol"
    var %size = 55
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $calc((%ww - %w) / 2)
    var %y = 520

    addControl menu_text options %x %y %w %h %font %size relative %text
  }
  elseif ($1 == connect) {
    hadd sbmui focus server

    var %text = $chr(8592) Back
    var %font = "segoe ui symbol"
    var %size = 20
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = 10
    var %y = 5

    addControl menu_text back %x %y %w %h %font %size static %text

    var %text = Enter the server information and a nickname
    var %font = "segoe ui symbol"
    var %size = 27
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%ww,%w,0).center
    var %y = 100

    addControl text title %x %y %w %h %font %size fixed %text

    var %text = Server Address
    var %font = "segoe ui symbol"
    var %size = 25
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = 180
    var %y = 270
    var %sx = %x
    var %sw = %w

    addControl text server_label %x %y %w %h %font %size absolute_top_right %text

    var %font = "segoe ui symbol"
    var %size = 15
    var %w = 160
    var %h = 25
    var %x = 380
    var %y = 272

    addControl edit server %x %y %w %h %font %size absolute_top_left

    var %text = Server Port
    var %font = "segoe ui symbol"
    var %size = 25
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%sw,%w,%sx).oppositeSide
    var %y = 350

    addControl text port_label %x %y %w %h %font %size absolute_top_right %text

    var %font = "segoe ui symbol"
    var %size = 15
    var %w = 80
    var %h = 25
    var %x = 380
    var %y = 352

    addControl edit port %x %y %w %h %font %size absolute_top_left

    var %text = Nickname
    var %font = "segoe ui symbol"
    var %size = 25
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%sw,%w,%sx).oppositeSide
    var %y = 430

    addControl text nick_label %x %y %w %h %font %size absolute_top_right %text

    var %font = "segoe ui symbol"
    var %size = 15
    var %w = 90
    var %h = 25
    var %x = 380
    var %y = 432

    addControl edit nick %x %y %w %h %font %size absolute_top_left $me

    hadd sbmui nick_cursor $len($me)

    if ($len($me)) hadd sbmui nick_sel 0 $len($me)

    var %text = Connect
    var %font = "segoe ui symbol"
    var %size = 28
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%ww,%w,0).center
    var %y = 500

    addControl menu_text connect %x %y %w %h %font %size absolute_top_left %text

    hadd sbmui connect_disabled $true
  }
  elseif ($1 == create) {
    hadd sbmui focus port

    var %text = $chr(8592) Back
    var %font = "segoe ui symbol"
    var %size = 20
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = 10
    var %y = 5

    addControl menu_text back %x %y %w %h %font %size static %text

    var %text = Enter the server port and a nickname
    var %font = "segoe ui symbol"
    var %size = 27
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%ww,%w,0).center
    var %y = 100

    addControl text title %x %y %w %h %font %size fixed %text

    var %text = Server Address
    var %font = "segoe ui symbol"
    var %size = 25
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = 180
    var %y = 270
    var %sx = %x
    var %sw = %w

    ;addControl text server_label %x %y %w %h %font %size absolute_top_right %text

    var %font = "segoe ui symbol"
    var %size = 15
    var %w = 160
    var %h = 25
    var %x = 380
    var %y = 272

    ;addControl edit server %x %y %w %h %font %size absolute_top_left
    hadd sbmui server_text 127.0.0.1

    var %text = Server Port
    var %font = "segoe ui symbol"
    var %size = 25
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%sw,%w,%sx).oppositeSide
    var %y = 350

    addControl text port_label %x %y %w %h %font %size absolute_top_right %text

    var %font = "segoe ui symbol"
    var %size = 15
    var %w = 80
    var %h = 25
    var %x = 380
    var %y = 352

    addControl edit port %x %y %w %h %font %size absolute_top_left 8000

    hadd sbmui port_cursor 4
    hadd sbmui port_sel 0 4

    var %text = Nickname
    var %font = "segoe ui symbol"
    var %size = 25
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%sw,%w,%sx).oppositeSide
    var %y = 430

    addControl text nick_label %x %y %w %h %font %size absolute_top_right %text

    var %font = "segoe ui symbol"
    var %size = 15
    var %w = 90
    var %h = 25
    var %x = 380
    var %y = 432

    addControl edit nick %x %y %w %h %font %size absolute_top_left $me

    hadd sbmui nick_cursor $len($me)

    if ($len($me)) hadd sbmui nick_sel 0 $len($me)

    var %text = Start
    var %font = "segoe ui symbol"
    var %size = 28
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%ww,%w,0).center
    var %y = 500

    addControl menu_text connect %x %y %w %h %font %size absolute_top_left %text

    hadd sbmui connect_disabled $true
  }
  elseif ($1 == options) {

  }
  elseif ($1 == lobby) {
    hadd sbmui focus chat

    addcontrol chat display 0 400 785 160 "segoe ui symbol" 11 static
    addcontrol elevator up 785 400 15 20 "segoe ui symbol" 14 static $chr(9650)
    addcontrol scroll scroll 785 425 15 115 "segoe ui symbol" 14 static
    addcontrol elevator down 785 540 15 20 "segoe ui symbol" 14 static $chr(9660)
    addControl edit chat 5 570 760 25 15 15 "segoe ui symbol" 15 static

    hadd sbmui display_current 0
  }

  hadd sbm view $1

  hadd sbmui currentWidth 800
  hadd sbmui currentHeight 600
}

