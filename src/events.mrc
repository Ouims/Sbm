on *:close:@sbm: {
  hfree sbm
  hfree sbmui
  .timersbm off   
}

menu @sbm {
  mouse: {
    hadd sbmui mouseInControl $null

    noop $hfind(sbmui,*_type,0,w,hadd sbmui mouseInControl $iif($cooInControl($left($1,-5),$mouse.x,$mouse.y),$left($1,-5),$hget(sbmui,mouseInControl)))
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