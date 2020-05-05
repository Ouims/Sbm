/**
*
* Adds a control.
*
* @command /sbmaddcontrol
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
* @global
*
*/
alias sbmaddcontrol {
  tokenize 13 $sbmgetparams($1-)

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

    tokenize 13 $sbmgetparams($1-6 $9-)
  }

  hadd sbmui $+($2,_font) $7
  hadd sbmui $+($2,_fontsize) $8

  hadd sbmui $+($2,_osize) $8

  hadd sbmui $+($2,_style) $9

  if ($10 != $null) hadd sbmui $+($2,_text) $10-

  if ($1 == edit) hadd sbmui $+($2,_bg) 8355711
  elseif ($1 == chat) {
    hadd sbmui $+($2,_total_visible_lines) $int($calc($6 / 18))
    hadd sbmui $+($2,_sel_start) -1 -1 -1
    hadd sbmui $+($2,_sel_end) -1 -1 -1
  }
}

/**
*
* Draws control.
*
* @command /sbmdrawcontrol
*
* @param <id>  control id
*
* @global
*
*/
alias sbmdrawcontrol {
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
        var %wx = 0
        var %wy = 0
        var %oww = $hget(sbmui,originalWidth)
        var %owh = $hget(sbmui,originalHeight)
        var %parent = $hget(sbmui,$+($1,_parent))

        if (%parent) {
          %wx = $hget(sbmui,$+(%parent,_x))
          %wy = $hget(sbmui,$+(%parent,_y))
          %ww = $hget(sbmui,$+(%parent,_w))
          %wh = $hget(sbmui,$+(%parent,_h))
          %oww = $hget(sbmui,$+(%parent,_ow))
          %owh = $hget(sbmui,$+(%parent,_oh))
        }

        var %ox = $hget(sbmui,$+($1,_ox))
        var %oy = $hget(sbmui,$+($1,_oy))
        var %ow = $hget(sbmui,$+($1,_ow))
        var %oh = $hget(sbmui,$+($1,_oh))
        var %osize = $hget(sbmui,$+($1,_osize))

        var %scale = $calc(1 / $sbmmax($calc(%oww / %ww),$calc(%owh / %wh)))

        if (%style == relative) {          
          %x = $calc((%ox / %oww) * %ww + %wx)
          %y = $calc((%oy / %owh) * %wh + %wy)
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

          %x = $calc((%rw - %w) / 2 + %x + %wx)
          %y = $calc((%rh - %h) / 2 + %y + %wy)

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

        if (%size < 0) %size = 0

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
    if (%type == text) drawtext -npr @sbm $iif($hget(sbmui,$+($1,_forecolor)),$v1,$hget(sbmoptions,colornormal)) %font %size %x %y $hget(sbmui,$+($1,_text))
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
      %x = $sbmalign(%w,$width(%t,%font,%size),%x).center
      drawtext -rn @sbm $hget(sbmoptions,colorelevator) %font %size %x %y %t
    }
    elseif (%type == scroll) {
      drawrect -rfn @sbm 0 1 %x %y %w %h

      if ($hget(sbmui,$+($1,_thumb_size))) drawrect -rfn @sbm 16777215 1 %x $calc(%y + $hget(sbmui,$+($1,_thumb_position))) %w $v1
    }
    elseif (%type == sprite) {
      tokenize 32 $hget(sbmui,$+($1,_text))

      drawpic -nst @sbm $1 %x %y %w %h $2-
    }
    elseif (%type == play_text) {
      var %color = $hget(sbmoptions,colorplay)

      if ($1 == $hget(sbmui,mouseInControl)) %color = $hget(sbmoptions,colorhoverplay)
      if ($hget(sbmui,$+($1,_disabled))) %color = 13816530

      drawtext -rpn @sbm %color %font %size %x %y $hget(sbmui,$+($1,_text))
    }

    ;drawrect -rn @sbm $rgb(220,220,220) 1 %x %y %w %h
  }
}

