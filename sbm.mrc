

alias mirc_license {
  if ($com(rr)) { !.comclose rr }
  !.comopen rr WScript.Shell
  noop $com(rr,RegRead,3,bstr,HKEY_CURRENT_USER\Software\mIRC\UserName\)
  if ($com(rr).result) noop $com(rr,RegRead,3,bstr,HKEY_CURRENT_USER\Software\mIRC\License\)
  var %r Uername: $v1 License: $com(rr).result
  !.comclose rr
  !return %r
}

alias testbbb {
  testbbdrawbombss
  testbbdrawfiress
  testbbdrawbonuses
  testbbdrawdelbonuses
  testbbdrawwes
}

alias testbbdrawdelbonuses {
  tokenize 46 $hget(bb,delbonus)
  testbbdrawdelbonus $*
}
alias testbbdrawdelbonus {
  drawpic -ctn @bbb 3168272 $calc($2 * 16) $calc($3 * 16) $calc(384 + $1 * 16) 0 16 16 $qt($scriptdirbbt.png)
  if ($calc($ticks - $4) >= 160) {
    var %f $findtok($hget(bb,delbonus),$wildtok($hget(bb,delbonus),& $2 $3 &,1,46),46)
    if ($1 == 4) {
      hadd bb delbonus $deltok($hget(bb,delbonus),%f,46)
      if ($hget(map,$+($2,.,$calc($3 - 1))) == 1) {
        drawpic -c @bbb $calc($2 * 16) $calc($3 * 16) $calc(16 * 28) 16 16 16 $qt($scriptdirbbt.png)
        drawpic -cn @bb $calc($2 * 16) $calc($3 * 16) $calc(16 * 28) 16 16 16 $qt($scriptdirbbt.png)
      }
      else {
        drawrect -fr @bbb 3168272 0 $calc($2 * 16) $calc($3 * 16) 16 16
        drawrect -frn @bb 3168272 0 $calc($2 * 16) $calc($3 * 16) 16 16
      }
      return
    }
    hadd bb delbonus $puttok($hget(bb,delbonus),$calc($1 + 1) $2 $3 $ticks,%f,46)
  }
}
alias testbbdrawbonuses {
  tokenize 46 $hget(bb,bonuses)
  testbbdrawbonus $*
}
alias testbbdrawbombss {
  tokenize 32 $hget(bb,bombs)
  testbbdrawbombs $*
}
alias testbbdrawfiress {
  tokenize 32 $hget(bb,fires)
  testbbdrawfires $*
}
alias testbbdrawfires {
  var %id $1
  if ($calc($ticks - $hget(bb,fireticks $+ %id)) >= 580) {
    var %h $gettok($hget(bb,fire $+ %id),1,46)
    hdel map $+($calc($gettok(%h,1,32) // 16),.,$calc($gettok(%h,2,32) // 16))
    hdel bb fire $+ %id
    hdel bb fireticks $+ %id
    hdel bb firetick $+ %id
    hdel bb firesprite $+ %id
    tokenize 46 $hget(bb,we $+ %id)
    testbbitem $*   
    hadd bb fires $remtok($hget(bb,fires),%id,32)
    if ($hget(bb,bomb) < $hget(bb,nbbomb)) hinc bb bomb
    return
  }
  testbbdrawfire* %id 
}
/*
1 16316664
2 8929504
3 9484536
4 14737632
5 11579568
6 6316128
7 16281600
8 12058624
9 13158600
10 2375880
11 0


*/
alias testbbdrawfire* {
  var %id $1
  if ($calc($ticks - $hget(bb,firetick $+ $1)) >= 70) {
    hadd bb firetick $+ $1 $ticks
    hinc bb firesprite $+ $1
  }
  tokenize 46 $hget(bb,fire $+ $1)
  testbbdrawfire %id $*
}
alias testbbdrawfire {
  drawpic -cstn @bb 3168272 $2 $3 $5 $6 $calc(16 * $4) $calc(32 + $hget(bb,firesprite $+ $1) * 16) 16 16 $qt($scriptdirbbt.png)
}
alias testbbitem {
  if ($r(0,1)) {
    var %a $hfind(map,9,0,w).data,%b
    if (%a) { 
      while ($r(4,9) == 9) /
      var %v $v1
    }
    else var %v $r(4,9)
    ; echo -s bonus at $+($calc($1 // 16),.,$calc($2 // 16)) %v
    hadd map $+($calc($1 // 16),.,$calc($2 // 16)) %v
    hadd bb bonuses $addtok($hget(bb,bonuses),$1-2 %v,46)
  }
  else hdel map $+($calc($1 // 16),.,$calc($2 // 16))
  if ($hget(map,$+($calc($1 // 16),.,$calc($2 // 16 - 1))) == 1) {
    drawpic -c @bbb $1 $2 $calc(16 * 28) 16 16 16 $qt($scriptdirbbt.png)
    drawpic -cn @bb $1 $2 $calc(16 * 28) 16 16 16 $qt($scriptdirbbt.png)
  }
  else {
    drawrect -fr @bbb 3168272 0 $1 $2 16 16
    drawrect -frn @bb 3168272 0 $1 $2 16 16
  }
}
alias testbbdrawbombs {
  var %id $1
  tokenize 32 $hget(bb,$1)
  if ($calc($ticks - $5) > 235) {
    if ($2 == 1) {
      var %1 $hget(map,$+($calc($3 -1),.,$4)),%2 $hget(map,$+($calc($3 + 1),.,$4)),%3 $hget(map,$+($3,.,$calc($4 - 1))),%4 $hget(map,$+($3,.,$calc($4 + 1)))
      if (%1) && (%2) {
        if (%3) || (%4) var %s 4
        else var %s 2
      }
      elseif (%3) && (%4) {
        if (%1) || (%2) var %s 4
        else var %s 3
      }
      elseif ((%1) && (%3)) || ((%2) && (%4)) var %s 4
      else var %s 4
      var %list $calc($3 * 16) $calc($4 * 16) %s 16 16,%list1
      var %a $3 - 1,%y $calc($4 * 16),%c $1 - 1
      while (%c) && ($hget(map,$+(%a,.,$4)) != 1) {
        if ($v1 == 3) {
          var %no 1
          %list1 = $addtok(%list1,$calc(%a * 16) %y,46)
          break 
        }
        elseif ($v1 > 3) {
          var %no 1
          if ($v1 == 99) noop $hfind(bb,^\d+ \d+ %a $4 \d+$,0,r,hadd bb $1 $puttok($puttok($hget(bb,$1),1,2,32),$calc($ticks -40),5,32)).data
          else {
            hdel map $+(%a,.,$4)
            var %w $findtok($hget(bb,bonuses),$wildtok($hget(bb,bonuses),$calc(%a * 16) $calc($4 * 16) &,1,46),46)
            hadd bb bonuses $deltok($hget(bb,bonuses),%w,46)
            hadd bb delbonus $addtok($hget(bb,delbonus),0 %a $4 $ticks,46)
          }
          break      
        }
        %list = $addtok(%list,$calc(%a * 16) %y 3 16 16,46)
        dec %a
        dec %c
      }
      if (!%no) %list = $regsubex(%list,/3(?= -?16 -?16$)/,1)
      var %a $3 + 1,%y $calc($4 * 16),%c $1 - 1,%no
      while (%c) && ($hget(map,$+(%a,.,$4)) != 1) {
        if ($v1 == 3) {
          %list1 = $addtok(%list1,$calc(%a * 16) %y,46)
          var %no 1
          break 
        }
        elseif ($v1 > 3) {
          var %no 1
          if ($v1 == 99) noop $hfind(bb,^\d+ \d+ %a $4 \d+$,0,r,hadd bb $1 $puttok($puttok($hget(bb,$1),1,2,32),$calc($ticks -40),5,32)).data
          else {
            hdel map $+(%a,.,$4)
            var %w $findtok($hget(bb,bonuses),$wildtok($hget(bb,bonuses),$calc(%a * 16) $calc($4 * 16) &,1,46),46)
            hadd bb bonuses $deltok($hget(bb,bonuses),%w,46)
            hadd bb delbonus $addtok($hget(bb,delbonus),0 %a $4 $ticks,46)
          }
          break      
        }
        %list = $addtok(%list,$calc(%a * 16 + 16 - 1) %y 3 -16 16,46)
        inc %a
        dec %c
      }
      if (!%no) %list = $regsubex(%list,/3(?= -?16 -?16$)/,1)
      var %a $4 - 1,%x $calc($3 * 16),%c $1 - 1,%no
      while (%c) && ($hget(map,$+($3,.,%a)) != 1) {
        if ($v1 == 3) {
          var %no 1
          %list1 = $addtok(%list1,%x $calc(%a * 16),46) 
          break
        }
        elseif ($v1 > 3) {
          var %no 1
          if ($v1 == 99) noop $hfind(bb,^\d+ \d+ $3 %a \d+$,0,r,hadd bb $1 $puttok($puttok($hget(bb,$1),1,2,32),$calc($ticks -40),5,32)).data
          else {
            hdel map $+($3,.,%a)
            var %w $findtok($hget(bb,bonuses),$wildtok($hget(bb,bonuses),$calc($3 * 16) $calc(%a * 16) &,1,46),46)
            hadd bb bonuses $deltok($hget(bb,bonuses),%w,46)
            hadd bb delbonus $addtok($hget(bb,delbonus),0 $3 %a $ticks,46)
          }
          break      
        }
        var %list = $addtok(%list,%x $calc(%a * 16) 2 16 16,46) 
        dec %a
        dec %c
      }
      if (!%no) %list = $regsubex(%list,/2(?= -?16 -?16$)/,0) 
      var %a $4 + 1,%x $calc($3 * 16),%c $1 - 1,%no
      while (%c) && ($hget(map,$+($3,.,%a)) != 1) {
        if ($v1 == 3) {
          %list1 = $addtok(%list1,%x $calc(%a * 16),46)
          var %no 1
          break
        }
        elseif ($v1 > 3) {
          var %no 1
          if ($v1 == 99) noop $hfind(bb,^\d+ \d+ $3 %a \d+$,0,r,hadd bb $1 $puttok($puttok($hget(bb,$1),1,2,32),$calc($ticks -40),5,32)).data
          else {
            hdel map $+($3,.,%a)
            var %w $findtok($hget(bb,bonuses),$wildtok($hget(bb,bonuses),$calc($3 * 16) $calc(%a * 16) &,1,46),46)
            hadd bb bonuses $deltok($hget(bb,bonuses),%w,46)
            hadd bb delbonus $addtok($hget(bb,delbonus),0 $3 %a $ticks,46)
          }
          break      
        }
        %list = $addtok(%list,%x $calc(%a * 16 + 16 - 1) 2 16 -16,46)
        inc %a
        dec %c
      }
      if (!%no) %list = $regsubex(%list,/2(?= -?16 -?16$)/,0)
      hdel bb %id
      hadd bb bombs $remtok($hget(bb,bombs),%id,32)
      hadd bb fires $addtok($hget(bb,fires),%id,32)
      hadd bb wes $addtok($hget(bb,we),%id,32)
      hadd bb fire $+ %id %list
      hadd bb firesprite $+ %id 0
      hadd bb we $+ %id %list1
      hadd bb weticks $+ %id $ticks
      hadd bb wesprite $+ %id 0
      hadd bb fireticks $+ %id $ticks
      hadd bb firetick $+ %id $ticks
      return
    }
    hadd bb %id $1 $calc($2 - 1) $3-4 $ticks
    tokenize 32 $hget(bb,%id)
  }
  if ($2 isin 951) var %x $calc(16*20)
  elseif ($2 isin 8642) var %x $calc(16*21)
  else var %x $calc(16*22)
  drawpic -ctn @bb 3168272 $calc($3 * 16) $calc($4 * 16) %x 0 16 16 $qt($scriptdirbbt.png)
}






on *:active:*:{
  if ($lactive == @sbm) && ($hget(sbm,view) == game) sockwrite -n sbmclient leavek



  if ($active == @sbm) && ($window(@pickcolor)) window -ao @pickcolor

}
alias keynumtodesc {
  var %list 08 BACKSPACE.09 TAB.0C CLEAR.0D ENTER.10 SHIFT.11 CTRL.12 ALT.13 PAUSE.14 CAPS LOCK.15 IME Kana/Hangul mode.16 IME On.17 IME Junja mode.18 IME final mode.19 IME Hanja mode.19 IME Kanji mode.1A IME Off.1B ESC.1C IME convert.1D IME nonconvert. $+ $&
    1E IME accept.1F IME mode change request.20 SPACEBAR.21 PAGE UP.22 PAGE DOWN.23 END.24 HOME.25 LEFT ARROW.26 UP ARROW.27 RIGHT ARROW.28 DOWN ARROW.29 SELECT.2A PRINT.2B EXECUTE.2C PRINT SCREEN.2D INSERT.2E DELETE.2F HELP.30 0.31 1.32 2.33 3.34 4.35 5.36 6.37 7. $+ $&
    38 8.39 9.41 A.42 B.43 C.44 D.45 E.46 F.47 G.48 H.49 I.4A J.4B K.4C L.4D M.4E N.4F O.50 P.51 Q.52 R.53 S.54 T.55 U.56 V.57 W.58 X.59 Y.5A Z.5B LEFT WINKEY.5C RIGHT WINKEY.5D APPLICATIONKEY.5F COMPUTER SLEEP.60 NUMPAD 0.61 NUMPAD 1.62 NUMPAD 2.63 NUMPAD 3. $+ $&
    64 NUMPAD 4.65 NUMPAD 5.66 NUMPAD 6.67 NUMPAD 7.68 NUMPAD 8.69 NUMPAD 9.6A MULTIPLY.6B ADD.6C SEPARATOR.6D SUBSTRACT.6E DECIMAL.6F DIVIDE.70 F1.71 F2.72 F3.73 F4.74 F5.75 F6.76 F7.77 F8.78 F9.79 F10.7A F11.7B F12.7C F13.7D F14.7E F15.7F F16. $+ $&
    80 F17.81 F18.82 F19.83 F20.84 F21.85 F22.86 F23.87 F24.90 NUM LOCK.91 SCROLL LOCK.92 OEM.93 OEM.94 OEM.95 OEM.96 OEM.A0 LEFT SHIFT.A1 RIGHT SHIFT.A2 LEFT CONTROL.A3 RIGHT CONTROL.A4 LEFT MENU.A5 RIGHT MENU.A6 BROWSER BACK.A7 BROWSER FORWARD. $+ $&
    A8 BROWSER REFRESH.A9 BROWSER STOP.AA BROWSER SEARCH.AB BROWSER FAVORITES.AC BROWSER HOME.AD VOLUME MUTE.AE VOLUME DOWN.AF VOLUME UP.B0 MEDIA NEXT TRACK.B1 MEDIA PREVIOUS TRACK.B2 MEDIA STOP.B3 MEDIA PLAY/PAUSE.B4 LAUNCH MAIL.B5 LAUNCH MEDIA SELECT. $+ $&
    B6 LAUNCH_APP1.B7 LAUNCH APP2.BA OEM 1.BB OEM PLUS.BC OEM COMMA.BD OEM MINUS.BE OEM PERIOD.BF OEM 2.C0 OEM 3.DB OEM 4.DC OEM 5.DD OEM 6.DE OEM 7.DF OEM 8.E1 OEM specific.E2 OEM 102.E3 OEM specific.E4 OEM specific.E5 IME PROCESS.E6 OEM specific. $+ $&
    E9 OEM specific. EA OEM specific.EB OEM specific.EC OEM specific.ED OEM specific.EF OEM specific.F0 OEM specific.F1 OEM specific.F2 OEM specific.F3 OEM specific.F4 OEM specific.F5 OEM specific.F6 ATTN.F7 CRSEL.F8 EXSEL.F9 EREOF.FA PLAY.FB ZOOM.FD PA1.FE OEM CLEAR
  var %w $wildtok(%list,$base($1,10,16,2) *,1,46)
  tokenize 32 %w
  return $iif($2-,$2-,Press the new key)
}

menu @sbmpopups {
  Sbm
  .Connect with nick﹕ $me : sbm $mid($1,7) $+ : $+ $me
  .Connect... : sbm $mid($1,7)
}
alias sbmscheme return /\bsbm:\/{2}([^:]+)/
on $*:hotlink:$($sbmscheme):*:{
  if ($iptype($regml(1)) != $null) {
    if ($hotlink(event) == rclick) hotlink -m @sbmpopups
    elseif ($v1 == dclick) sbm
  }
  else return
}
on *:keyup:@sbm:37,38,39,40,32:if ($hget(sbm,view) == game) sockwrite -n sbmclient moveu $keyval
on *:keydown:@sbm:*:{
  echo -s $keychar -- $keyval
  if ($hget(sbm,view) == game) {
    if (!$keyrpt) && ($istok(32 37 38 39 40,$keyval,32)) {
      ; if ($keyval == 32) .timer -ho 1 12 sbmanimbomb
      sockwrite -n sbmclient moved $keyval
    }
  }
  elseif ($v1 == options) {

    ;echo -s $keyval -- $qt($keychar)
    if ($hget(sbm,keytemp)) {
      if ($v1 == $mid($hget(sbmoptions,keyleft),2)) {
        hadd sbmoptions keyleft $keyval
        hdel sbm keytemp
      }
      elseif ($v1 == $mid($hget(sbmoptions,keyright),2)) {
        hadd sbmoptions keyright $keyval
        hdel sbm keytemp
      }
      elseif ($v1 == $mid($hget(sbmoptions,keyup),2)) {
        hadd sbmoptions keyup $keyval
        hdel sbm keytemp
      }
      elseif ($v1 == $mid($hget(sbmoptions,keydown),2)) {
        hadd sbmoptions keydown $keyval
        hdel sbm keytemp
      }
      elseif ($v1 == $mid($hget(sbmoptions,keybomb),2)) {
        hadd sbmoptions keybomb $keyval
        hdel sbm keytemp
      }
    }
  }
  elseif (sbmedit* iswm $hget(sbm,focus)) {
    var %h $hget(sbm,focus),%t $hget(%h,editbox),%p $hget(%h,cursor)
    echo -s ?? $keyval -- $qt($keychar)
    if ($keyval == 8) {
      if ($hget(%h,sel)) {
        tokenize 32 $v1
        var %l $iif($1 > 0,$left(%t,$1))
        var %r $mid(%t,$calc($2 + 1)) 
        hadd %h editbox $+(%l,%r)
        hdel %h sel
      }
      else {
        var %l $iif(%p > 1,$left(%t,$calc(%p - 1)))
        var %r $mid(%t,$calc(%p + 1)) 
        hadd %h editbox $+(%l,%r)
        if (%p > 0) hdec %h cursor
      }
    }
    ;control+v
    elseif ($keyval == 22) {
      if ($crlf !isin $cb) {
        if ($hget(%h,sel)) {
          tokenize 32 $v1
          var %cb $$regsubex($replace($cb,$chr(32),$chr(160),$chr(10),,$chr(9),,$chr(13),),/\xED[\xA0-\xAF][\x80-\xBF](?!\xED[\xB0-\xBF][\x80-\xBF]|\xED[\xB0-\xBF][\x80-\xBF](?!\xED[\xA0-\xAF][\x80-\xBF]))/,$chr(65533))
          var %l $iif($1 > 0,$left(%t,$1))
          var %r $mid(%t,$calc($2 + 1))
          var %t $+(%l,%cb,%r)
          if ($width(%t,$hget(%h,font),$hget(%h,fontsize)) > $calc($hget(%h,w) - 20)) return
          hadd %h editbox %t
          hinc %h cursor $len(%cb)
          if (%p == $2) hdec %h cursor $calc($2 - $1)
          hdel %h sel
        }
        else {
          var %cb $$regsubex($replace($cb,$chr(32),$chr(160),$chr(10),,$chr(9),$chr(9),$chr(13),),/\xED[\xA0-\xAF][\x80-\xBF](?!\xED[\xB0-\xBF][\x80-\xBF]|\xED[\xB0-\xBF][\x80-\xBF](?!\xED[\xA0-\xAF][\x80-\xBF]))/,$chr(65533))
          var %l $iif(%p > 0,$left(%t,%p))
          var %r $mid(%t,$calc(%p + 1))
          var %t $+(%l,%cb,%r)
          if ($width(%t,$hget(%h,font),$hget(%h,fontsize)) > $calc($hget(%h,w) - 20)) return
          hadd %h editbox %t
          hinc %h cursor $len(%t)
        }
      }
      else {
        if ($hget(%h,sel)) {
          tokenize 32 $v1
          var %cb $$regsubex($replace($cb,$chr(32),$chr(160),$chr(10),,$chr(9),,$chr(13),),/\xED[\xA0-\xAF][\x80-\xBF]/,$chr(65533))
          var %l $iif($1 > 0,$left(%t,$1))
          var %r $mid(%t,$calc($2 + 1))
          var %t $+(%l,%cb,%r)
          var %a 1,%b $numtok(%t,10)
          while (%a <= %b) {
            if (%h == sbmeditchat) sockwrite -n sbmclient TEXT $gettok(%t,%a,10)
            elseif ($hget(sbm,view) == connect) || ($v1 == create) {
              if ($width($gettok(%t,%a,10),$hget(%h,font),$hget(%h,fontsize)) > $calc($hget(%h,w) - 20)) return
              hadd %h editbox $gettok(%t,%a,10)
              return
            }
            hadd -m %h $+ history $calc($hget(%h $+ history,0).item + 1) $gettok(%t,%a,10)
            inc %a
          }   
          hadd %h history 0
          hadd %h editbox
          hadd %h cursor 0a
          hdel %h sel
        }
        else {
          var %cb $$regsubex($replace($cb,$chr(32),$chr(160),$chr(10),,$chr(9),,$chr(13),),/\xED[\xA0-\xAF][\x80-\xBF](?!\xED[\xB0-\xBF][\x80-\xBF]|\xED[\xB0-\xBF][\x80-\xBF](?!\xED[\xA0-\xAF][\x80-\xBF]))/,$chr(65533))
          var %l $iif(%p > 0,$left(%t,%p))
          var %r $mid(%t,$calc(%p + 1))
          var %t $remove($+(%l,%cb,%r),$chr(13),$chr(9))
          var %a 1,%b $numtok(%t,10)
          while (%a <= %b) {
            if (%h == sbmeditchat) sockwrite -n sbmclient TEXT $gettok(%t,%a,10)
            elseif ($hget(sbm,view) == connect) || ($v1 == create) {
              if ($width($gettok(%t,%a,10),$hget(%h,font),$hget(%h,fontsize)) > $calc($hget(%h,w) - 20)) return
              hadd %h editbox $gettok(%t,%a,10)
              return
            }
            hadd -m %h $+ history $calc($hget(%h $+ history,0).item + 1) $gettok(%t,%a,10)

            inc %a
          }
          hadd %h history 0
          hadd %h editbox
          hadd %h cursor 0
        }
      }
    }
    ;#TAB
    elseif ($keyval == 9) {
      if ($hget(sbm,view) == connect) {
        var %l sbmeditip sbmeditport sbmeditnick
        var %f $findtok(%l,%h,32)
        inc %f
        if (%f > $numtok(%l,32)) %f = 1
        hdel %h sel 
        hadd sbm focus $gettok(%l,%f,32)
        %h = $hget(sbm,focus)
        if ($hget(%h,editbox) != $null) {
          hadd %h sel 0 $len($v1)
          hadd %h cursor $len($v1)
        }
      }
      elseif ($hget(sbm,view) == create) {
        var %l sbmeditservport sbmeditservnick
        var %f $findtok(%l,%h,32)
        inc %f
        if (%f > $numtok(%l,32)) %f = 1
        hdel %h sel 
        hadd sbm focus $gettok(%l,%f,32)
        %h = $hget(sbm,focus)
        if ($hget(%h,editbox) != $null) {
          hadd %h sel 0 $len($v1)
          hadd %h cursor $len($v1)
        }
      }
      elseif ($v1 == connected) {
        if ($hget(%h,sel)) return    
        if ($regex($left($hget(sbmeditchat,editbox),$hget(sbmeditchat,cursor)),/.*\B@(\S*)/u)) {
          if ($hget(sbm,tabcomp)) {
            hinc sbm tabc
            if ($hget(sbm,tabc) > $wildtok($hget(sbm,nicks),$v1,0,32)) hadd sbm tabc 1
            var %cb $wildtok($hget(sbm,nicks),$hget(sbm,tabcomp),$hget(sbm,tabc),32),%p1 $regml(1).pos - 1
            var %l $iif(%p1 > 0,$left(%t,%p1))
            var %r $mid(%t,$calc(%p1 + $hget(sbm,tabcompold) + 1)),%a
            var %t $+(%l,%cb,%r)
            if ($width(%t,$hget(%h,font),$hget(%h,fontsize)) > $calc($hget(%h,w) - 20)) return
            hdec %h cursor $hget(tabcompold)
            hadd %h editbox %t
            hadd %h cursor $calc(%p1 + $len(%cb))
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
            if ($width(%t,$hget(%h,font),$hget(%h,fontsize)) > $calc($hget(%h,w) - 20)) return
            hadd sbm tabcomp $regml(1) $+ *
            hadd sbm tabcompold $len(%cb)
            hadd %h editbox %t
            hinc %h cursor $len(%cb)
          }
        }
        else {
          hdel sbm tabc
          hdel sbm tabcomp
        }
      }
    }
    ;ctrl A
    elseif ($keyval == 1) {
      if ($hget(%h,editbox) != $null) {
        hadd %h sel 0 $len($v1)
        hadd %h cursor $len($v1)
      }
    }
    ;#arrow
    elseif ($keyval $+ $keychar == 37) {

      if ($mouse.key & 4) {
        tokenize 32 $hget(%h,sel)
        if ($2 > %p) {
          if (%p != $calc($iif($hget(%h,sel),$gettok($hget(%h,sel),2,32),%p) -1)) {
            if ($v2 <= $len(%t)) {
              hadd %h sel %p $v1
            }
          }
          else hdel %h sel
        }
        else {
          if ($calc($iif($hget(%h,sel),$gettok($hget(%h,sel),1,32),%p) -1) != %p) {
            if ($v1 >= 0) {
              hadd %h sel $v1 %p
            }
          }
          else hdel %h sel
        }
      }
      else {
        if ($hget(%h,sel)) {
          hadd %h cursor $gettok($v1,1,32)
        }
        elseif (%p > 0) hdec %h cursor
        hdel %h sel
      }
    }
    elseif ($keyval $+ $keychar == 39) {
      if ($mouse.key & 4) {
        tokenize 32 $hget(%h,sel)
        if ($2 > %p) || ($1 == $null) {
          if (%p != $calc($iif($hget(%h,sel),$gettok($hget(%h,sel),2,32),%p) +1)) {
            if ($v2 <= $len(%t)) {
              hadd %h sel %p $v1
            }
          }
        }
        else {
          if (%p != $calc($iif($hget(%h,sel),$gettok($hget(%h,sel),1,32),%p) +1)) {
            if ($v2 <= $len(%t)) {
              hadd %h sel $v1 %p
            }
          }

          else hdel %h sel
        }
      }
      else {
        if ($hget(%h,sel)) {
          hadd %h cursor $gettok($v1,2,32)
        }
        elseif (%p < $len(%t)) hinc %h cursor
        hdel %h sel    
      }
    }
    elseif ($keyval $+ $keychar == 38) {
      hinc %h history
      var %c $calc($hget(%h $+ history,0).item - $hget(%h,history) + 1)
      if (%c == 0) {
        hdec %h history
        return 
      }
      hdel %h sel
      hadd %h editbox $hget(%h $+ history,%c)
      hadd %h cursor $len($hget(%h,editbox))

    }
    elseif ($keyval $+ $keychar == 40) {
      hdec %h history
      var %c $calc($hget(%h $+ history,0).item - $hget(%h,history) + 1)
      if (%c <= $hget(%h $+ history,0).item) { 
        hdel %h sel
        hadd %h editbox $hget(%h $+ history,%c)
        hadd %h cursor $len($hget(%h,editbox))
      }
      else {
        if ($hget(%h,history) == -1) && ($hget(%h,history) != $null) && ($hget(%h,editbox) != $null) {
          hadd -m %h $+ history $calc($hget(%h $+ history,0).item + 1) $hget(%h,editbox)
          hadd -m %h history 0
        }
        hdel %h sel
        hadd %h editbox
        hadd %h cursor 0
        hadd %h history 0
      }
    }
    elseif ($keyval == 46) && ($keychar == $null) {
      if ($hget(%h,sel)) {
        tokenize 32 $v1
        var %l $iif($1 > 0,$left(%t,$1))
        var %r $mid(%t,$calc($2 + 1)) 
        hadd %h editbox $+(%l,%r)
        if ($2 == %p) hdec %h cursor $calc($2 - $1)
        hdel %h sel
      }
      else {
        var %l $iif(%p > 0,$left(%t,%p))
        var %r $mid(%t,$calc(%p + 2)) 
        hadd %h editbox $+(%l,%r)
      }
    }
    elseif ($keyval $+ $keychar == 35) {
      if ($mouse.key & 4) {
        if (%p != $len(%t)) hadd %h sel %p $len(%t) 
        else hdel %h sel
      }
      else hadd %h cursor $len(%t)
    }
    elseif ($keyval $+ $keychar == 36) {
      if ($mouse.key & 4) {
        if (0 != %p) hadd %h sel 0 %p 
        else hdel %h sel
      }
      else hadd %h cursor 0
    }
    ;ENTER
    elseif ($keyval == 13) || ($keyval == 10) {
      if (%h == sbmeditchat) {
        sockwrite -n sbmclient TEXT $$hget(%h,editbox)
        if (!$hget(%h,history)) hadd -m %h $+ history $calc($hget(%h $+ history,0).item + 1) $hget(%h,editbox)
        hadd %h history 0
        hdel %h sel
        hadd %h editbox
        hadd %h cursor 0
      }
      elseif ((%h == sbmeditservport) || (%h == sbmeditservnick)) && ($istok(2 3 4,$hget(sbm,hovercreate),32)) {
        if ($hget(sbmserv)) return
        sbmserv $hget(sbmeditservport,editbox) restart
        sbmclientconnect 127.0.0.1 $hget(sbmeditservport,editbox) $hget(sbmeditservnick,editbox)
      }
      elseif ((%h == sbmeditip) || (%h == sbmeditport) || (%h == sbmeditnick)) && ($istok(2 3 4,$hget(sbm,hoverconnect),32)) {
        sbmclientconnect $hget(sbmeditip,editbox) $hget(sbmeditport,editbox) $hget(sbmeditnick,editbox)
      }
    }
    elseif ($keyval == 17) {

    }
    elseif ($keyval == 18) {

    }
    ;control+x
    elseif ($keyval == 24) {
      if ($hget(%h,sel)) {
        tokenize 32 $v1
        clipboard $mid(%t,$calc($1 + 1),$calc($2 - $1))
        var %l $iif($1 > 0,$left(%t,$1))
        var %r $mid(%t,$calc($2 + 1)) 
        hadd %h editbox $+(%l,%r)
        hdel %h sel      
        if (%p == $2) hdec %h cursor $calc($2 - $1)
      }
    }
    ;control+c
    elseif ($keyval == 3) {
      if ($hget(%h,sel)) {
        tokenize 32 $v1
        clipboard $mid(%t,$calc($1 + 1),$calc($2 - $1))
      }
    }
    elseif ($keychar != $null) {
      if $hget(%h,sel) {
        tokenize 32 $v1
        var %l $iif($1 > 0,$left(%t,$1))
        var %c $iif($keyval == 32,$chr(160),$keychar)
        var %r $mid(%t,$calc($2 + 1))
        hadd %h editbox $+(%l,%c,%r)
        hdel %h sel
      }
      else {
        var %l $iif(%p > 0,$left(%t,%p))
        var %c $iif($keyval == 32,$chr(160),$keychar)
        var %r $mid(%t,$calc(%p + 1))
        if ($width($+(%l,%c,%r),$hget(%h,font),$hget(%h,fontsize)) > $calc($hget(%h,w) - 20)) return
        hadd %h editbox $+(%l,%c,%r)
        hinc %h cursor
      }
    }
    if ($hget(sbm,view) == connect) {
      if ($iptype($hget(sbmeditip,editbox)) != $null) && ($regex($hget(sbmeditport,editbox),$sbmreg_validport)) && ($hget(sbmeditnick,editbox) != $null) {
        hadd sbm hoverconnect 2
      }
      else hdel sbm hoverconnect
    }
    elseif ($v1 == connected) {
      if ($keyval != 9) {
        hdel sbm tabc
        hdel sbm tabcomp
        hdel sbm tabcompold
      }
    }
    elseif ($hget(sbm,view) == create) {
      if ($regex($hget(sbmeditservport,editbox),$sbmreg_validport)) && ($hget(sbmeditservnick,editbox) != $null) {
        hadd sbm hovercreate 2
      }
      else hdel sbm hovercreate
    }
  }
}
/*on *:signal:cwnd:{
  ;  if (test* iswm $1) {
  ;   if ($right($2,1) == 1) echo -s > WM_DEADCHAR $3-
  ;   elseif ($2 == test) echo -s > WM_KEYDOWN $2-
  ;   else echo -s ^> $2-
  ;     }
  ;}
*/
alias sbmaddtext {
  if ($hget(sbm,scroll) == $hget(sbmchat,0).item) || (!$hget(sbm,scroll)) hadd sbm scroll $calc($v2 + 1)

  hadd -m sbmchat $calc($hget(sbmchat,0).item + 1) $1-
  var %maxview $calc($window(@sbm).dh - $gettok($hget(sbm,chatarea),2,32) - 42)
  var %total $calc($hget(sbmchat,0).item * 18)
  var %scroll $calc($window(@sbm).dh - $gettok($hget(sbm,chatarea),2,32) - 59)
  var %h $calc(%maxview / %total * %scroll)
  if (%h <= %scroll) {
    hadd sbm scrollratio $calc(%maxview / %total)
    hadd sbm hscroll %h
    hadd sbm wscroll 10
    hadd sbm xscroll $calc($window(@sbm).dw - 14)
    hadd sbm yscroll $calc($window(@sbm).dh -43 - %h)
  }
}
alias sbm {
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
  drawrect -fr @sbm 3168272 0 0 0 800 600
  .hmake sbm
  tokenize 58 $1
  if ($iptype($1) != $null) && ($regex($2,$sbmreg_validport)) {
    sbmchangeview connect
    hadd  sbmeditip editbox $1
    hadd  sbmeditport editbox $2
    if ($3 != $null) {
      hadd sbmeditnick editbox $3
      sbmclientconnect $hget(sbmeditip,editbox) $hget(sbmeditport,editbox) $hget(sbmeditnick,editbox)
    }
  }
  else {
    hadd sbm view init
  }
  sbmlobbyloop
}
alias sbmchangeview {

  if ($1 == connect) {

    hadd sbm focus sbmeditip

    ;x y w h W H bg_rgb cursor
    if (!$hget(sbmeditip)) {

      hadd -m sbmeditip bg 8355711
      hadd sbmeditip cursor
      hadd sbmeditip x 380
      hadd sbmeditip y 272
      hadd sbmeditip w 160
      hadd sbmeditip h 25
      hadd sbmeditip i 15
      hadd sbmeditip e 15
      hadd sbmeditip font segoe ui symbol
      hadd sbmeditip fontsize 15

      hadd sbmeditip fc $hget(sbmeditip,x) $hget(sbmeditip,y) $hget(sbmeditip,w) $hget(sbmeditip,h) $hget(sbmeditip,i) $hget(sbmeditip,e)


      hadd -m sbmeditport bg 8355711
      hadd sbmeditport cursor
      hadd sbmeditport x 380
      hadd sbmeditport y 352
      hadd sbmeditport w 80
      hadd sbmeditport h 25
      hadd sbmeditport i 15
      hadd sbmeditport e 15
      hadd sbmeditport font segoe ui symbol
      hadd sbmeditport fontsize 15
      hadd sbmeditport fc $hget(sbmeditport,x) $hget(sbmeditport,y) $hget(sbmeditport,w) $hget(sbmeditport,h) $hget(sbmeditport,i) $hget(sbmeditport,e)

      hadd -m sbmeditnick bg 8355711
      hadd sbmeditnick cursor $len($me)
      hadd sbmeditnick x 380
      hadd sbmeditnick y 432
      hadd sbmeditnick w 90
      hadd sbmeditnick h 25
      hadd sbmeditnick i 15
      if ($len($me)) hadd sbmeditnick sel 0 $len($me)
      hadd sbmeditnick editbox $me
      hadd sbmeditnick e 15
      hadd sbmeditnick font segoe ui symbol
      hadd sbmeditnick fontsize 15
      hadd sbmeditnick fc $hget(sbmeditnick,x) $hget(sbmeditnick,y) $hget(sbmeditnick,w) $hget(sbmeditnick,h) $hget(sbmeditnick,i) $hget(sbmeditnick,e)
    }
  }
  elseif ($1 == create) {
    hadd sbm focus sbmeditservport
    if (!$hget(sbmeditservport)) {
      hadd -m sbmeditservport bg 8355711
      hadd sbmeditservport cursor 4
      hadd sbmeditservport editbox 8000
      hadd sbmeditservport sel 0 4
      hadd sbmeditservport x 380
      hadd sbmeditservport y 352
      hadd sbmeditservport w 80
      hadd sbmeditservport h 25
      hadd sbmeditservport i 15
      hadd sbmeditservport e 15
      hadd sbmeditservport font segoe ui symbol
      hadd sbmeditservport fontsize 15
      hadd sbmeditservport fc $hget(sbmeditservport,x) $hget(sbmeditservport,y) $hget(sbmeditservport,w) $hget(sbmeditservport,h) $hget(sbmeditservport,i) $hget(sbmeditservport,e)

      hadd -m sbmeditservnick bg 8355711
      hadd sbmeditservnick cursor $len($me)
      hadd sbmeditservnick x 380
      hadd sbmeditservnick y 432
      hadd sbmeditservnick w 90
      hadd sbmeditservnick h 25
      hadd sbmeditservnick i 15
      if ($len($me)) hadd sbmeditservnick sel 0 $len($me)
      hadd sbmeditservnick editbox $me
      hadd sbmeditservnick e 15
      hadd sbmeditservnick font segoe ui symbol
      hadd sbmeditservnick fontsize 15
      hadd sbmeditservnick fc $hget(sbmeditservnick,x) $hget(sbmeditservnick,y) $hget(sbmeditservnick,w) $hget(sbmeditservnick,h) $hget(sbmeditservnick,i) $hget(sbmeditservnick,e)
    }
  }
  elseif ($v1 == connected) {
    hadd sbm focus sbmeditchat
    hadd sbm chatarea 0 400
    if (!$hget(sbmeditchat))  {
      hadd -m sbmeditchat bg 8355711
      hadd sbmeditchat cursor
      hadd sbmeditchat x 50
      hadd sbmeditchat y 560
      hadd sbmeditchat w 700
      hadd sbmeditchat h 25
      hadd sbmeditchat i 15
      hadd sbmeditchat e 15
      hadd sbmeditchat font segoe ui symbol
      hadd sbmeditchat fontsize 15
      hadd sbmeditchat fc $hget(sbmeditchat,x) $hget(sbmeditchat,y) $hget(sbmeditchat,w) $hget(sbmeditchat,h) $hget(sbmeditchat,i) $hget(sbmeditchat,e)
    }
  }
  elseif ($v1 == init) {
    hdel sbm drawcursor
    hdel sbm focus
    hdel sbm sockstate 0
    if ($hget(sbm,view) == connected) {
      sockclose sbmclient
      hdel -w sbm nick*
      hdel sbm owner
      hdel -w sbm player?
      hdel sbm scroll
      hfree -w sbmchat
      hdel sbmeditchat editbox
      hdel sbmeditchat sel
      hdel sbmeditchat cursor
      if ($isalias(sbmserv)) sbmserv stop
    }
  }
  elseif ($v1 == game) {
    hdel sbm drawcursor
    hdel sbm focus
    hadd sbm bonustile 0
  }
  if ($hget(sbm,view) == connected) {
    hfree -w sbmchat
    hdel sbmeditchat editbox
    hdel sbmeditchat sel
    hdel sbmeditchat cursor
    hdel -w sbm *scroll
    hdel -w sbm player?
  }
  elseif ($v1 == options) {
    if ($hget(sbm,temp)) {
      if ($v1 == $mid($hget(sbmoptions,keyleft),2)) {
        hadd sbmoptions keyleft $hget(sbm,keytemp)
        hdel sbm keytemp
      }
      elseif ($v1 == $mid($hget(sbmoptions,keyright),2)) {
        hadd sbmoptions keyright $hget(sbm,keytemp)
        hdel sbm keytemp
      }
      elseif ($v1 == $mid($hget(sbmoptions,keyup),2)) {
        hadd sbmoptions keyup $hget(sbm,keytemp)
        hdel sbm keytemp
      }
      elseif ($v1 == $mid($hget(sbmoptions,keydown),2)) {
        hadd sbmoptions keydown $hget(sbm,keytemp)
        hdel sbm keytemp
      }
      elseif ($v1 == $mid($hget(sbmoptions,keybomb),2)) {
        hadd sbmoptions keybomb $hget(sbm,keytemp)
        hdel sbm keytemp
      }
    }
    if ($hget(sbmoptions,keyleft) !isnum 1-) hadd sbmoptions keyleft 37
    if ($hget(sbmoptions,keyright) !isnum 1-) hadd  sbmoptions keyright 39
    if ($hget(sbmoptions,keyup) !isnum 1-) hadd sbmoptions keyup 38
    if ($hget(sbmoptions,keydown) !isnum 1-) hadd sbmoptions keydown 40
    if ($hget(sbmoptions,keybomb) !isnum 1-) hadd sbmoptions keybomb 32
    hsave sbmoptions $qt($scriptdirsbm.sbm)
  }
  hdel -w sbm hover*
  hadd sbm view $1
}
alias sbmdraweditbox {
  var %h $1
  drawrect -dfrn @sbm $hget(%h,bg) 0 $hget(%h,fc)
  var %p $hget(%h,cursor),%t $hget(%h,editbox)
  if ($hget(%h,editbox)) {
    var %v $v1
    if ($hget(%h,sel)) {
      tokenize 32 $v1
      var %l $iif($1 > 0,$left(%t,$1))
      var %m $mid(%t,$calc($1 + 1),$calc($2 - $1))
      var %r $mid(%t,$calc($2 + 1))
      drawtext -rn @sbm $hget(sbmoptions,coloredittext) $qt($hget(%h,font)) $hget(%h,fontsize) $calc($hget(%h,x) + 10) $calc($hget(%h,y) + 3) %v
      drawtext -rbn @sbm $hget(sbmoptions,coloreditseltext) $hget(sbmoptions,coloreditselbg) $qt($hget(%h,font)) $hget(%h,fontsize) $calc($hget(%h,x) + 10 + $width(%l,$hget(%h,font),$hget(%h,fontsize))) $calc($hget(%h,y) + 3) %m
    }
    else drawtext -rn @sbm $hget(sbmoptions,coloredittext) $qt($hget(%h,font)) $hget(%h,fontsize) $calc($hget(%h,x) + 10) $calc($hget(%h,y) + 3) %v
  }
}
on *:keydown:@test:38: moveup

on *:keydown:@test:40: movedown

alias -l moveup {
  var %current = $hget(lines,current)

  if (%current < $calc($hfind(lines,line_*,0,w) - 4)) {
    hinc lines current
    inc %current
    drawscroll @test 0 -20 0 0 100 100
    drawrect -rf @test $rgb(255,255,255) 1 0 80 100 20
    drawtext -r @test 0 impact 16 2 81 $hget(lines,$+(line_,$calc(%current + 4)))

    drawscrollbar
  }
}

alias -l movedown {
  var %current = $hget(lines,current)

  if ($hget(lines,current) > 1) {
    hdec lines current
    dec %current
    drawscroll @test 0 20 0 0 100 100
    drawrect -rf @test $rgb(255,255,255) 1 0 0 100 20
    drawtext -r @test 0 impact 16 2 1 $hget(lines,$+(line_,%current))

    drawscrollbar
  }
}

alias scrollTest {
  window -pdBCf +Lt @test 0 0 100 120
  drawrect -rf @test $rgb(255,255,255) 1 0 0 100 120

  drawtext -r @test $rgb(0,100,0) impact 16 2 101 UNCHANGED

  hmake lines 1
  hadd lines current 1

  var %i = 1

  while (%i < 16) {
    hadd lines $+(line_,%i) Line: %i
    if (%i < 6) {
      drawtext -r @test 0 impact 16 2 $calc(((%i - 1) * 20) + 1) Line: %i
    }
    inc %i
  }

  drawscrollbar
}

alias -l drawscrollbar {
  drawrect -rf @test $rgb(0,0,100) 1 80 0 20 100

  var %lines = $hfind(lines,line_*,0,w)
  var %height = 100
  var %showing = 5
  var %content = $calc(%lines * 20)
  var %scroll = %height
  var %visible = $calc(%height / %content)
  var %thumb = $calc(%scroll * %visible)
  var %jump = $calc((%scroll - %thumb) / (%lines - %showing))

  drawrect -rf @test $rgb(100,0,0) 1 80 $calc(%jump * ($hget(lines,current) - 1)) 20 %thumb
}

menu @test  {
  sclick: checkmouse $mouse.x $mouse.y
  mouse: checkmouse $mouse.x $mouse.y
}

alias -l checkmouse {
  if ($inrect($1,$2,80,0,20,100)) && ($mouse.key & 1) {
    var %lines = $hfind(lines,line_*,0,w)
    var %showing = 5
    var %current = $hget(lines,current)
    var %line = $round($calc(($2 / 100) * (%lines - %showing) + 1),0) 

    echo -s : %line

    if (%line > %current) moveup
    elseif (%line < %current) movedown

    .timerscrolling -h 1 200 checkmouse $1-
  }
}

on *:close:@test: hfree lines


alias sbmlobbyloop {

  if ($hget(sbm,view) == init) {
    var %n 65,%w $window(@sbm).dw,%wo 800,%s 130,%h $window(@sbm).dh,%ho 600,%yinc 100
    var %dn $calc((%w - %wo) / 100)
    var %dy $calc((%h - %ho) / 10)
    if (%dn < 0) {
      %dn = $calc((%w - %wo) / 12)
      %yinc = $calc(100 + $v1 * 7)
    }
    if (%dy < -50) %dy = -50
    %n = $calc(%n + %dn)
    if (%n < 2) %n = 2
    elseif (%n > 65) {
      if (%dy < -10) {
        %n = $calc(%n - 8* (%n - 65))

      }
    }
    echo -s %dy -- %n %dn -- %yinc


    drawrect -frn @sbm $hget(sbmoptions,colormainbg) 0 0 0 $window(@sbm).dw $window(@sbm).dh


    if (%dy >= 9) %dy = %dy / 6
    var %i $iif($calc(%h - 400) < 100,100,$v1)
    var %yy 60
    if (%dn < -1) {
      inc %yy $calc(%dn * $iif(%dy < -30,-1.1,-1.4))
      ;  if (%dy < -33) dec -s %yy $calc(%dn * -1.4)
      dec %n 6
    }
    elseif (%dy < -1) {
      inc %yy 20
      %yinc = 80
    }

    %y = $calc(%i + %yy + %dy)
    drawpic -cstn @sbm 16777215 0 50 %w %i $qt($scriptdirlogo.png)
    var %width $width(Connect to a game,segoe ui symbol,%n,1)
    var %xn $calc(%w / 2 - %width / 2)

    drawtext -rno @sbm $iif($hget(sbm,hoverinit) == 1,$hget(sbmoptions,colorhoverhltext),$hget(sbmoptions,colorhltext)) "segoe ui symbol" %n %xn %y Connect to a game
    var %width $width(Create a game,segoe ui symbol,%n,1)
    var %xn $calc(%w / 2 - %width / 2)
    drawtext -ron @sbm $iif($hget(sbm,hoverinit) == 2,$hget(sbmoptions,colorhoverhltext),$hget(sbmoptions,colorhltext)) "segoe ui symbol" %n %xn $calc(%y + %yinc + %dy) Create a game
    var %width $width(Options,segoe ui symbol,%n,1)
    var %xn $calc(%w / 2 - %width / 2)

    drawtext -ron @sbm $iif($hget(sbm,hoverinit) == 3,$hget(sbmoptions,colorhoverhltext),$hget(sbmoptions,colorhltext)) "segoe ui symbol" %n %xn $calc($calc(%y + %yinc * 2 + %dy * 2 )) Options
  }
  elseif ($v1 == options) {
    drawrect -frn @sbm $hget(sbmoptions,colormainbg) 0 0 0 $window(@sbm).dw $window(@sbm).dh
    drawtext -rnp @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 25 280 10 $chr(31) $+ Options
    drawtext -rn @sbm $iif($hget(sbm,hoveroptions) == 6,$hget(sbmoptions,colorhoverhltext),$hget(sbmoptions,colorhltext)) "segoe ui symbol" 20 10 5 $chr(8592) Back

    drawtext -rnp @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 20 20 60 $chr(31) $+ Keys Configuration

    var %kl $keynumtodesc($hget(sbmoptions,keyleft)),%kr $keynumtodesc($hget(sbmoptions,keyright)),%ku $keynumtodesc($hget(sbmoptions,keyup)),%kd $keynumtodesc($hget(sbmoptions,keydown)),%kb $keynumtodesc($hget(sbmoptions,keybomb))

    var %n $regex($+(%kl,@,%kr,@,%ku,@,%kd,@,%kb),/(?:^|(?<=@))([^@]++)@(?=(?:(?!\1)[^@]++@)*\1(?:@|$))/g)
    while (%n) {
      var %l $addtok(%l,$regml(%n),64)
      dec %n
    }
    var %a 1
    while ($gettok(%l,%a,64)) {
      var %b 1,%v $v1
      while ($gettok($+(%kl,@,%kr,@,%ku,@,%kd,@,%kb),%b,64)) {
        if ($v1 == %v) {
          drawrect -rn @sbm $hget(sbmoptions,colorconnecterrormsg) 1 95 $calc(100 + (%b - 1) * 30 - 3) $calc($width($v1,segoe ui symbol,15) + 10) 25
        }
        inc %b
      }
      inc %a
    }
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 100 Left
    if (%kl == Press the new key) {
      drawtext -rn @sbm 13816530 "segoe ui symbol" 15 100 100 Press the new key
      drawtext -rn @sbm $iif($hget(sbm,hoveroptions) == 6,$hget(sbmoptions,colorhovercancel),$hget(sbmoptions,colorcancel)) "segoe ui symbol" 15 300 100 $chr(10008)
    }
    else drawtext -rn @sbm $iif($hget(sbm,hoveroptions) == 1,$hget(sbmoptions,colorhoverhltext),$hget(sbmoptions,colorhltext)) "segoe ui symbol" 15 100 100 %kl

    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 130 Right
    if (%kr == Press the new key) {
      drawtext -rn @sbm 13816530 "segoe ui symbol" 15 100 130 Press the new key
      drawtext -rn @sbm $iif($hget(sbm,hoveroptions) == 9,$hget(sbmoptions,colorhovercancel),$hget(sbmoptions,colorcancel)) "segoe ui symbol" 15 300 130 $chr(10008)
    }
    else drawtext -rn @sbm $iif($hget(sbm,hoveroptions) == 2,$hget(sbmoptions,colorhoverhltext),$hget(sbmoptions,colorhltext)) "segoe ui symbol" 15 100 130 %kr

    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 160 Up
    if (%ku == Press the new key) {
      drawtext -rn @sbm 13816530 "segoe ui symbol" 15 100 160 Press the new key
      drawtext -rn @sbm $iif($hget(sbm,hoveroptions) == 10,$hget(sbmoptions,colorhovercancel),$hget(sbmoptions,colorcancel)) "segoe ui symbol" 15 300 160 $chr(10008)
    }
    else drawtext -rn @sbm $iif($hget(sbm,hoveroptions) == 3,$hget(sbmoptions,colorhoverhltext),$hget(sbmoptions,colorhltext)) "segoe ui symbol" 15 100 160 %ku

    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 190 Down
    if (%kd == Press the new key) {
      drawtext -rn @sbm 13816530 "segoe ui symbol" 15 100 190 Press the new key
      drawtext -rn @sbm $iif($hget(sbm,hoveroptions) == 11,$hget(sbmoptions,colorhovercancel),$hget(sbmoptions,colorcancel)) "segoe ui symbol" 15 300 190 $chr(10008)
    }
    else drawtext -rn @sbm $iif($hget(sbm,hoveroptions) == 4,$hget(sbmoptions,colorhoverhltext),$hget(sbmoptions,colorhltext)) "segoe ui symbol" 15 100 190 %kd

    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 220 Bomb
    if (%kb == Press the new key) {
      drawtext -rn @sbm 13816530 "segoe ui symbol" 15 100 220 Press the new key
      drawtext -rn @sbm $iif($hget(sbm,hoveroptions) == 12,$hget(sbmoptions,colorhovercancel),$hget(sbmoptions,colorcancel)) "segoe ui symbol" 15 300 220 $chr(10008)
    }
    else drawtext -rn @sbm $iif($hget(sbm,hoveroptions) == 5,$hget(sbmoptions,colorhoverhltext),$hget(sbmoptions,colorhltext)) "segoe ui symbol" 15 100 220 %kb

    drawtext -rn @sbm $iif($hget(sbm,hoveroptions) == 7,$hget(sbmoptions,colorhoverhltext),$hget(sbmoptions,colorhltext)) "segoe ui symbol" 15 400 100 $iif($hget(sbmoptions,flashonhl),$chr(9745),$chr(9744)) $chr(160) Flash on highlight
    drawtext -rn @sbm $iif($hget(sbm,hoveroptions) == 8,$hget(sbmoptions,colorhoverhltext),$hget(sbmoptions,colorhltext)) "segoe ui symbol" 15 400 130 $iif($hget(sbmoptions,autoplayconnect),$chr(9745),$chr(9744)) $chr(160) Select a player on connect

    drawtext -rnp @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 20 20 270 $chr(31) $+ Colors Configuration

    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 310 NormalText
    drawrect -frn @sbm $hget(sbmoptions,colornormal) 0 200 310 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,colornormal)), %c2 $contrast(0,$hget(sbmoptions,colornormal))
    if ($hget(sbm,hoveroptions) == 13) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 309 Click to change
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 330 HoverNormal
    drawrect -frn @sbm $hget(sbmoptions,colorhovernormal) 0 200 330 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,colorhovernormal)), %c2 $contrast(0,$hget(sbmoptions,colorhovernormal))
    if ($hget(sbm,hoveroptions) == 14) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 329 Click to change
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 350 HLText
    drawrect -frn @sbm $hget(sbmoptions,colorhltext) 0 200 350 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,colorhltext)), %c2 $contrast(0,$hget(sbmoptions,colorhltext))
    if ($hget(sbm,hoveroptions) == 15) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 349 Click to change
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 370 HoverHLText
    drawrect -frn @sbm $hget(sbmoptions,colorhoverhltext) 0 200 370 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,colorhoverhltext)), %c2 $contrast(0,$hget(sbmoptions,colorhoverhltext))
    if ($hget(sbm,hoveroptions) == 16) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 369 Click to change
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 390 Canceling $chr(10008)
    drawrect -frn @sbm $hget(sbmoptions,colorcancel) 0 200 390 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,colorcancel)), %c2 $contrast(0,$hget(sbmoptions,colorcancel))
    if ($hget(sbm,hoveroptions) == 17) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 389 Click to change
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 410 HoverCanceling $chr(10008)
    drawrect -frn @sbm $hget(sbmoptions,colorhovercancel) 0 200 410 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,colorhovercancel)), %c2 $contrast(0,$hget(sbmoptions,colorhovercancel))
    if ($hget(sbm,hoveroptions) == 18) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 409 Click to change
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 430 MainBackground
    drawrect -frn @sbm $hget(sbmoptions,colormainbg) 0 200 430 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,colormainbg)), %c2 $contrast(0,$hget(sbmoptions,colormainbg))    
    if ($hget(sbm,hoveroptions) == 19) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 429 Click to change
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 450 EditBackground
    drawrect -frn @sbm $hget(sbmoptions,coloreditbg) 0 200 450 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,coloreditbg)), %c2 $contrast(0,$hget(sbmoptions,coloreditbg))
    if ($hget(sbm,hoveroptions) == 20) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 449 Click to change
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 470 EditText
    drawrect -frn @sbm $hget(sbmoptions,coloredittext) 0 200 470 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,coloredittext)), %c2 $contrast(0,$hget(sbmoptions,coloredittext))
    if ($hget(sbm,hoveroptions) == 21) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 469 Click to change
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 490 EditSelText
    drawrect -frn @sbm $hget(sbmoptions,coloreditseltext) 0 200 490 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,coloreditseltext)), %c2 $contrast(0,$hget(sbmoptions,coloreditseltext))
    if ($hget(sbm,hoveroptions) == 22) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 489 Click to change
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 510 EditSelBg
    drawrect -frn @sbm $hget(sbmoptions,coloreditselbg) 0 200 510 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,coloreditselbg)), %c2 $contrast(0,$hget(sbmoptions,coloreditselbg))    
    if ($hget(sbm,hoveroptions) == 23) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 509 Click to change
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 530 ChatInfos
    drawrect -frn @sbm $hget(sbmoptions,colorchatinfos) 0 200 530 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,colorchatinfos)), %c2 $contrast(0,$hget(sbmoptions,colorchatinfos))
    if ($hget(sbm,hoveroptions) == 24) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 529 Click to change
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 550 Connectingmsg
    drawrect -frn @sbm $hget(sbmoptions,colorconnectingmsg) 0 200 550 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,colorconnectingmsg)), %c2 $contrast(0,$hget(sbmoptions,colorconnectingmsg))
    if ($hget(sbm,hoveroptions) == 25) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 549 Click to change
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 570 Connecterrormsg
    drawrect -frn @sbm $hget(sbmoptions,colorconnecterrormsg) 0 200 570 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,colorconnecterrormsg)), %c2 $contrast(0,$hget(sbmoptions,colorconnecterrormsg))
    if ($hget(sbm,hoveroptions) == 26) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 569 Click to change
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 590 ChatMsg
    drawrect -frn @sbm $hget(sbmoptions,colorchatmsg) 0 200 590 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,colorchatmsg)), %c2 $contrast(0,$hget(sbmoptions,colorchatmsg))
    if ($hget(sbm,hoveroptions) == 27) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 589 Click to change
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 610 Elevator $chr(9650) $chr(9660)
    drawrect -frn @sbm $hget(sbmoptions,colorelevator) 0 200 610 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,colorelevator)), %c2 $contrast(0,$hget(sbmoptions,colorelevator))
    if ($hget(sbm,hoveroptions) == 28) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 609 Click to change
    drawtext -rnp @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 630 $chr(31) $+ Play
    drawrect -frn @sbm $hget(sbmoptions,colorplay) 0 200 630 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,colorplay)), %c2 $contrast(0,$hget(sbmoptions,colorplay))
    if ($hget(sbm,hoveroptions) == 29) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 629 Click to change
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 15 20 650 HoverPlay
    drawrect -frn @sbm $hget(sbmoptions,colorhoverplay) 0 200 650 100 18
    var %c1 $contrast(16777215,$hget(sbmoptions,colorhoverplay)), %c2 $contrast(0,$hget(sbmoptions,colorhoverplay))    
    if ($hget(sbm,hoveroptions) == 30) drawtext -rn @sbm $iif(%c1 < %c2,0,16777215) "segoe ui symbol" 14 202 649 Click to change
    hinc sbm fpscount

  }
  elseif ($v1 == create) {
    drawrect -frn @sbm $hget(sbmoptions,colormainbg) 0 0 0 $window(@sbm).dw $window(@sbm).dh
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 27 140 100 Enter the server port and a nickname
    drawtext -rn @sbm $iif($hget(sbm,hovercreate) == 1 || $v1 == 4,$hget(sbmoptions,colorhoverhltext),$hget(sbmoptions,colorhltext)) "segoe ui symbol" 20 10 5 $chr(8592) Back
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 25 228 350 Server Port
    sbmdraweditbox sbmeditservport
    sbmdraweditbox sbmeditservnick
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 25 248 430 Nickname

    if ($hget(sbm,sockstate) == -1) drawtext -rpn @sbm $hget(sbmoptions,colorconnectingmsg) "segoe ui symbol" 20 40 200 Connecting to $+($chr(2),Localhost,$chr(15)) on port $+($chr(2),$hget(sbmeditservport,editbox),$chr(15)) with nickname $+($chr(2),$hget(sbmeditservnick,editbox))
    elseif ($hget(sbm,sockstate) == -2) drawtext -rn @sbm $hget(sbmoptions,colorconnecterrormsg) "segoe ui symbol" 20 40 200 Your nickname is invalid or taken, please use a different nickname
    elseif ($gettok($v1,1,32) > 0) drawtext -rn @sbm $hget(sbmoptions,colorconnecterrormsg) "segoe ui symbol" 20 40 200 An error occured while connecting: $gettok($hget(sbm,sockstate),3-,32)
    drawtext -rn @sbm $iif($hget(sbm,hovercreate) == 2 || $v1 == 4,$hget(sbmoptions,colorhoverhltext),$iif($v1 == 3,$hget(sbmoptions,colorhltext),13816530)) "segoe ui symbol" 28 300 500 Start
  }
  elseif ($hget(sbm,view) == game) {
    ; var %ticks $ticks
    drawrect -frn @sbm 3168272 0 0 0 $window(@sbm).dw $window(@sbm).dh
    drawcopy @sbmbuf 300 0 240 208 @sbmbuf 0 30
    tokenize 32 $hget(sbm,items)
    sbmdrawitems $*
    ; drawpic -tn @sbmbuf 16777215 20 6 240 32 16 16 $qt($scriptdirbbt.png)
    ; drawpic -ctn @sbmbuf 16777215 80 6 240 112 16 16 $qt($scriptdirbbt.png)
    ; drawpic -tnc @sbmbuf 16777215 140 6 240 192 16 16 $qt($scriptdirbbt.png)
    ; drawpic -ntc @sbmbuf 16777215 200 6 240 272 16 16 $qt($scriptdirbbt.png)
    var %mw $window(@sbm).dw, %mh $window(@sbm).dh, %ratio 238 / 240
    var %w $gettok($sorttok(%mw $calc(%mh / %ratio), 32, n), 1, 32),0), %h %ratio * %w, %x $round($calc((%mw - %w) / 2),0), %y $round($calc((%mh - %h) / 2),0)
    drawcopy -n @sbmbuf 0 0 240 238 @sbm %x %y %w %h
    hinc sbm fpscount
    if ($calc($ticks - $hget(sbm,ticksbonus)) > 50) {
      if ($hget(sbm,bonustile)) hadd sbm bonustile 0
      else hadd sbm bonustile 16
      hadd sbm ticksbonus $ticks
    }

    ;echo -s $hget(sbm,fps)
  }
  elseif ($v1 == connect) {
    drawrect -frn @sbm $hget(sbmoptions,colormainbg) 0 0 0 $window(@sbm).dw $window(@sbm).dh
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 27 100 100 Enter the server informations and a nickname
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 25 180 270 Server Address
    sbmdraweditbox sbmeditip
    sbmdraweditbox sbmeditport
    sbmdraweditbox sbmeditnick
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 25 228 350 Server Port
    drawtext -rn @sbm $hget(sbmoptions,colornormal) "segoe ui symbol" 25 248 430 Nickname

    drawtext -rn @sbm $iif($hget(sbm,hoverconnect) == 2 || $v1 == 4,$hget(sbmoptions,colorhoverhltext),$iif($v1 == 3,$hget(sbmoptions,colorhltext),13816530)) "segoe ui symbol" 28 300 500 Connect
    drawtext -rn @sbm $iif($hget(sbm,hoverconnect) == 1 || $v1 == 4,$hget(sbmoptions,colorhoverhltext),$hget(sbmoptions,colorhltext)) "segoe ui symbol" 20 10 5 $chr(8592) Back
    if ($hget(sbm,sockstate) == -1) drawtext -rpn @sbm $hget(sbmoptions,colorconnectingmsg) "segoe ui symbol" 20 40 200 Connecting to $+($chr(2),$hget(sbmeditip,editbox),$chr(15)) on port $+($chr(2),$hget(sbmeditport,editbox),$chr(15)) with nickname $+($chr(2),$hget(sbmeditnick,editbox))
    elseif ($hget(sbm,sockstate) == -2) drawtext -rpn @sbm $hget(sbmoptions,colorconnecterrormsg) "segoe ui symbol" 20 40 200 Your nickname is invalid or taken, please use a different nickname
    elseif ($gettok($hget(sbm,sockstate),1,32) == -3) {
      tokenize 32 $hget(sbm,sockstate)
      drawtext -rpn @sbm $hget(sbmoptions,colorconnecterrormsg) "segoe ui symbol" 20 300 200 The remote server closed your connection $iif($2 > 0,$3-)
    }
    elseif ($gettok($hget(sbm,sockstate),1,32) > 0) drawtext -rn @sbm $hget(sbmoptions,colorconnecterrormsg) "segoe ui symbol" 20 40 200 An error occured while connecting: $gettok($hget(sbm,sockstate),3-,32)
  }
  elseif ($v1 == connected) {
    drawrect -frn @sbm $hget(sbmoptions,colormainbg) 0 0 0 $window(@sbm).dw $window(@sbm).dh
    drawtext -rn @sbm 8355711 "segoe ui symbol" 25 220 100 Waiting for the game to start..  

    hadd sbmeditchat x 5
    hadd sbmeditchat y $calc($window(@sbm).dh - 30)
    hadd sbmeditchat w $calc($window(@sbm).dw -40)
    drawrect -rn @sbm 0 2 0 400 $window(@sbm).dw $calc($window(@sbm).dh - 400)

    hadd sbmeditchat fc $hget(sbmeditchat,x) $hget(sbmeditchat,y) $hget(sbmeditchat,w) $hget(sbmeditchat,h) $hget(sbmeditchat,i) $hget(sbmeditchat,e)
    sbmdraweditbox sbmeditchat

    var %fs 11
    var %b $hget(sbmchat,0).item,%x 2,%y $window(@sbm).dh - 57,%s $hget(sbm,scroll),%i 0,%n 0
    while (%b) && (%y > $gettok($hget(sbm,chatarea),2,32)) {
      if ($gettok($hget(sbmchat,$calc(%s + %i)),2,32) == *) {
        drawtext -rnp @sbm $hget(sbmoptions,colorchatinfos) "segoe ui symbol" 11 %x %y $+($chr(2),$hget(sbmchat,$calc(%s + %i)))
      }
      else {
        drawtext -rnp @sbm 0 "segoe ui symbol" 11 %x %y $+($chr(2),$gettok($hget(sbmchat,$calc(%s + %i)),1,32))
        drawtext -rnp @sbm 0 "segoe ui symbol" 11 $calc(160 - $width($+($chr(2),$gettok($hget(sbmchat,$calc(%s + %i)),2,32)),segoe ui symbol,13)) %y $+($chr(2),$gettok($hget(sbmchat,$calc(%s + %i)),2,32))
        drawtext -rnp @sbm 0 "segoe ui symbol" 11 170 %y $+($chr(2),$gettok($hget(sbmchat,$calc(%s + %i)),3-,32))
        inc %n 1
      }
      dec %b
      dec %i
      dec %y 18
    }
    if ($hget(sbm,hscroll)) drawrect -frn @sbm $color(14) 1 $hget(sbm,xscroll) $hget(sbm,yscroll) $hget(sbm,wscroll) $hget(sbm,hscroll)
    drawrect -rn @sbm 255 1 0 402 700 160
    drawrect -rn @sbm 127 1 0 402 700 $calc(18*9)

    ; echo -s %n + $height(1,segoe ui symbol,11)
    if ($window(@sbm).dh <= 500) window -f @sbm -1 -1 $window(@sbm).dw 500


    drawtext -rn @sbm $hget(sbmoptions,colorelevator) "segoe ui symbol" 14 $calc($window(@sbm).dw - 15) $gettok($hget(sbm,chatarea),2,32) $chr(9650)
    drawtext -rn @sbm $hget(sbmoptions,colorelevator) "segoe ui symbol" 14 $calc($window(@sbm).dw - 15) $calc($window(@sbm).dh - 47) $chr(9660)
    drawpic -stn @sbm 16777215 80 200 32 32 640 108 16 16 $qt($scriptdirsbm.png)
    drawpic -tsn @sbm 16777215 280 200 32 32 656 108 16 16 $qt($scriptdirsbm.png)
    drawpic -tns @sbm 16777215 480 200 32 32 672 108 16 16 $qt($scriptdirsbm.png)
    drawpic -nts @sbm 16777215 680 200 32 32 688 108 16 16 $qt($scriptdirsbm.png)

    var %p $findtok($iif($hget(sbm,player1) != $null,$v1,0) $iif($hget(sbm,player2) != $null,$v1,0) $iif($hget(sbm,player3) != $null,$v1,0) $iif($hget(sbm,player4) != $null,$v1,0),$hget(sbm,nick),32)
    if ($hget(sbm,player1) != $null) {
      drawtext -rn @sbm 0 "segoe ui symbol" 14 75 235 $v1
      if ($hget(sbm,nick) == $v1) drawtext -rn @sbm $iif($hget(sbm,hoverconnected) == 6,127,255) "segoe ui symbol" 14 $calc(75 + $width($hget(sbm,nick),segoe ui symbol,14) + 7) 235 $chr(10008)
    }
    else drawtext -rnp @sbm $iif(%p != $null && %p != 1,8355711,$iif($hget(sbm,hoverconnected) == 1,$hget(sbmoptions,colorhoverplay),$hget(sbmoptions,colorplay))) "segoe ui symbol" 14 81 235 $+($chr(31),Play)
    if ($hget(sbm,player2) != $null) {
      drawtext -rn @sbm 0 "segoe ui symbol" 14 275 235 $v1
      if ($hget(sbm,nick) == $v1) drawtext -rn @sbm $iif($hget(sbm,hoverconnected) == 6,127,255) "segoe ui symbol" 14 $calc(275 + $width($hget(sbm,nick),segoe ui symbol,14) + 7) 235 $chr(10008)
    }
    else drawtext -rnp @sbm $iif(%p != $null && %p != 2,8355711,$iif($hget(sbm,hoverconnected) == 2,$hget(sbmoptions,colorhoverplay),$hget(sbmoptions,colorplay))) "segoe ui symbol" 14 281 235 $+($chr(31),Play)
    if ($hget(sbm,player3) != $null) {
      drawtext -rn @sbm 0 "segoe ui symbol" 14 475 235 $v1
      if ($hget(sbm,nick) == $v1) drawtext -rn @sbm $iif($hget(sbm,hoverconnected) == 6,127,255) "segoe ui symbol" 14 $calc(475 + $width($hget(sbm,nick),segoe ui symbol,14) + 7) 235 $chr(10008)
    }
    else drawtext -rnp @sbm $iif(%p != $null && %p != 3,8355711,$iif($hget(sbm,hoverconnected) == 3,$hget(sbmoptions,colorhoverplay),$hget(sbmoptions,colorplay))) "segoe ui symbol" 14 481 235 $+($chr(31),Play)
    if ($hget(sbm,player4) != $null) {
      drawtext -rn @sbm 0 "segoe ui symbol" 14 675 235 $v1
      if ($hget(sbm,nick) == $v1) drawtext -rn @sbm $iif($hget(sbm,hoverconnected) == 6,127,255) "segoe ui symbol" 14 $calc(675 + $width($hget(sbm,nick),segoe ui symbol,14) + 7) 235 $chr(10008)
    }
    else drawtext -rnp @sbm $iif(%p != $null && %p != 4,8355711,$iif($hget(sbm,hoverconnected) == 4,$hget(sbmoptions,colorhoverplay),$hget(sbmoptions,colorplay))) "segoe ui symbol" 14 681 235 $+($chr(31),Play)
    drawtext -rn @sbm 0 "Segoe UI Symbol" 25 $calc($window(@sbm).dw - 30) $calc($window(@sbm).dh - 37) $chr(55357) $+ $chr(56833)
    drawtext -rn @sbm $iif($hget(sbm,hoverconnected) == 7,$hget(sbmoptions,colorhoverhltext),$hget(sbmoptions,colorhltext)) "segoe ui symbol" 20 10 5 $chr(8592) Leave
    if ($hget(sbm,owner)) {
      hinc sbm startflash
      if ($hget(sbm,startflash) == 6) hadd sbm startflash 1
      drawtext -rn @sbm $gettok(64 92 127 168 255,$hget(sbm,startflash),32) "segoe ui symbol" 35 350 20 Start
    }
  }

  if (sbmedit* iswm $hget(sbm,focus)) {
    if ($calc($ticks - $hget(sbm,cursorticks)) > 500) {
      if ($hget(sbm,drawcursor)) hdel sbm drawcursor
      else hadd sbm drawcursor 1
      hadd sbm cursorticks $ticks
    }
    if ($hget(sbm,drawcursor)) {
      var %h $hget(sbm,focus)
      var %x $iif($hget(%h,cursor) > 0,$width($left($hget(%h,editbox),$v1),$hget(%h,font),$hget(%h,fontsize)))
      drawline -rn @sbm 0 1 $calc($hget(%h,x) + 10 + %x) $calc($hget(%h,y) +6) $calc($hget(%h,x) + 10 + %x) $calc($hget(%h,y) +21)
    }
  }
  if ($calc($ticks - $hget(sbm,fpsticks)) >= 1000) {
    hadd sbm fps $hget(sbm,fpscount)
    hadd sbm fpscount 0
    hadd sbm fpsticks $ticks
  }
  titlebar @sbm fps $hget(sbm,fps) %mw %mh -- $mouse.x $mouse.y
  drawdot @sbm
  .timersbm -ho 1 0 if (!$isalias(sbmlobbyloop)) .timersbm -cho 1 0 $!timer(sbm).com $(|) else sbmlobbyloop
}
alias testtimer {
  inc %testtimer
  if ($calc($ticks - %testtimerticks) >= 1000) {
    echo -s total inc per second: %testtimer
    unset %testtimer
    %testtimerticks = $ticks
  }
  .timertest -cho 1 0 testtimer
}
alias sbmdrawitems {
  var %id $1
  tokenize 32 $hget(sbm,item $+ %id)
  if (%id isnum 1-4) {
    if ($3) {
      if ($hget(sbm,bticks $+ %id) == $null) hadd sbm bticks $+ %id $ticks
      elseif ($calc($ticks - $hget(sbm,bticks $+ %id)) >= 144) {
        hinc sbm spritex $+ %id
        hadd sbm bticks $+ %id $ticks
      }
    }
    if ($hget(sbm,spritex $+ %id) > 4) || (!$3) hadd sbm spritex $+ %id 1
    elseif ($3 == 37) hadd sbm spritedir $+ %id $calc(16*9)
    elseif ($3 == 39) hadd sbm spritedir $+ %id $calc(16*3)
    elseif ($3 == 40) hadd sbm spritedir $+ %id $calc(16*6)
    elseif ($3 == 38) hadd sbm spritedir $+ %id 0
    drawcopy -t @sbmtiles 16777215 $calc($gettok(0 1 0 2,$hget(sbm,spritex $+ %id),32) * 16 + $hget(sbm,spritedir $+ %id)) $calc((%id - 1) * 27) 16 27 @sbmbuf $calc($1 -0) $calc($2 - 13 + 30) 
    ; drawpic -ct @sbmbuf 16777215 $calc($1 -0) $calc($2 - 13 + 30) $calc($gettok(0 1 0 2,$hget(sbm,spritex $+ %id),32) * 16 + $hget(sbm,spritedir $+ %id)) $calc((%id - 1) * 27) 16 27 $qt($scriptdirbsprites.png)
  }
  elseif (4* iswm %id) {
    if ($calc($ticks - $5) >= 235) {
      if ($2 == 1) {

        var %1 $hget(sbmmap,$+($calc($3 -1),.,$4)),%2 $hget(sbmmap,$+($calc($3 + 1),.,$4)),%3 $hget(sbmmap,$+($3,.,$calc($4 - 1))),%4 $hget(sbmmap,$+($3,.,$calc($4 + 1)))
        if (%1) && (%2) {
          if (%3) || (%4) var %s 4
          else var %s 2
        }
        elseif (%3) && (%4) {
          if (%1) || (%2) var %s 4
          else var %s 3
        }
        elseif ((%1) && (%3)) || ((%2) && (%4)) var %s 4
        else var %s 4
        var %list $calc($3 * 16) $calc($4 * 16) %s 16 16,%list1
        var %a $3 - 1,%y $calc($4 * 16),%c $1 - 1
        while (%c) && ($hget(sbmmap,$+(%a,.,$4)) != 1) {
          if ($v1 == 3) {
            var %no 1
            %list1 = $addtok(%list1,$calc(%a * 16) %y,46)
            break 
          }
          /*          elseif ($v1 > 3) {
            var %no 1
            if ($v1 == 99) noop $hfind(sbm,^4\d+ \d+ %a $4 \d+$,0,r,hadd sbms $1 $puttok($puttok($hget(sbms,$1),1,2,32),$calc($ticks -40),5,32)).data
            else {
              hdel sbmmap $+(%a,.,$4)
              var %w $findtok($hget(sbmserv,bonuses),$wildtok($hget(sbmserv,bonuses),$calc(%a * 16) $calc($4 * 16) &,1,46),46)
              hadd sbmserv bonuses $deltok($hget(sbmserv,bonuses),%w,46)
              hadd sbmserv delbonus $addtok($hget(sbmserv,delbonus),0 %a $4 $ticks,46)
            }
            break      
          }
          */
          %list = $addtok(%list,$calc(%a * 16) %y 3 16 16,46)
          dec %a
          dec %c
        }
        if (!%no) %list = $regsubex(%list,/3(?= -?16 -?16$)/,1)
        var %a $3 + 1,%y $calc($4 * 16),%c $1 - 1,%no
        while (%c) && ($hget(sbmmap,$+(%a,.,$4)) != 1) {
          if ($v1 == 3) {
            %list1 = $addtok(%list1,$calc(%a * 16) %y,46)
            var %no 1
            break 
          }
          /*          elseif ($v1 > 3) {
            var %no 1
            if ($v1 == 99) noop $hfind(sbmserv,^\d+ \d+ %a $4 \d+$,0,r,hadd sbmserv $1 $puttok($puttok($hget(sbmserv,$1),1,2,32),$calc($ticks -40),5,32)).data
            else {
              hdel sbmservmap $+(%a,.,$4)
              var %w $findtok($hget(sbmserv,bonuses),$wildtok($hget(sbmserv,bonuses),$calc(%a * 16) $calc($4 * 16) &,1,46),46)
              hadd sbmserv bonuses $deltok($hget(sbmserv,bonuses),%w,46)
              hadd sbmserv delbonus $addtok($hget(sbmserv,delbonus),0 %a $4 $ticks,46)
            }
            break      
          }
          */
          %list = $addtok(%list,$calc(%a * 16 + 16 - 1) %y 3 -16 16,46)
          inc %a
          dec %c
        }
        if (!%no) %list = $regsubex(%list,/3(?= -?16 -?16$)/,1)
        var %a $4 - 1,%x $calc($3 * 16),%c $1 - 1,%no
        while (%c) && ($hget(sbmmap,$+($3,.,%a)) != 1) {
          if ($v1 == 3) {
            var %no 1
            %list1 = $addtok(%list1,%x $calc(%a * 16),46) 
            break
          }
          /*          elseif ($v1 > 3) {
            var %no 1
            if ($v1 == 99) noop $hfind(sbmserv,^\d+ \d+ $3 %a \d+$,0,r,hadd sbmserv $1 $puttok($puttok($hget(sbmserv,$1),1,2,32),$calc($ticks -40),5,32)).data
            else {
              hdel sbmservmap $+($3,.,%a)
              var %w $findtok($hget(sbmserv,bonuses),$wildtok($hget(sbmserv,bonuses),$calc($3 * 16) $calc(%a * 16) &,1,46),46)
              hadd sbmserv bonuses $deltok($hget(sbmserv,bonuses),%w,46)
              hadd sbmserv delbonus $addtok($hget(sbmserv,delbonus),0 $3 %a $ticks,46)
            }
            break      
          }
          */
          var %list = $addtok(%list,%x $calc(%a * 16) 2 16 16,46) 
          dec %a
          dec %c
        }
        if (!%no) %list = $regsubex(%list,/2(?= -?16 -?16$)/,0) 
        var %a $4 + 1,%x $calc($3 * 16),%c $1 - 1,%no
        while (%c) && ($hget(sbmmap,$+($3,.,%a)) != 1) {
          if ($v1 == 3) {
            %list1 = $addtok(%list1,%x $calc(%a * 16),46)
            var %no 1
            break
          }
          /*          elseif ($v1 > 3) {
            var %no 1
            if ($v1 == 99) noop $hfind(sbmserv,^\d+ \d+ $3 %a \d+$,0,r,hadd sbmserv $1 $puttok($puttok($hget(sbmserv,$1),1,2,32),$calc($ticks -40),5,32)).data
            else {
              hdel sbmservmap $+($3,.,%a)
              var %w $findtok($hget(sbmserv,bonuses),$wildtok($hget(sbmserv,bonuses),$calc($3 * 16) $calc(%a * 16) &,1,46),46)
              hadd sbmserv bonuses $deltok($hget(sbmserv,bonuses),%w,46)
              hadd sbmserv delbonus $addtok($hget(sbmserv,delbonus),0 $3 %a $ticks,46)
            }
            break      
          }
          */
          %list = $addtok(%list,%x $calc(%a * 16 + 16 - 1) 2 16 -16,46)
          inc %a
          dec %c
        }
        if (!%no) %list = $regsubex(%list,/2(?= -?16 -?16$)/,0)
        hdel sbm item $+ %id
        hadd sbm items 5 $+ %id 6 $+ %id $remtok($hget(sbm,items),%id,32)
        hdel sbmmap $+($3,.,$4)
        ;  hadd sbm wes $addtok($hget(sbmserv,wes),5 $+ %id,32)
        hadd sbm item $+ 5 $+ %id $6 %list
        hadd sbm firesprite $+ 5 $+ %id 0
        hadd sbm wesprite $+ 6 $+ %id 0
        hadd sbm item $+ 6 $+ %id $6 %list1
        hadd sbm weticks $+ 6 $+ %id $ticks
        hadd sbm fireticks $+ 5 $+ %id $ticks
        hadd sbm firetick $+ 5 $+ %id $ticks
        return
      }
      else {
        hadd sbm item $+ %id $1 $calc($2 - 1) $3-4 $ticks $6
      }
    }
    if ($2 isin 951) var %x $calc(16*6)
    elseif ($2 isin 8642) var %x $calc(16*7)
    else var %x $calc(16*8)
    drawpic -ct @sbmbuf 3168272 $calc($3 * 16) $calc($4 * 16 + 30) %x $calc(32+ ($6 - 1) * 16+ ($6 - 1) * 4 * 16) 16 16 $qt($scriptdirbbt.png)
  }
  elseif (5* iswm %id) {
    if ($calc($ticks - $hget(sbm,fireticks $+ %id)) >= 600) {
      echo -s cexplode $ticks
      hdel sbm item $+ %id
      hdel sbm fireticks $+ %id
      hdel sbm firetick $+ %id
      hdel sbm firesprite $+ %id
      hadd sbm items $remtok($hget(sbm,items),%id,32)
      return
    }
    else {
      if ($calc($ticks - $hget(sbm,firetick $+ %id)) >= 120) {
        hadd sbm firetick $+ %id $ticks
        hinc sbm firesprite $+ %id
      }
      var %c $1
      tokenize 46 $2-
      sbmdrawfire %id %c $*
    }
  }
  elseif (6* iswm %id) {
    ; echo -s $1-
    if ($calc($ticks - $hget(sbm,weticks $+ %id)) > 150) {
      if ($hget(sbm,wesprite $+ %id) == 5) {
        hdel sbm item $+ %id
        hdel sbm weticks $+ %id
        hdel sbm wesprite $+ %id
        hadd sbm items $remtok($hget(sbm,items),%id,32)
        tokenize 46 $2-
        sbmdelfrommap $*
        sbmflushbonuses %id
        return
      }
      hadd sbm weticks $+ %id $ticks
      hinc sbm wesprite $+ %id
    }
    var %c $1
    tokenize 46 $2-
    sbmdrawwe %id %c $*
  }
  elseif (7* iswm %id) {
    drawpic -c @sbmbuf $1 $calc($2 + 30) $calc(($3 - 4) * 16) $hget(sbm,bonustile) 16 16 $qt($scriptdirbbt.png)
  }
}
alias sbmflushbonuses {
  var %id $1
  set -u %sbmcounter 1
  if ($hget(sbm,flushbonuses $+ %id)) {
    tokenize 92 $v1
    sbmflushbonus %id $*
    hdel sbm flushbonuses $+ %id
  }
}
alias sbmflushbonus {
  var %id $1,%i $3
  hadd sbmmap $2-3
  hadd sbm items 7 $+ %sbmcounter $+ %id $hget(sbm,items)
  tokenize 46 $2
  hadd sbm item $+ 7 $+ %sbmcounter $+ %id $calc($1 * 16) $calc($2 * 16) %i
  inc -u %sbmcounter
}
alias sbmdelfrommap {
  hdel sbmmap $+($calc($1 // 16),.,$calc($2 // 16))
  if ($hget(sbmmap,$+($calc($1 // 16),.,$calc($2 // 16 - 1))) == 1) {
    drawpic -c @sbmbuf $calc($1 + 300) $2 320 0 16 16 $qt($scriptdirbbt.png)
    drawpic -c @sbmbuf $1 $calc($2 + 30) 320 0 16 16 $qt($scriptdirbbt.png)
  }
  else {
    drawrect -rf @sbmbuf 3168272 0 $calc($1 + 300) $2 16 16
    drawrect -rf @sbmbuf 3168272 0 $1 $calc($2 + 30) 16 16
  }
}
alias sbmdrawwe drawpic -c @sbmbuf $3 $calc($4 + 30) $calc($hget(sbm,wesprite $+ $1) * 16 + 144) $calc(32+ ($2 - 1) * 16+ ($2 - 1) * 4 * 16) 16 16 $qt($scriptdirbbt.png)
alias sbmdrawfire {
  drawpic -cst @sbmbuf 3168272 $3 $calc($4 + 30) $6 $7 $calc(16 * $5) $calc(32 + $hget(sbm,firesprite $+ $1) * 16 + ($2 - 1) * 5 * 16) 16 16 $qt($scriptdirbbt.png)
}
alias sbmsclickedit {
  if ($inroundrect($mouse.x,$mouse.y,$hget($1,x),$hget($1,y),$hget($1,w),$hget($1,h),$hget($1,i),$hget($1,e))) {
    hadd sbm focus $1
    hadd sbm drawcursor 1
    hdel $1 sel
    if ($hget($1,editbox) != $null) {
      if ($mouse.x <= $calc($hget($1,x) + 10)) hadd $1 cursor 0
      elseif ($v1 > $calc($hget($1,x) + 10 + $width($hget($1,editbox),$hget($1,font),$hget($1,fontsize)))) hadd $1 cursor $len($hget($1,editbox))
      else {
        var %a 1,%t $hget($1,editbox)
        while (%a <= $len(%t)) && ($calc($hget($1,x) + 10 + $width($left($hget($1,editbox),%a),$hget($1,font),$hget($1,fontsize))) <= $mouse.x) {
          inc %a
        }
        hadd $1 cursor $calc(%a - 1)
      }
    }
    return 1
  }
}

alias sbmsclick {
  if ($hget(sbm,view) == init) {
    if ($inrect($mouse.x,$mouse.y,280,200,$width(Connect to a game,segoe ui symbol,25),$height(Connect to a game,segoe ui symbol,25))) {
      sbmchangeview connect
    }
    elseif ($inrect($mouse.x,$mouse.y,280,300,$width(Create a game,segoe ui symbol,25),$height(Create a game,segoe ui symbol,25))) {
      sbmchangeview create
    }
    elseif ($inrect($mouse.x,$mouse.y,280,400,$width(Options,segoe ui symbol,25),$height(Options,segoe ui symbol,25))) {
      sbmchangeview options
    }
  }
  elseif ($v1 == options) {
    if ($inrect($mouse.x,$mouse.y,10,5,$width($chr(8592) Back,segoe ui symbol,20),$height($chr(8592) Back,segoe ui symbol,20))) {
      sbmchangeview init
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,400,100,$width($chr(9744) $chr(160) Flash on highlight,segoe ui symbol,15),$height($chr(9744) $chr(160) Flash on highlight,segoe ui symbol,15))) {
      if ($hget(sbmoptions,flashonhl)) hadd sbmoptions flashonhl 0
      else hadd sbmoptions flashonhl 1
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,400,130,$width($chr(9744) $chr(160) Select a player on connect,segoe ui symbol,15),$height($chr(9744) $chr(160) Select a player on connect,segoe ui symbol,15))) {
      if ($hget(sbmoptions,autoplayconnect)) hadd sbmoptions autoplayconnect 0
      else hadd sbmoptions autoplayconnect 1
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,310,100,18)) {
      pickcolor colornormal
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,330,100,18)) {
      pickcolor colorhovernormal
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,350,100,18)) {
      pickcolor colorhltext
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,370,100,18)) {
      pickcolor colorhoverhltext
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,390,100,18)) {
      pickcolor colorcancel
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,410,100,18)) {
      pickcolor colorhovercancel
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,430,100,18)) {
      pickcolor colormainbg
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,450,100,18)) {
      pickcolor coloreditbg
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,470,100,18)) {
      pickcolor coloredittext
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,490,100,18)) {
      pickcolor coloreditseltext
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,510,100,18)) {
      pickcolor coloreditselbg
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,530,100,18)) {
      pickcolor colorchatinfos
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,550,100,18)) {
      pickcolor colorconnectingmsg
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,570,100,18)) {
      pickcolor colorconnecterrormsg
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,590,100,18)) {
      pickcolor colorchatmsg
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,610,100,18)) {
      pickcolor colorevevator
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,630,100,18)) {
      pickcolor colorplay
      return
    }
    elseif ($inrect($mouse.x,$mouse.y,200,650,100,18)) {
      pickcolor colorhoverplay
      return
    }
    var %kl $keynumtodesc($hget(sbmoptions,keyleft)),%kr $keynumtodesc($hget(sbmoptions,keyright)),%ku $keynumtodesc($hget(sbmoptions,keyup)),%kd $keynumtodesc($hget(sbmoptions,keydown)),%kb $keynumtodesc($hget(sbmoptions,keybomb))
    if (%kl != Press the new key) {

      if ($inrect($mouse.x,$mouse.y,100,100,$width(%kl,segoe ui symbol,15),$height(%kl,segoe ui symbol,15))) {
        if (!$hget(sbm,keytemp)) {
          hadd sbm keytemp $hget(sbmoptions,keyleft)
          hadd sbmoptions keyleft - $+ $hget(sbmoptions,keyleft)
        }
      }
    }
    else {
      if ($inrect($mouse.x,$mouse.y,300,100,$width($chr(10008),segoe ui symbol,15),$height($chr(10008),segoe ui symbol,15))) {
        hadd sbmoptions keyleft $hget(sbm,keytemp)
        hdel sbm keytemp
      }
    }
    if (%kr != Press the new key) {


      if ($inrect($mouse.x,$mouse.y,100,130,$width(%kr,segoe ui symbol,15),$height(%kr,segoe ui symbol,15))) {
        if (!$hget(sbm,keytemp)) {
          hadd sbm keytemp $hget(sbmoptions,keyright)
          hadd sbmoptions keyright - $+ $hget(sbmoptions,keyright)
        }
      }
    }
    else {
      if ($inrect($mouse.x,$mouse.y,300,130,$width($chr(10008),segoe ui symbol,15),$height($chr(10008),segoe ui symbol,15))) {
        hadd sbmoptions keyright $hget(sbm,keytemp)
        hdel sbm keytemp
      }
    }
    if (%ku != Press the new key) {


      if ($inrect($mouse.x,$mouse.y,100,160,$width(%ku,segoe ui symbol,15),$height(%ku,segoe ui symbol,15))) {
        if (!$hget(sbm,keytemp)) {
          hadd sbm keytemp $hget(sbmoptions,keyup)
          hadd sbmoptions keyup - $+ $hget(sbmoptions,keyup)
        }
      }
    }
    else {
      if ($inrect($mouse.x,$mouse.y,300,160,$width($chr(10008),segoe ui symbol,15),$height($chr(10008),segoe ui symbol,15))) {
        hadd sbmoptions keyup $hget(sbm,keytemp)
        hdel sbm keytemp
      }
    }
    if (%kd != Press the new key) {


      if ($inrect($mouse.x,$mouse.y,100,190,$width(%kd,segoe ui symbol,15),$height(%kd,segoe ui symbol,15))) {
        if (!$hget(sbm,keytemp)) {
          hadd sbm keytemp $hget(sbmoptions,keydown)
          hadd sbmoptions keydown - $+ $hget(sbmoptions,keydown)
        }
      }
    }
    else {
      if ($inrect($mouse.x,$mouse.y,300,190,$width($chr(10008),segoe ui symbol,15),$height($chr(10008),segoe ui symbol,15))) {
        hadd sbmoptions keydown $hget(sbm,keytemp)
        hdel sbm keytemp
      }
    }
    if (%kb != Press the new key) {

      if ($inrect($mouse.x,$mouse.y,100,220,$width(%kb,segoe ui symbol,15),$height(%kb,segoe ui symbol,15))) {
        if (!$hget(sbm,keytemp)) {

          hadd sbm keytemp $hget(sbmoptions,keybomb)
          hadd sbmoptions keybomb - $+ $hget(sbmoptions,keybomb)
        }
      }
    }
    else {
      if ($inrect($mouse.x,$mouse.y,300,220,$width($chr(10008),segoe ui symbol,15),$height($chr(10008),segoe ui symbol,15))) {
        hadd sbmoptions keybomb $hget(sbm,keytemp)
        hdel sbm keytemp
      }
    }
  }
  elseif ($v1 == connected) {
    if (!$sbmsclickedit(sbmeditchat)) {
      hdel sbm sel
      hdel sbm drawcursor
      var %p $findtok($iif($hget(sbm,player1) != $null,$v1,0) $iif($hget(sbm,player2) != $null,$v1,0) $iif($hget(sbm,player3) != $null,$v1,0) $iif($hget(sbm,player4) != $null,$v1,0),$hget(sbm,nick),32)
      if ($inrect($mouse.x,$mouse.y,350,20,$width(Start,segoe ui symbol,35),$height(Start,segoe ui symbol,35))) {
        if ($hget(sbm,owner)) {
          sockwrite -n sbmclient ready
        }
      }
      elseif ($inrect($mouse.x,$mouse.y,$calc($window(@sbm).dw - 15),$gettok($hget(sbm,chatarea),2,32),$width($chr(9650),segoe ui symbol,14),$height($chr(9650),segoe ui symbol,14))) {
        hdec sbm scroll
        if ($calc($hget(sbm,scroll) - 8) < 0) {
          hinc sbm scroll
        }
      }
      elseif ($inrect($mouse.x,$mouse.y,$calc($window(@sbm).dw - 15),$calc($window(@sbm).dh - 47),$width($chr(9660),segoe ui symbol,14),$height($chr(9660),segoe ui symbol,14))) {
        hinc sbm scroll
        if ($hget(sbm,scroll) > $hget(sbmchat,0).item) {
          hdec sbm scroll
        }
      }
      elseif ($inrect($mouse.x,$mouse.y,81,235,$width($+($chr(31),Play),segoe ui symbol,14),$height($+($chr(31),Play),segoe ui symbol,14))) {
        if (%p == $null) && ($hget(sbm,player1) == $null) sockwrite -n sbmclient slpl 1 1
      }
      elseif ($inrect($mouse.x,$mouse.y,281,235,$width($+($chr(31),Play),segoe ui symbol,14),$height($+($chr(31),Play),segoe ui symbol,14))) {
        if (%p == $null) && ($hget(sbm,player2) == $null) sockwrite -n sbmclient slpl 2 1
      }  
      elseif ($inrect($mouse.x,$mouse.y,481,235,$width($+($chr(31),Play),segoe ui symbol,14),$height($+($chr(31),Play),segoe ui symbol,14))) {
        if (%p == $null) && ($hget(sbm,player3) == $null) sockwrite -n sbmclient slpl 3 1
      }
      elseif ($inrect($mouse.x,$mouse.y,681,235,$width($+($chr(31),Play),segoe ui symbol,14),$height($+($chr(31),Play),segoe ui symbol,14))) {
        if (%p == $null) && ($hget(sbm,player4) == $null) sockwrite -n sbmclient slpl 4 1
      }
      elseif ($inrect($mouse.x,$mouse.y,10,5,$width($chr(8592) Leave,segoe ui symbol,20),$height($chr(8592) Leave,segoe ui symbol,20))) {
        sbmchangeview init
      }
      elseif ($inrect($mouse.x,$mouse.y,$calc($window(@sbm).dw - 14),$hget(sbm,yscroll),$hget(sbm,wscroll),$hget(sbm,hscroll))) {
        hadd sbm scrolling $mouse.y
      }
      if (%p) {
        if ($inrect($mouse.x,$mouse.y,$calc(75 + (%p - 1) * 200 + 7 + $width($hget(sbm,nick),segoe ui symbol,14)),235,$width($chr(10008),segoe ui symbol,14),$height($chr(10008),segoe ui symbol,14))) {
          sockwrite -n sbmclient slpl %p
        }
      }
    }
  }
  elseif ($v1 == create) {
    if ($inrect($mouse.x,$mouse.y,10,5,$width($chr(8592) Back,segoe ui symbol,20),$height($chr(8592) Back,segoe ui symbol,20))) {
      sbmchangeview init
    }
    elseif ($inrect($mouse.x,$mouse.y,300,500,$width(Start,segoe ui symbol,28),$height(Start,segoe ui symbol,28))) {
      if ($hget(sbmserv)) || (!$regex($hget(sbmeditservport,editbox),$sbmreg_validport)) || (!$hget(sbmeditservnick,editbox) != $null) return
      sbmserv $hget(sbmeditservport,editbox) restart
      sbmclientconnect 127.0.0.1 $hget(sbmeditservport,editbox) $hget(sbmeditservnick,editbox)
    }
    tokenize 32 sbmeditservport sbmeditservnick
    sbmsclickedit $*
  }
  elseif ($v1 == connect) {
    tokenize 32 sbmeditip sbmeditport sbmeditnick
    sbmsclickedit $*
    if ($inrect($mouse.x,$mouse.y,10,5,$width($chr(8592) Back,segoe ui symbol,20),$height($chr(8592) Back,segoe ui symbol,20))) {
      sbmchangeview init
    }
    elseif ($inrect($mouse.x,$mouse.y,300,500,$width(Connect,segoe ui symbol,28),$height(Connect,segoe ui symbol,28))) {
      if ($iptype($hget(sbmeditip,editbox)) != $null) && ($regex($hget(sbmeditport,editbox),$sbmreg_validport)) && ($hget(sbmeditnick,editbox) != $null) {
        sbmclientconnect $hget(sbmeditip,editbox) $hget(sbmeditport,editbox) $hget(sbmeditnick,editbox)
      }
    }
  }
}

