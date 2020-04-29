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
  else {
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

      if ($hget(sbmchat,0).item) && (!$hget(sbmui,display_hidden)) {
        var %position = $hget(sbmui,display_position)
        var %visible = $hget(sbmui,display_total_visible_lines)
        var %visible_to_position = $sbmmax($calc(%position - %visible + 1),1)

        hadd sbmui display_draw_y $calc($hget(sbmui,display_y) + $hget(sbmui,display_h) - ((%position - %visible_to_position + 1) * 18))

        tokenize 32 $gettok($hget(sbmui,display_lines_positions),$+(%visible_to_position,-,%position),32)

        sbmdrawchatline $*
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