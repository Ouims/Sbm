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
  hadd sbmui $+($2,_size) $8

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
  var %size = $hget(sbmui,$+($1,_size))
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
      hadd sbmui $+($1,_size) %size
    }
  }

  if (%type == text) drawtext -nr @sbm $hget(sbmoptions,$iif($1 == $hget(sbmui,active),colorhoverhltext,colorhltext)) %font %size %x %y $hget(sbmui,$+($1,_text))
  elseif (%type == logo) drawpic -cstn @sbm 16777215 %x %y %w %h $qt($scriptdirassets\logo.png)

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
* Sets the active control.
*
* @command /setActiveControl
*
*/
alias setActiveControl {
  hadd sbmui active $null

  noop
}