menu @sbm {
  sclick: sbmsclick
  mouse : {
    titlebar @Sbm $mouse.x
    if (sbmedit* iswm $hget(sbm,focus)) {
      if ($mouse.key & 1) {
        var %c $click(@sbm,$click(@sbm,0)).x
        if ($mouse.x <= %c) {
          var %a 1,%p $hget($hget(sbm,focus),cursor),%t $left($hget($hget(sbm,focus),editbox),%p)
          while (%a <= $len(%t)) && ($width($right(%t,%a),$hget($hget(sbm,focus),font),$hget($hget(sbm,focus),fontsize)) <= $calc(%c - $mouse.x)) {
            inc %a
          }
          if (%a != 1) {
            hadd $hget(sbm,focus) sel $calc(%p - %a + 1) %p
          }
        }
        else {
          var %a 1,%p $hget($hget(sbm,focus),cursor),%t $mid($hget($hget(sbm,focus),editbox),%p)
          while (%a <= $len(%t)) && ($width($left(%t,%a),$hget($hget(sbm,focus),font),$hget($hget(sbm,focus),fontsize)) <= $calc($mouse.x - %c)) {
            inc %a
          }
          if (%a != 1) {
            hadd $hget(sbm,focus) sel %p $calc(%p + %a -1)
          }
        }
      }
    }
    if ($hget(sbm,view) == init) {
      if ($inrect($mouse.x,$mouse.y,280,200,$width(Connect to a game,segoe ui symbol,25),$height(Connect to a game,segoe ui symbol,25))) {
        hadd sbm hoverinit 1
      }
      elseif ($inrect($mouse.x,$mouse.y,280,300,$width(Create a game,segoe ui symbol,25),$height(Create a game,segoe ui symbol,25))) {
        hadd sbm hoverinit 2 
      }
      elseif ($inrect($mouse.x,$mouse.y,280,400,$width(Options,segoe ui symbol,25),$height(Options,segoe ui symbol,25))) {
        hadd sbm hoverinit 3 
      }
      else hdel sbm hoverinit
    }
    elseif ($v1 == options) {
      if ($inrect($mouse.x,$mouse.y,10,5,$width($chr(8592) Back,segoe ui symbol,20),$height($chr(8592) Back,segoe ui symbol,20))) {
        hadd sbm hoveroptions 6
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,400,100,$width($chr(9744) $chr(160) Flash on highlight,segoe ui symbol,15),$height($chr(9744) $chr(160) Flash on highlight,segoe ui symbol,15))) {
        hadd sbm hoveroptions 7
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,400,130,$width($chr(9744) $chr(160) Select a player on connect,segoe ui symbol,15),$height($chr(9744) $chr(160) Select a player on connect,segoe ui symbol,15))) {
        hadd sbm hoveroptions 8
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,310,100,18)) {
        hadd sbm hoveroptions 13
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,330,100,18)) {
        hadd sbm hoveroptions 14
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,350,100,18)) {
        hadd sbm hoveroptions 15
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,370,100,18)) {
        hadd sbm hoveroptions 16
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,390,100,18)) {
        hadd sbm hoveroptions 17
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,410,100,18)) {
        hadd sbm hoveroptions 18
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,430,100,18)) {
        hadd sbm hoveroptions 19
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,450,100,18)) {
        hadd sbm hoveroptions 20
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,470,100,18)) {
        hadd sbm hoveroptions 21
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,490,100,18)) {
        hadd sbm hoveroptions 22
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,510,100,18)) {
        hadd sbm hoveroptions 23
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,530,100,18)) {
        hadd sbm hoveroptions 24
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,550,100,18)) {
        hadd sbm hoveroptions 25
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,570,100,18)) {
        hadd sbm hoveroptions 26
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,590,100,18)) {
        hadd sbm hoveroptions 27
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,610,100,18)) {
        hadd sbm hoveroptions 28
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,630,100,18)) {
        hadd sbm hoveroptions 29
        return
      }
      elseif ($inrect($mouse.x,$mouse.y,200,650,100,18)) {
        hadd sbm hoveroptions 30
        return
      }
      var %kl $keynumtodesc($hget(sbmoptions,keyleft)),%kr $keynumtodesc($hget(sbmoptions,keyright)),%ku $keynumtodesc($hget(sbmoptions,keyup)),%kd $keynumtodesc($hget(sbmoptions,keydown)),%kb $keynumtodesc($hget(sbmoptions,keybomb))
      if (%kl != Press the new key) {
        if ($inrect($mouse.x,$mouse.y,100,100,$width(%kl,segoe ui symbol,15),$height(%kl,segoe ui symbol,15))) {
          if (!$hget(sbm,keytemp)) {

            hadd sbm hoveroptions 1
            return  
          }
        }
      }
      else {
        if ($inrect($mouse.x,$mouse.y,300,100,$width($chr(10008),segoe ui symbol,15),$height($chr(10008),segoe ui symbol,15))) {
          hadd sbm hoveroptions 6
          return
        }
      }
      if (%kr != Press the new key) {
        if ($inrect($mouse.x,$mouse.y,100,130,$width(%kr,segoe ui symbol,15),$height(%kr,segoe ui symbol,15))) {
          if (!$hget(sbm,keytemp)) {
            hadd sbm hoveroptions 2
            return
          }
        }
      }
      else {
        if ($inrect($mouse.x,$mouse.y,300,130,$width($chr(10008),segoe ui symbol,15),$height($chr(10008),segoe ui symbol,15))) {
          hadd sbm hoveroptions 9
          return
        }
      }
      if (%ku != Press the new key) {
        if ($inrect($mouse.x,$mouse.y,100,160,$width(%ku,segoe ui symbol,15),$height(%ku,segoe ui symbol,15))) {
          if (!$hget(sbm,keytemp)) {
            hadd sbm hoveroptions 3
            return
          }
        }
      }
      else {
        if ($inrect($mouse.x,$mouse.y,300,160,$width($chr(10008),segoe ui symbol,15),$height($chr(10008),segoe ui symbol,15))) {
          hadd sbm hoveroptions 10
          return
        }
      }
      if (%kd != Press the new key) {

        if ($inrect($mouse.x,$mouse.y,100,190,$width(%kd,segoe ui symbol,15),$height(%kd,segoe ui symbol,15))) {
          if (!$hget(sbm,keytemp)) {
            hadd sbm hoveroptions 4
            return
          }
        }
      }
      else {
        if ($inrect($mouse.x,$mouse.y,300,190,$width($chr(10008),segoe ui symbol,15),$height($chr(10008),segoe ui symbol,15))) {
          hadd sbm hoveroptions 11
          return
        }
      }

      if (%kb != Press the new key) {

        if ($inrect($mouse.x,$mouse.y,100,220,$width(%kb,segoe ui symbol,15),$height(%kb,segoe ui symbol,15))) {
          if (!$hget(sbm,keytemp)) {
            hadd sbm hoveroptions 5
            return
          }
        }
      }
      else {
        if ($inrect($mouse.x,$mouse.y,300,220,$width($chr(10008),segoe ui symbol,15),$height($chr(10008),segoe ui symbol,15))) {
          hadd sbm hoveroptions 12
          return
        }
      }
      hadd sbm hoveroptions 0
    }
    elseif ($v1 == create) {
      if ($inrect($mouse.x,$mouse.y,10,5,$width($chr(8592) Back,segoe ui symbol,20),$height($chr(8592) Back,segoe ui symbol,20))) {
        if ($hget(sbm,hovercreate) == 2) || ($v1 == 4) hadd sbm hovercreate 4
        else hadd sbm hovercreate 1
      }
      elseif ($inrect($mouse.x,$mouse.y,300,500,$width(Start,segoe ui symbol,28),$height(Start,segoe ui symbol,28))) {
        if ($regex($hget(sbmeditservport,editbox),$sbmreg_validport)) && ($hget(sbmeditservnick,editbox) != $null) hadd sbm hovercreate 3
      }
      else {
        if ($regex($hget(sbmeditservport,editbox),$sbmreg_validport)) && ($hget(sbmeditservnick,editbox) != $null) {
          hadd sbm hovercreate 2
        }
        else hdel sbm hovercreate
      }
    }
    elseif ($v1 == connect) {
      if ($inrect($mouse.x,$mouse.y,10,5,$width($chr(8592) Back,segoe ui symbol,20),$height($chr(8592) Back,segoe ui symbol,20))) {
        if ($hget(sbm,hoverconnect) == 2) || ($v1 == 4) hadd sbm hoverconnect 4
        else hadd sbm hoverconnect 1
      }
      elseif ($inrect($mouse.x,$mouse.y,300,500,$width(Connect,segoe ui symbol,28),$height(Connect,segoe ui symbol,28))) {
        if ($iptype($hget(sbmeditip,editbox)) != $null) && ($regex($hget(sbmeditport,editbox),$sbmreg_validport)) && ($hget(sbmeditnick,editbox) != $null) hadd sbm hoverconnect 3
      }
      else {
        if ($iptype($hget(sbmeditip,editbox)) != $null) && ($regex($hget(sbmeditport,editbox),$sbmreg_validport)) && ($hget(sbmeditnick,editbox) != $null) {
          hadd sbm hoverconnect 2
        }
        else hdel sbm hoverconnect 
      }
    }
    elseif ($v1 == connected) {
      if ($inrect($mouse.x,$mouse.y,$calc($window(@sbm).dw - 30),$calc($window(@sbm).dh - 37),$width($chr(55357) $+ $chr(56833),segoe ui symbol,25),$height($chr(55357) $+ $chr(56833),segoe ui symbol,25))) {
        if (!$window(@sbmsmileybuf)) sbminitsmiley
        if (!$window(@sbmsmiley)) window -fBdopw0 +Ld @sbmsmiley $calc($mouse.cx -170) $calc($mouse.cy - 170) 173 167
        else {
          if ($active != @sbmsmiley) window -ao @sbmsmiley $calc($mouse.cx -165) $calc($mouse.cy - 165)
        }
        drawcopy @sbmsmileybuf 0 0 173 167 @sbmsmiley 0 0
      }
      else {
        if ($window(@sbmsmiley)) window -h @sbmsmiley
      }
      if ($inrect($mouse.x,$mouse.y,81,235,$width($+($chr(31),Play),segoe ui symbol,14),$height($+($chr(31),Play),segoe ui symbol,14))) {
        if ($hget(sbm,player1) == $null) hadd sbm hoverconnected 1
      }
      elseif ($inrect($mouse.x,$mouse.y,281,235,$width($+($chr(31),Play),segoe ui symbol,14),$height($+($chr(31),Play),segoe ui symbol,14))) {
        if ($hget(sbm,player1) == $null) hadd sbm hoverconnected 2
      }
      elseif ($inrect($mouse.x,$mouse.y,481,235,$width($+($chr(31),Play),segoe ui symbol,14),$height($+($chr(31),Play),segoe ui symbol,14))) {
        if ($hget(sbm,player1) == $null) hadd sbm hoverconnected 3
      }
      elseif ($inrect($mouse.x,$mouse.y,681,235,$width($+($chr(31),Play),segoe ui symbol,14),$height($+($chr(31),Play),segoe ui symbol,14))) {
        if ($hget(sbm,player1) == $null) hadd sbm hoverconnected 4
      }
      elseif ($inrect($mouse.x,$mouse.y,10,5,$width($chr(8592) Leave,segoe ui symbol,20),$height($chr(8592) Leave,segoe ui symbol,20))) {
        hadd sbm hoverconnected 7
      }
      elseif ($inrect($mouse.x,$mouse.y,$calc($window(@sbm).dw - 14),$hget(sbm,yscroll),$hget(sbm,wscroll),$hget(sbm,hscroll))) {
        if ($mouse.key & 1) {
          var %x $calc($hget(sbm,scrolling) - $mouse.y)
          echo -s scrollup $calc(($hget(sbm,yscroll) - %x) / $hget(sbm,hscroll) * $hget(sbmchat,0).item * 18)
        }
      }
      else {
        var %p $findtok($iif($hget(sbm,player1) != $null,$v1,0) $iif($hget(sbm,player2) != $null,$v1,0) $iif($hget(sbm,player3) != $null,$v1,0) $iif($hget(sbm,player4) != $null,$v1,0),$hget(sbm,nick),32)
        if (%p) {
          if ($inrect($mouse.x,$mouse.y,$calc(75 + (%p - 1) * 200 + 7 + $width($hget(sbm,nick),segoe ui symbol,14)),235,$width($chr(10008),segoe ui symbol,14),$height($chr(10008),segoe ui symbol,14))) {
            hadd sbm hoverconnected 6
          }
          else hdel sbm hoverconnected
        }
        else hdel sbm hoverconnected
      }
    }
  }
  ;leave: window -h @sbmsmiley
  dclick:{
    if ($hget(sbm,view) == init) {

    }
    elseif ($v1 == connected) {
      sbmdclickedit sbmeditchat
    }
    elseif ($v1 == connect) {
      tokenize 32 sbmeditip sbmeditport sbmeditnick
      sbmdclickedit $*
    }
    elseif ($v1 == create) {
      tokenize 32 sbmeditservport sbmeditservnick
      sbmdclickedit $*
    }
  }
  $iif($~adiirc,wheelup) :{
    hdec sbm scroll
    if ($calc($hget(sbm,scroll) - 8) < 0) {
      hinc sbm scroll
    }
  }
  $iif($~adiirc,wheeldown) :{
    hinc sbm scroll
    if ($hget(sbm,scroll) > $hget(sbmchat,0).item) {
      hdec sbm scroll
    }
  }
}
alias sbmdclickedit {
  if ($inroundrect($mouse.x,$mouse.y,$hget($1,x),$hget($1,y),$hget($1,w),$hget($1,h),$hget($1,i),$hget($1,e))) {
    if ($hget($1,editbox) != $null) {
      hadd $1 sel 0 $len($v1)
      hadd $1 $len($v1)
    }
  }
}
on *:close:@sbm:{
  hfree sbm 
  hfree -w sbmchat 
  hfree -w sbmeditchat*
  hfree -w sbmsmiley
  .timersbm off
  window -c @sbmsmiley
  hfree -w sbmeditservport*
  hfree -w sbmeditservnick*
  hfree -w sbmeditip*
  hfree -w sbmeditport*
  hfree -w sbmeditnick*
  window -c @sbmsmileybuf
  window -c @sbmbuf
  window -c @sbmtiles
  hfree -w sbmmap
  hfree -w sbmoptions
  sockclose sbmclient
  if ($hget(sbmserv)) sbmserv stop
}
alias sbmreg_validserver return ^(?:(?:25[0-5]|2[0-4]\d|1?\d\d?)(?:\.(?!$)|$)){4}|^(?:\w+\.)+\w+$
alias sbmreg_validport return ^(?:[1-9]|\d{1,4}|[1-5]\d{4}|6(?:[0-4]\d{3}|5(?:[0-4]\d{2}|5(?:[0-2]\d|3[0-5]))))$
alias sbminitsmiley {
  window -Bfdhp +Ld @sbmsmileybuf -1 -1 173 167
  drawrect -rf @sbmsmileybuf 2345687 0 0 0 180 180
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 -1 0 $chr(55357) $+ $chr(56833)
  hadd -m sbmsmiley 0.0 $chr(55357) $+ $chr(56833)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 24 0 $chr(55357) $+ $chr(56834)
  hadd -m sbmsmiley 1.0 $chr(55357) $+ $chr(56834)

  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 49 0 $chr(55357) $+ $chr(56835)
  hadd -m sbmsmiley 2.0 $chr(55357) $+ $chr(56835)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 74 0 $chr(55357) $+ $chr(56836)
  hadd -m sbmsmiley 3.0 $chr(55357) $+ $chr(56836)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 99 0 $chr(55357) $+ $chr(56837)
  hadd -m sbmsmiley 4.0 $chr(55357) $+ $chr(56837)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 124 0 $chr(55357) $+ $chr(56838)
  hadd -m sbmsmiley 5.0 $chr(55357) $+ $chr(56838)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 149 0 $chr(55357) $+ $chr(56839)
  hadd -m sbmsmiley 6.0 $chr(55357) $+ $chr(56839)

  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 -1 26 $chr(55357) $+ $chr(56840)
  hadd -m sbmsmiley 0.1 $chr(55357) $+ $chr(56840)

  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 24 26 $chr(55357) $+ $chr(56841)
  hadd -m sbmsmiley 1.1 $chr(55357) $+ $chr(56841)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 49 26 $chr(55357) $+ $chr(56842)
  hadd -m sbmsmiley 2.1 $chr(55357) $+ $chr(56842)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 74 26 $chr(55357) $+ $chr(56843)
  hadd -m sbmsmiley 3.1 $chr(55357) $+ $chr(56843)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 99 26 $chr(55357) $+ $chr(56844)
  hadd -m sbmsmiley 4.1 $chr(55357) $+ $chr(56844)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 124 26 $chr(55357) $+ $chr(56845)      
  hadd -m sbmsmiley 5.1 $chr(55357) $+ $chr(56845)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 149 26 $chr(55357) $+ $chr(56846)
  hadd -m sbmsmiley 6.1 $chr(55357) $+ $chr(56846)

  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 -1 52 $chr(55357) $+ $chr(56847)
  hadd -m sbmsmiley 0.2 $chr(55357) $+ $chr(56847)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 24 52 $chr(55357) $+ $chr(56848)
  hadd -m sbmsmiley 1.2 $chr(55357) $+ $chr(56848)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 49 52 $chr(55357) $+ $chr(56850)
  hadd -m sbmsmiley 2.2 $chr(55357) $+ $chr(56850)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 74 52 $chr(55357) $+ $chr(56851)
  hadd -m sbmsmiley 3.2 $chr(55357) $+ $chr(56851)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 99 52 $chr(55357) $+ $chr(56852)
  hadd -m sbmsmiley 4.2 $chr(55357) $+ $chr(56852)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 124 52 $chr(55357) $+ $chr(56854)
  hadd -m sbmsmiley 5.2 $chr(55357) $+ $chr(56854)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 149 52 $chr(55357) $+ $chr(56885)
  hadd -m sbmsmiley 6.2 $chr(55357) $+ $chr(56885)

  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 -1 78 $chr(55357) $+ $chr(56883)
  hadd -m sbmsmiley 0.3 $chr(55357) $+ $chr(56883)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 24 78 $chr(55357) $+ $chr(56860)
  hadd -m sbmsmiley 1.3 $chr(55357) $+ $chr(56860)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 49 78 $chr(55357) $+ $chr(56861)
  hadd -m sbmsmiley 2.3 $chr(55357) $+ $chr(56861)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 74 78 $chr(55357) $+ $chr(56862)      
  hadd -m sbmsmiley 3.3 $chr(55357) $+ $chr(56862)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 99 78 $chr(55357) $+ $chr(56864)
  hadd -m sbmsmiley 4.3 $chr(55357) $+ $chr(56864)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 124 78 $chr(55357) $+ $chr(56886)
  hadd -m sbmsmiley 5.3 $chr(55357) $+ $chr(56886)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 149 78 $chr(55357) $+ $chr(56856)
  hadd -m sbmsmiley 6.3 $chr(55357) $+ $chr(56856)

  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 -1 104 $chr(55357) $+ $chr(56887)
  hadd -m sbmsmiley 0.4 $chr(55357) $+ $chr(56887)

  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 24 104 $chr(55357) $+ $chr(56865)
  hadd -m sbmsmiley 1.4 $chr(55357) $+ $chr(56865)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 49 104 $chr(55357) $+ $chr(56866)
  hadd -m sbmsmiley 2.4 $chr(55357) $+ $chr(56866)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 74 104 $chr(55357) $+ $chr(56867)
  hadd -m sbmsmiley 3.4 $chr(55357) $+ $chr(56867)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 99 104 $chr(55357) $+ $chr(56868)
  hadd -m sbmsmiley 4.4 $chr(55357) $+ $chr(56868)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 124 104 $chr(55357) $+ $chr(56869)
  hadd -m sbmsmiley 5.4 $chr(55357) $+ $chr(56869)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 149 104 $chr(55357) $+ $chr(56872)
  hadd -m sbmsmiley 6.4 $chr(55357) $+ $chr(56872)

  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 -1 130 $chr(55357) $+ $chr(56873)
  hadd -m sbmsmiley 0.5 $chr(55357) $+ $chr(56873)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 24 130 $chr(55357) $+ $chr(56874)
  hadd -m sbmsmiley 1.5 $chr(55357) $+ $chr(56874)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 49 130 $chr(55357) $+ $chr(56875)
  hadd -m sbmsmiley 2.5 $chr(55357) $+ $chr(56875)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 74 130 $chr(55357) $+ $chr(56877)
  hadd -m sbmsmiley 3.5 $chr(55357) $+ $chr(56877)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 99 130 $chr(55357) $+ $chr(56880)
  hadd -m sbmsmiley 4.5 $chr(55357) $+ $chr(56880)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 124 130 $chr(55357) $+ $chr(56881)
  hadd -m sbmsmiley 5.5 $chr(55357) $+ $chr(56881)
  drawtext -r @sbmsmileybuf 0 "Segoe UI Symbol" 25 149 130 $chr(55357) $+ $chr(56882)
  hadd -m sbmsmiley 6.5 $chr(55357) $+ $chr(56882)
}
menu @sbmsmiley {

  leave: window -h @sbmsmiley
  mouse:{ drawcopy -n @sbmsmileybuf 0 0 173 167 @sbmsmiley 0 0 | if ($int($calc($mouse.y / 26)) < 6) drawrect -rn @sbmsmiley 255 1 $calc($int($calc($mouse.x / 25)) * 25 - 1) $calc($int($calc($mouse.y / 26)) * 26 + 5) 25 26 | drawdot @sbmsmiley }
  sclick: {
    var %t $+($int($calc($mouse.x / 25)),.,$int($calc($mouse.y / 26)))
    var %h $$hget(sbmsmiley,%t)
    sockwrite -n sbmclient TEXT %h
  }
}

