/**
*
* Game loop.
*
* @command /sbmloop
*
* @global
*
*/
alias sbmloop {
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

      if (%wh > 480) && (%ww > 270) {
        hadd sbmui display_resize $true
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

        hadd sbmui display_total_visible_lines $int($calc((%wh - 440) / 18))

        sbmresizechat
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

    var %p = $hget(sbm,player1) $hget(sbm,player2) $hget(sbm,player3) $hget(sbm,player4)

    if ($hget(sbm,player1) != $null) {
      hadd sbmui select_white_text $v1
      hadd sbmui select_white_disabled $true
    }
    else {
      hadd sbmui select_white_text $+($chr(31),Play)
      hadd sbmui select_white_disabled $istok(%p,$hget(sbm,nick),32)
    }
    if ($hget(sbm,player2) != $null) {
      hadd sbmui select_black_text $v1
      hadd sbmui select_black_disabled $true
    }
    else {
      hadd sbmui select_black_text $+($chr(31),Play)
      hadd sbmui select_black_disabled $istok(%p,$hget(sbm,nick),32)
    }
    if ($hget(sbm,player3) != $null) {
      hadd sbmui select_orange_text $v1
      hadd sbmui select_orange_disabled $true
    }
    else {
      hadd sbmui select_orange_text $+($chr(31),Play)
      hadd sbmui select_orange_disabled $istok(%p,$hget(sbm,nick),32)
    }
    if ($hget(sbm,player4) != $null) {
      hadd sbmui select_blue_text $v1
      hadd sbmui select_blue_disabled $true
    }
    else {
      hadd sbmui select_blue_text $+($chr(31),Play)
      hadd sbmui select_blue_disabled $istok(%p,$hget(sbm,nick),32)
    }

    var %lines = $hget(sbmchat,0).item

    if (%lines) && (!$hget(sbmui,display_hidden)) {
      var %dy = $hget(sbmui,display_y)
      var %last_line = $gettok($hget(sbmui,display_last_visible_line),1,32)
      var %line = %last_line
      var %wrapped_line = $gettok($hget(sbmui,display_last_visible_line),2,32)
      var %y = $calc(%dy + $hget(sbmui,display_h) - 18)
      var %font = $hget(sbmui,display_font)
      var %fontsize = $hget(sbmui,display_fontsize)
      var %width = $calc($hget(sbmui,display_w) - 175)
      var %resize_thumb = $false

      var %bg = $hget(sbmoptions,colormainbg)

      while (%y > %dy) && (%line) && ($hget(sbmchat,%line)) {
        tokenize 32 $v1
        
        var %color = 0

        if ($2 == *) %color = $hget(sbmoptions,colorchatinfos)

        var %lines = $wrap($3-,$noqt(%font),%fontsize,%width,1,0)

        if (%line < $hget(sbmui,display_upper_bound)) {
          hinc sbmui display_total_lines $calc(%lines - 1)
          hdec sbmui display_upper_bound
          hinc sbmui display_position $calc(%lines - 1)

          var %resize_thumb = $true
        }

        if (%line == %last_line) %lines = %wrapped_line

        var %in_mouse = $hget(sbmui,mouseInControl)
        var %check_mouse = $false

        if (%in_mouse == display) && ($mouse.key & 1) %check_mouse = $true

        while (%y > %dy) && (%lines) {
          var %text = $wrap($3-,$noqt(%font),%fontsize,%width,1,%lines)

          if (%check_mouse) && ($inrect($hget(sbmui,mousex),$hget(sbmui,mousey),170,%y,%width,18)) {
            var %x = $calc($hget(sbmui,mousex) - 170)

            if ($hget(sbmui,display_sel_start) == -1 -1) {
              if (%x < $width($left($strip(%text),1),$noqt(%font),%fontsize,1,0)) hadd sbmui display_sel_start %line %lines 0
              else hadd sbmui display_sel_start %line %lines $len($wrap(%text,$noqt(%font),%fontsize,%x,0,1))
            }

            if (%x > $width($left($strip(%text),1),$noqt(%font),%fontsize,1,0)) hadd sbmui display_sel_end %line %lines $len($wrap(%text,$noqt(%font),%fontsize,%x,0,1))

            if ($hget(sbmui,display_sel_start) != $hget(sbmui,display_sel_end)) && ($v1 != -1 -1) drawrect -rfin @sbm %bg 1 170 %y %x 18
          }

          drawtext -porn @sbm %color %font %fontsize 170 $calc(%y + 1) %text

          dec %y 18
          dec %lines
        }

        if (%lines == 0) {
          drawtext -porn @sbm %color %font %fontsize 2 $calc(%y + 18) $1
          drawtext -porn @sbm %color %font %fontsize $calc(160 - $width($2,%font,%fontsize)) $calc(%y + 18) $2
        }

        dec %line
      }

      if (%resize_thumb) sbmresizechatthumb
    }

    if ($hget(sbmui,scroll_to)) {
      var %pos = $round($calc(($v1 - $hget(sbmui,scroll_y)) / $hget(sbmui,scroll_h) * ($hget(sbmui,display_total_lines) + $hget(sbmui,display_total_visible_lines))),0)
      ;echo -s %pos - $hget(sbmui,display_position) $hget(sbmui,display_total_lines) $hget(sbmui,display_total_visible_lines)

      if (%pos > $hget(sbmui,display_position)) sbmscroll down
      elseif ($v1 < $v2) sbmscroll up
      else hdel sbmui scroll_to
    } 
  }

  noop $hfind(sbmui,*_type,0,w,sbmdrawcontrol $left($1,-5))

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

  if ($hget(sbm,view) == game) {
    drawrect -frn @sbm 3168272 0 0 0 %ww %wh
    tokenize 32 $hget(sbm,items)
    ;sbmdrawitems $*
    var %ratio 208 / 240
    var %w $gettok($sorttok(%ww $calc(%wh / %ratio), 32, n), 1, 32),0), %h %ratio * %w
    drawcopy -n @sbmbuf 300 0 240 208 @sbm $sbmalign(%ww,%w,0).center $sbmalign(%wh,%h,0).center %w %h
    hinc sbm fpscount
    if ($calc($ticks - $hget(sbm,ticksbonus)) > 50) {
      if ($hget(sbm,bonustile)) hadd sbm bonustile 0
      else hadd sbm bonustile 16
      hadd sbm ticksbonus $ticks
    }
  }

  hinc sbm fpscount

  if ($calc($ticks - $hget(sbm,fpsticks)) >= 1000) {
    hadd sbm fps $hget(sbm,fpscount)
    hadd sbm fpscount 0
    hadd sbm fpsticks $ticks
  }

  titlebar @sbm fps $hget(sbm,fps)

  drawdot @sbm

  .timersbm -ho 1 0 if (!$isalias(sbmloop)) .timersbm -cho 1 0 $!timer(sbm).com $(|) else sbmloop
}