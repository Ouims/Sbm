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

      if ($hget(sbmui,$+($1,_thumb))) drawrect -rfn @sbm 16777215 1 %x $calc(%y + $hget(sbmui,$+($1,_thumb_position))) %w $v1
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
* @identifer $sbmcooincontrol
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
  var %i = $hget(sbmchat,0).item

  hadd -m sbmchat $calc(%i + 1) $1-

  if (%i == $hget(sbmui,display_current)) hinc sbmui display_current

  sbmresizechatthumb
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
  var %lines = $hget(sbmchat,0).item
  var %height = $hget(sbmui,display_h)
  var %scroll = $hget(sbmui,scroll_h)
  var %viewing = $int($calc(%height / 18))
  var %current = $hget(sbmui,display_current)

  hadd sbmui scroll_thumb 0

  if (%lines > %viewing) {
    if (%current != %lines) && (%current < %viewing) && ($calc((%current - %viewing) * -1) > 0) {
      hinc sbmui display_current $v1
      inc %current $v1
    }

    var %content = $calc(%lines * 18)
    var %visible = $calc((%viewing * 18) / %content)
    var %thumb = $calc(%scroll * %visible)
    var %jump = $calc((%scroll - %thumb) / (%lines - %viewing))

    hadd sbmui scroll_thumb_hidden $false
    hadd sbmui scroll_thumb %thumb
    hadd sbmui scroll_thumb_jump %jump
    hadd sbmui scroll_thumb_position $calc(%jump * ($hget(sbmui,display_current) - %viewing))
  }
  elseif (%current != %lines) && (%current < %viewing) && ($calc((%current - %viewing) * -1) > 0) {
    hinc sbmui display_current $v1
    inc %current $v1
  }

  if (%lines === 0) hdel -w scroll_thumb*
}