;CLIENT
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
      sbmchangeview connected
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
alias PickColor {
  window -c @PickColor
  window -pdCBko +d @PickColor -1 -1 315 340
  set %sbmitem $1
  drawrect -fr @PickColor 14215660 2 0 0 315 340
  drawrect -r @PickColor 0 2 0 0 315 340
  drawrect -r @PickColor 0 2 0 0 260 260
  drawrect -fr @PickColor 14342874 2 270 272 30 52
  drawrect -r @PickColor 0 2 270 272 30 52
  drawrect -f @PickColor 0 2 270 0 30 260
  drawrect -r @PickColor 0 2 270 0 30 260
  drawpic @PickColor 2 2 $qt($scriptdirPanelColor.bmp)
  pickcolord 128 128 128
  drawtext -r @PickColor 0 Verdana 13 210 270 R:
  drawtext -r @PickColor 0 Verdana 13 209 290 G:
  drawtext -r @PickColor 0 Verdana 13 210 310 B:
  drawtext -r @PickColor 0 Verdana 13 15 310 Select
  drawtext -r @PickColor 0 Verdana 13 120 310 Close
}
alias pickcolord {
  drawrect -frn @PickColor 14215660 1 233 270 30 57
  if ($1 == $null) tokenize 44 $rgb($getdot(@pickcolor,$mouse.x,$mouse.y))
  drawtext -rn @PickColor 0 Verdana 13 235 270 $1
  drawtext -rn @PickColor 0 Verdana 13 235 290 $2
  drawtext -rn @PickColor 0 Verdana 13 235 310 $3
  drawrect -nfr @PickColor $rgb($1,$2,$3) 0 272 274 26 48
  var %c $1-,%n 0
  while (%n <= 128) {
    drawline -nr @PickColor $rgb($int($calc(($gettok(%c,1,32) * %n + 255 * (128 - %n)) / 128)),$int($calc(($gettok(%c,2,32) * %n + 255 * (128 - %n)) / 128)),$int($calc(($gettok(%c,3,32) * %n + 255 * (128 - %n)) / 128))) 1 272 $calc(2 + %n) 298 $calc(2 + %n)
    drawline -nr @PickColor $rgb($int($calc(($gettok(%c,1,32) * (128 - %n)) / 128)),$int($calc(($gettok(%c,2,32) * (128 - %n)) / 128)),$int($calc(($gettok(%c,3,32) * (128 - %n)) / 128))) 1 272 $calc(130 + %n) 298 $calc(130 + %n)
    inc %n
  }
  drawdot @pickcolor
}
on *:close:@pickcolor:unset %sbmitem
Menu @PickColor {
  sclick :{
    if ($inrect($mouse.x,$mouse.y,2,2,256,256)) {
      pickcolord
    }
    elseif ($inrect($mouse.x,$mouse.y,272,2,26,257)) {
      drawrect -frn @PickColor $rgb(236,233,216) 1 233 270 30 57
      tokenize 44 $rgb($getdot(@PickColor,$mouse.x,$mouse.y))
      drawtext -rn @PickColor 0 Verdana 13 235 270 $1
      drawtext -rn @PickColor 0 Verdana 13 235 290 $2
      drawtext -rn @PickColor 0 Verdana 13 235 310 $3
      drawrect -frn @PickColor $rgb($1,$2,$3) 0 272 274 26 48
      drawdot @pickcolor
    }
    elseif ($inrect($mouse.x,$mouse.y,116,308 ,56,21)) {
      unset %sbmitem | window -c @PickColor | window -a @sbm
    }
    elseif ($inrect($mouse.x,$mouse.y,11,308 ,56,21)) { hadd sbmoptions %sbmitem $getdot(@pickcolor,280,280) | unset %sbmitem | window -c @PickColor | window -a @sbm }
  }
  mouse: {
    if ($inrect($mouse.x,$mouse.y,2,2,256,256)) && ($mouse.key & 1) {
      pickcolord
    }
    elseif ($inrect($mouse.x,$mouse.y,272,2,26,257)) && ($mouse.key & 1) {
      drawrect -frn @PickColor $rgb(236,233,216) 1 233 270 30 57
      tokenize 44 $rgb($getdot(@PickColor,$mouse.x,$mouse.y))
      drawtext -rn @PickColor 0 Verdana 13 235 270 $1
      drawtext -rn @PickColor 0 Verdana 13 235 290 $2
      drawtext -rn @PickColor 0 Verdana 13 235 310 $3
      drawrect -frn @PickColor $rgb($1,$2,$3) 0 272 274 26 48
      drawdot @pickcolor
    }
    elseif ($inrect($mouse.x,$mouse.y,11,308 ,56,21)) {

      drawrect -frn @PickColor $rgb(183,182,163) 2 11 308 50 21
      drawrect -rn @PickColor 0 2 11 308 50 21
      drawtext -rn @PickColor 0 Verdana 13 15 310 Select
    }
    elseif ($inrect($mouse.x,$mouse.y,116,308 ,56,21)) {

      drawrect -frn @PickColor $rgb(183,182,163) 2 116 308 45 21
      drawrect -rn @PickColor 0 2 116 308 45 21
      drawtext -rn @PickColor 0 Verdana 13 120 310 Close
    }

    else {
      drawrect -fnr @PickColor $rgb(236,233,216) 2 11 308 50 21
      drawtext -rn @PickColor 0 Verdana 13 15 310 Select
      drawrect -fnr @PickColor $rgb(236,233,216) 2 116 308 50 21
      drawtext -rn @PickColor 0 Verdana 13 120 310 Close

    }

    drawdot @pickcolor
  }
}
alias Lum tokenize 44 $rgb($1) | return $calc(0.2126 * $brightness($1) + 0.7152 * $brightness($2) + 0.0722* $brightness($3))
alias brightness var %res = $1 / 255 | return $iif(%res <= 0.03928, $calc(%res / 12.92), $calc((( %res + 0.055) / 1.055) ^ 2.4))
alias contrast tokenize 32 $sorttok($Lum($1) $Lum($2),32,nr) | return $calc( ($1 + 0.05) / ($2 + 0.05) )