/**
*
* Checks if a coordinate is within a UI control.
*
* @identifier $sbmcooincontrol
*
* @param <id>        id of the control
* @param <x>         x position of coordinate
* @param <y>         y position of coordinate
*
* @global
*
*/
alias sbmcooincontrol {
  if (!$hget(sbmui,$+($1,_hidden))) {
    if ($hget(sbmui,$+($1,_i)) != $null) {
      return $inroundrect($2,$3,$hget(sbmui,$+($1,_x)),$hget(sbmui,$+($1,_y)),$hget(sbmui,$+($1,_w)),$hget(sbmui,$+($1,_h)),$hget(sbmui,$+($1,_i)),$hget(sbmui,$+($1,_e)))
    }
    
    return $inrect($2,$3,$hget(sbmui,$+($1,_x)),$hget(sbmui,$+($1,_y)),$hget(sbmui,$+($1,_w)),$hget(sbmui,$+($1,_h)))
  }

  return $false
}

alias sbmaddtext {
  var %line = $calc($hget(sbmchat,0).item + 1)
  var %font = $noqt($hget(sbmui,display_font))
  var %fontsize = $hget(sbmui,display_fontsize)
  var %width = $calc($hget(sbmui,display_w) - 175)
  var %scroll = $false
  var %line_lines = $wrap($3-,%font,%fontsize,%width,1,0)
  var %line_line = 1

  hadd -m sbmchat %line $1-

  if (!$hget(sbmui,display_total_lines)) {
    hadd sbmui display_total_lines 0
    hadd sbmui display_position 0
  }

  if ($hget(sbmui,display_total_lines) == $hget(sbmui,display_position)) %scroll = $true

  while (%line_line <= %line_lines) {
    hadd sbmui display_lines_positions $hget(sbmui,display_lines_positions) $+(%line,_,%line_line)
    
    hinc sbmui display_total_lines
    
    if (%scroll) sbmscroll down

    inc %line_line
  }

  sbmresizechatthumb
}

/**
*
* Scrolls the chat display.
*
* @command /sbmscroll
*
* @param <direction>  up to scroll up, down to scroll down
*
* @global
*
*/
alias sbmscroll {
  if ($1 == down) && ($hget(sbmui,display_position) < $hget(sbmui,display_total_lines)) {
    hinc sbmui display_position

    if ($hget(sbmui,scroll_thumb_size)) hinc sbmui scroll_thumb_position $hget(sbmui,scroll_thumb_jump)
  }
  elseif ($1 == up) && ($hget(sbmui,display_position) > $hget(sbmui,display_total_visible_lines)) {
    hdec sbmui display_position

    if ($hget(sbmui,scroll_thumb_size)) hdec sbmui scroll_thumb_position $hget(sbmui,scroll_thumb_jump)
  }
}

/**
*
* Resizes chat lines.
*
* @command /sbmresizechat
*
* @global
*
*/
alias sbmresizechat {
  if ($hget(sbmchat,0).item) {
    var %real_lines = $v1

    hadd sbmui display_total_lines 0
    hadd sbmui display_position $gettok($gettok($hget(sbmui,display_lines_positions),$hget(sbmui,display_position),32),1,95)
    hdel sbmui display_lines_positions

    var %font = $noqt($hget(sbmui,display_font))
    var %fontsize = $hget(sbmui,display_fontsize)
    var %width = $calc($hget(sbmui,display_w) - 175)
    var %line = 1
    var %position = $hget(sbmui,display_position)

    while (%line <= %real_lines) {
      var %line_lines = $wrap($gettok($hget(sbmchat,%line),3-,32),%font,%fontsize,%width,1,0)
      var %line_line = 1

      while (%line_line <= %line_lines) {
        hadd sbmui display_lines_positions $hget(sbmui,display_lines_positions) $+(%line,_,%line_line)

        inc %line_line
      }

      if (%line == %position) hadd sbmui display_position $numtok($hget(sbmui,display_lines_positions),32)

      hinc sbmui display_total_lines %line_lines

      inc %line
    }

    sbmresizechatthumb
  }
}

