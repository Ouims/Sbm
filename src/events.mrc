on *:close:@sbm: {
  hfree sbm
  hfree sbmui
  hfree -w sbm*history
  hfree -w sbmmap
  hfree -w sbmoptions
  hfree -w sbmchat
  hfree -w sbmmap
  hfree -w sbmoptions
  .timersbm off
  sockclose sbmclient
  if ($hget(sbmserv)) sbmserv stop
}

menu @sbm {
  mouse: {
    hadd sbmui mouseInControl $null

    noop $hfind(sbmui,*_type,0,w,hadd sbmui mouseInControl $iif($sbmcooincontrol($left($1,-5),$mouse.x,$mouse.y),$left($1,-5),$hget(sbmui,mouseInControl)))

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
        /*
        this has to be changed to a move towards said line instead of directly moving into said position because of the wrapping thing

        hadd sbmui display_current $round($calc(($mouse.y - $hget(sbmui,scroll_y)) / $hget(sbmui,scroll_h) * $v1),0)
        hadd sbmui scroll_thumb_position $calc($hget(sbmui,scroll_thumb_jump) * $hget(sbmui,display_current))
        */
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
        if (%in_mouse == connect) sbmchangeview connect
        elseif (%in_mouse == create) sbmchangeview create
      }
      elseif (%view == connect) {
        if (%in_mouse == back) sbmchangeview menu
        elseif (%in_mouse == connect) && (!$hget(sbmui,connect_disabled)) {
          sbmclientconnect $hget(sbmui,server_text) $hget(sbmui,port_text) $hget(sbmui,nick_text)
        }
      }
      elseif (%view == create) {
        if (%in_mouse == back) sbmchangeview menu
        elseif (%in_mouse == connect) && (!$hget(sbmui,connect_disabled)) {
          sbmserv $hget(sbmui,port_text) restart
          sbmclientconnect 127.0.0.1 $hget(sbmui,port_text) $hget(sbmui,nick_text)
        }
      }
      elseif (%view == lobby) {
        if (%in_mouse == back) sbmchangeview menu
        elseif (%in_mouse == start) sockwrite -n sbmclient ready
        elseif (%in_mouse == select_white) && (!$hget(sbmui,select_white_disabled)) sockwrite -n sbmclient slpl 1 1
        elseif (%in_mouse == select_black) && (!$hget(sbmui,select_black_disabled)) sockwrite -n sbmclient slpl 2 1
        elseif (%in_mouse == select_orange) && (!$hget(sbmui,select_orange_disabled)) sockwrite -n sbmclient slpl 3 1
        elseif (%in_mouse == select_blue) && (!$hget(sbmui,select_blue_disabled)) sockwrite -n sbmclient slpl 4 1
        elseif (%in_mouse == up) sbmscroll up
        elseif (%in_mouse == scroll) && ($hget(sbmui,scroll_thumb)) {
          /*
          this has to be changed to a move towards said line instead of directly moving into said position because of the wrapping thing

          hadd sbmui display_current $round($calc(($mouse.y - $hget(sbmui,scroll_y)) / $hget(sbmui,scroll_h) * ($hget(sbmchat,0).item - ($hget(sbmui,display_h) / 18))),0)
          hadd sbmui scroll_thumb_position $calc($hget(sbmui,scroll_thumb_jump) * $hget(sbmui,display_current))
          hadd sbmui scroll_thumb_active $true
          */
        }
        elseif (%in_mouse == down) sbmscroll down
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
    elseif ($keyval == 22) || (($mouse.key & 2) && ($keyval == 86)) {
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
