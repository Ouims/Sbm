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
      hadd sbmui menu_x 0
      hadd sbmui menu_w %ww
      hadd sbmui menu_h 400
      
      if (%ww > 800) {
        hadd sbmui menu_x $calc((%ww - 800) / 2)
        hadd sbmui menu_w 800
      }
      if (%wh < 400) hadd sbmui menu_h $v1

      if (%wh > 480) && (%ww > 200) {
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
    if ($hget(sbm,owner)) {
      hadd sbmui start_hidden $false
      hinc sbm startflash
      if ($hget(sbm,startflash) == 6) hadd sbm startflash 1
      hadd sbmui start_forecolor $gettok(64 92 127 168 255,$hget(sbm,startflash),32)
    }

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

  if ($hget(sbmui,$+(%focus,_type)) == edit) && (!$hget(sbmui,$+(%focus,_hidden))) {
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