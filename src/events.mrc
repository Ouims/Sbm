on *:close:@sbm: {
  hfree sbm
  hfree sbmui
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
        while (%a <= $len(%t)) && ($width($right(%t,%a),$hget(sbmui,$+(%focus,_font)),$hget(sbmui,$+(%focus,_size))) <= $calc(%c - $mouse.x)) {
          inc %a
        }
        if (%a != 1) {
          hadd sbmui $+(%focus,_sel) $calc(%p - %a + 1) %p
        }
      }
      else {
        var %a 1,%p $hget(sbmui,$+(%focus,_cursor)),%t $mid($hget(sbmui,$+(%focus,_text)),%p)
        while (%a <= $len(%t)) && ($width($left(%t,%a),$hget(sbmui,$+(%focus,_font)),$hget(sbmui,$+(%focus,_size))) <= $calc($mouse.x - %c)) {
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
          elseif ($v1 > $calc(%x + 10 + $width(%t,$hget(sbmui,$+(%active,_font)),$hget(sbmui,$+(%active,_size))))) hadd sbmui $+(%active,_cursor) $len(%t)
          else {
            var %a 1
            while (%a <= $len(%t)) && ($calc(%x + 10 + $width($left(%t,%a),$hget(sbmui,$+(%active,_font)),$hget(sbmui,$+(%active,_size)))) <= $mouse.x) {
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

    if ($keychar != $null) {
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

        if ($width($+(%l,%c,%r),$hget(sbmui,$+(%focus,_font)),$hget(sbmui,$+(%focus,_size))) > $calc($hget(sbmui,$+(%focus,_w)) - 20)) return

        hadd sbmui $+(%focus,_text) $+(%l,%c,%r)
        hinc sbmui $+(%focus,_cursor)
      }
    }
  }
}