/**
*
* Resizes the chat's thumb.
*
* @command /sbmresizechatthumb
*
* @global
*
*/
alias sbmresizechatthumb {
  var %lines = $hget(sbmui,display_total_lines)
  var %height = $hget(sbmui,display_h)
  var %scroll = $hget(sbmui,scroll_h)
  var %viewing = $hget(sbmui,display_total_visible_lines)
  var %position = $hget(sbmui,display_position)

  hadd sbmui scroll_thumb_size 0

  if (%lines > %viewing) {
    if (%position != %lines) && (%position < %viewing) && ($calc((%position - %viewing) * -1) > 0) {
      hinc sbmui display_position $v1
      inc %position $v1
    }

    var %content = $calc(%lines * 18)
    var %visible = $calc((%viewing * 18) / %content)
    var %thumb = $calc(%scroll * %visible)
    var %jump = $calc((%scroll - %thumb) / (%lines - %viewing))

    hadd sbmui scroll_thumb_hidden $false
    hadd sbmui scroll_thumb_size %thumb
    hadd sbmui scroll_thumb_jump %jump
    hadd sbmui scroll_thumb_position $calc(%jump * (%position - %viewing))
  }

  if (%lines === 0) hdel -w sbmui scroll_thumb*
}

/**
*
* Draws a chat line
*
* @command /sbmdrawchatline
*
* @param <line_N>  the line and N, the position of the wrap
*
* @global
*
*/
alias sbmdrawchatline {
  var %line = $gettok($1,1,95)
  var %wrap = $gettok($1,2,95)
  var %y = $calc($hget(sbmui,display_draw_y) + 1)
  var %font = $noqt($hget(sbmui,display_font))
  var %fontsize = $hget(sbmui,display_fontsize)
  var %width = $calc($hget(sbmui,display_w) - 175)
  var %color = 0

  tokenize 32 $hget(sbmchat,%line)

  var -p %text = $wrap($3-,%font,%fontsize,%width,1,%wrap)

  if ($2 == *) %color = $hget(sbmoptions,colorchatinfos)

  if ($hget(sbmui,display_sel_start) != $hget(sbmui,display_sel_end)) {
    var %current = $+(%line,.,%wrap)
    var %start = $+($gettok($v1,1,32),.,$gettok($v1,2,32))
    var %end = $+($gettok($v2,1,32),.,$gettok($v2,2,32))
    var %start_char = $gettok($v1,3,32)
    var %end_char = $gettok($v2,3,32)

    if (%current isnum $+(%start,-,%end)) {
      var %x1 = 0
      var %x2 = $width(%text,%font,%fontsize,1,1)

      if (%current == %start) && (%current == %end) {
        if (%start_char > %end_char) {
          var %temp_char = %end_char

          %end_char = %start_char
          %start_char = %temp_char
        }

        %x1 = $width($left(%text,%start_char),%font,%fontsize,1,1)
        %x2 = $width($left(%text,%end_char),%font,%fontsize,1,1)
      }
      elseif (%current == %start) {
        if (%start > %end) %x2 = $width($left(%text,%start_char),%font,%fontsize,1,1)
        elseif (%start < %end) %x1 = $width($left(%text,%start_char),%font,%fontsize,1,1)
      }
      elseif (%current == %end) {
        if (%end > %start) %x2 = $width($left(%text,%end_char),%font,%fontsize,1,1)
        elseif (%end < %start) %x1 = $width($left(%text,%end_char),%font,%fontsize,1,1)
      }

      if (%x2) drawrect -rfn @sbm $rgb(255,255,255) 1 $calc(170 + %x1) %y $calc(%x2 - %x1) 17
    }
  }

  drawtext -porn @sbm %color $qt(%font) %fontsize 170 %y %text

  if (%wrap == 1) {
    drawtext -porn @sbm %color $qt(%font) %fontsize 2 %y $1
    drawtext -porn @sbm %color $qt(%font) %fontsize $calc(160 - $width($2,%font,%fontsize)) %y $2
  }

  hinc sbmui display_draw_y 18
}