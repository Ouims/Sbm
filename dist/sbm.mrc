on *:close:@sbm: {
  hfree sbm
  hfree sbmui
  hfree -w sbm*history
  .timersbm off   
}

menu @sbm {
  mouse: {
    hadd sbmui mouseInControl $null

    noop $hfind(sbmui,*_type,0,w,hadd sbmui mouseInControl $iif($cooInControl($left($1,-5),$mouse.x,$mouse.y),$left($1,-5),$hget(sbmui,mouseInControl)))

    var %focus = $hget(sbmui,focus)

    if ($mouse.key & 1) && ($hget(sbmui,$+(%focus,_type)) == edit) && ($hget(sbmui,mouseInControl) == %focus) {
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
  }
  leave: hadd sbmui mouseInControl $null
  sclick: {
    if ($hget(sbmui,mouseInControl)) {
      var %active = $v1
      var %view = $hget(sbm,view)

      if ($hget(sbmui,$+(%active,_type)) == edit) {
        hadd sbmui focus %active
        hadd sbmui drawcursor $true
        hdel sbmui $+(%active,_sel)

        if ($hget(sbmui,$+(%active,_text)) != $null) {
          var -p %t = $v1
          var %x = $hget(sbmui,$+(%active,_x))

          if ($mouse.x <= $calc(%x + 10)) hadd sbmui $+(%active,_cursor) 0
          elseif ($v1 > $calc(%x + 10 + $width(%t,$hget(sbmui,$+(%active,_font)),$hget(sbmui,$+(%active,_fontsize))))) hadd sbmui $+(%active,_cursor) $len(%t)
          else {
            var %a 1
            while (%a <= $len(%t)) && ($calc(%x + 10 + $width($left(%t,%a),$hget(sbmui,$+(%active,_font)),$hget(sbmui,$+(%active,_fontsize)))) <= $mouse.x) {
              inc %a
            }

            hadd sbmui $+(%active,_cursor) $calc(%a - 1)
          }
        }
      }

      if (%view == menu) {
        if (%active == connect) view connect
        elseif (%active == create) view create
      }
      elseif (%view == connect) {
        if (%active == back) view menu
        elseif (%active == connect) && (!$hget(sbmui,connect_disabled)) {
          sbmclientconnect $hget(sbmui,server_text) $hget(sbmui,port_text) $hget(sbmui,nick_text)
        }
      }
      elseif (%view == create) {
        if (%active == back) view menu
      }
    }
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

        dec %f

        if (%f == 0) %f = $numtok(%l,32)

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
        if (!$hget(sbmui,$+(%focus,_history))) hadd -m %focus $+ history $calc($hget(%focus $+ history,0).item + 1) $hget(sbmui,$+(%focus,_text))
        hadd sbmui $+(%focus,_history) 0
        hdel sbmui $+(%focus,_sel)
        hadd sbmui $+(%focus,_editbox)
        hadd sbmui $+(%focus,_cursor) 0
      }
      elseif ($hget(sbmui,connect_disabled) != $null) && ($hget(sbmui,connect_disabled) == $false) {
        if ($hget(sbmui,view) == create) {
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
  }

  if ($hget(sbm,view) == connect) {
    hadd sbmui connect_disabled $true

    if ($iptype($hget(sbmui,server_text)) != $null) && ($regex($hget(sbmui,port_text),$sbmreg_validport)) && ($hget(sbmui,nick_text) != $null) {
      hadd sbmui connect_disabled $false
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

    tokenize 32 $getParameters($1-6 $9-)
  }

  hadd sbmui $+($2,_font) $7
  hadd sbmui $+($2,_fontsize) $8

  hadd sbmui $+($2,_osize) $8

  hadd sbmui $+($2,_style) $9

  if ($10 != $null) hadd sbmui $+($2,_text) $10-
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
  if ($hget(sbmui,$+($1,_i)) != $null) {
    return $inroundrect($2,$3,$hget(sbmui,$+($1,_x)),$hget(sbmui,$+($1,_y)),$hget(sbmui,$+($1,_w)),$hget(sbmui,$+($1,_h)),$hget(sbmui,$+($1,_i)),$hget(sbmui,$+($1,_e)))
  }
  
  return $inrect($2,$3,$hget(sbmui,$+($1,_x)),$hget(sbmui,$+($1,_y)),$hget(sbmui,$+($1,_w)),$hget(sbmui,$+($1,_h)))
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

  hadd sbm view $1

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

    hadd sbmui server_bg 8355711

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

    hadd sbmui port_bg 8355711

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

    hadd sbmui nick_bg 8355711

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

    hadd sbmui port_bg 8355711

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

    hadd sbmui nick_bg 8355711

    var %text = Start
    var %font = "segoe ui symbol"
    var %size = 28
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%ww,%w,0).center
    var %y = 500

    addControl menu_text connect %x %y %w %h %font %size absolute_top_left %text
    
  }
  elseif ($1 == options) {

  }

  hadd sbmui currentWidth 800
  hadd sbmui currentHeight 600
}

