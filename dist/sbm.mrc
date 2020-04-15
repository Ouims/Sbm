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
  }

  noop $hfind(sbmui,*_type,0,w,drawControl $left($1,-5))

  hadd sbmui resize $false

  var %focus = $hget(sbmui,focus)

  if ($hget(sbmui,$+(%focus,_type)) == edit) {
    if ($calc($ticks - $hget(sbmui,cursorticks)) > 500) {
      if ($hget(sbmui,drawcursor)) hadd sbmui drawcursor $false
      else hadd sbmui drawcursor $true

      hadd sbmui cursorticks $ticks
    }
    if ($hget(sbmui,drawcursor)) {
      var %x = $iif($hget(sbmui,$+(%focus,_cursor)) > 0,$width($left($hget(sbmui,$+(%focus,_text)),$v1),$hget(sbmui,$+(%focus,_font)),$hget(sbmui,$+(%focus,_size))),0)
      drawline -rn @sbm 0 1 $calc($hget(sbmui,$+(%focus,_x)) + 10 + %x) $calc($hget(sbmui,$+(%focus,_y)) + 6) $calc($hget(sbmui,$+(%focus,_x)) + 10 + %x) $calc($hget(sbmui,$+(%focus,_y)) + 21)
    }
  }

  drawdot @sbm

  .timersbm -ho 1 0 if (!$isalias(loop)) .timersbm -cho 1 0 $!timer(sbm).com $(|) else loop
}

/**
*
* Launches the game.
*
* @command /sbm
*
* @global
*
*/
alias sbm {
  if ($window(@sbm)) window -a sbm
  else {
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

    .hmake sbm
    hmake sbmui 1
    
    hadd sbmui originalWidth 800
    hadd sbmui originalHeight 600

    view menu

    loop
  }
}

/**
*
* Tokenizes a string based on a delimiter or quotes just as mIRC does for native commands.
*
* @identifier $getParameters
*
* @param <parameters>       String containing your parameters
* @param [delimiter=\x20]   The delimiter for your parameters
*
* @returns  String tokenized into $cr based on a specified delimiter or double quotes.
*
*/
alias -l getParameters {
  set -l %tokenized $null
  set -l %token 1
  set -l %chr $2

  if (%chr == $null) set -l %chr \x20

  set -l %regex /((?:"(?:[^"])*"|[^ $+ %chr $+ ])+)/g

  set -l %tokens $regex(tokens,$1,%regex)
  set -l %total $regml(tokens,0)

  while (%token <= %total) {
    set -l %tokenized $+(%tokenized,$cr,$regml(tokens,%token))

    inc %token
  }

  return %tokenized
}

/**
*
* Compares two numbers.
*
* @identifier $max
*
* @param <number>  first number to compare
* @param <number>  second number to compare
*
* @returns  the biggest number
*
*/
alias -l max {
  if ($1 > $2) return $1
  return $2
}

/**
*
* Compares two numbers.
*
* @identifier $min
*
* @param <number>  first number to compare
* @param <number>  second number to compare
*
* @returns  the smallest number
*
*/
alias -l min {
  if ($1 < $2) return $1
  return $2
}

/**
*
* Align helper.
*
* @identifier $align
*
* @param <available space>  available space
* @param <actual space>     space trying to be used
* @param <position>         current position
*
* @prop center              calculates the center position alignment
* @prop oppositeSide        calculates the opposite side position alignment
*
* @returns                  new position based on prop
*
*/
alias -l align {
  if ($prop == center) && ($calc(($1 - $2) / 2 + $3) > $3) return $v1
  elseif ($prop == oppositeSide) && ($calc($1 - $2 + $3) > $3) return $v1

  return $3
}

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

  if (%type == menu_text) {
    var %color = $hget(sbmoptions,colorhltext)

    if ($1 == $hget(sbmui,mouseInControl)) %color = $hget(sbmoptions,colorhoverhltext)
    if ($hget(sbmui,$+($1,_disabled))) %color = 13816530

    drawtext -nr @sbm %color %font %size %x %y $hget(sbmui,$+($1,_text))
  }
  if (%type == text) drawtext -nr @sbm $hget(sbmoptions,colornormal) %font %size %x %y $hget(sbmui,$+($1,_text))
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
* Sets the view of the game.
*
* @command /view
*
* @param <name>  the name of the view
*
*/
alias -l view {
  var %ww = $hget(sbmui,originalWidth)
  var %wh = $hget(sbmui,originalHeight)

  hadd sbm view $1

  hdel -w sbmui *_*
  hadd sbmui mouseInControl $null
  hadd sbmui focus $null
  hadd sbmui drawcursor $false

  if ($1 == menu) || ($1 == $null) {
    addControl logo logo 10 20 780 300 null null fixed

    var %text = Connect to game
    var %font = tahoma
    var %font = "segoe ui symbol"
    var %size = 55
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $calc((%ww - %w) / 2)
    var %y = 360

    addControl menu_text connect %x %y %w %h %font %size relative %text

    var %text = Create a game
    var %font = "segoe ui symbol"
    var %size = 55
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $calc((%ww - %w) / 2)
    var %y = 440

    addControl menu_text create %x %y %w %h %font %size relative %text

    var %text = Options
    var %font = impact
    var %font = "segoe ui symbol"
    var %size = 55
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $calc((%ww - %w) / 2)
    var %y = 520

    addControl menu_text options %x %y %w %h %font %size relative %text
  }
  elseif ($1 == connect) {
    hadd sbmui focus server

    var %text = $chr(8592) Back
    var %font = "segoe ui symbol"
    var %size = 20
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = 10
    var %y = 5

    addControl menu_text back %x %y %w %h %font %size static %text

    var %text = Enter the server information and a nickname
    var %font = "segoe ui symbol"
    var %size = 27
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%ww,%w,0).center
    var %y = 100

    addControl text title %x %y %w %h %font %size fixed %text

    var %text = Server Address
    var %font = "segoe ui symbol"
    var %size = 25
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = 180
    var %y = 270
    var %sx = %x
    var %sw = %w

    addControl text server_label %x %y %w %h %font %size absolute_top_right %text

    var %font = "segoe ui symbol"
    var %size = 15
    var %w = 160
    var %h = 25
    var %x = 380
    var %y = 272

    addControl edit server %x %y %w %h %font %size absolute_top_left

    hadd sbmui server_bg 8355711

    var %text = Server Port
    var %font = "segoe ui symbol"
    var %size = 25
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%sw,%w,%sx).oppositeSide
    var %y = 350

    addControl text port_label %x %y %w %h %font %size absolute_top_right %text

    var %font = "segoe ui symbol"
    var %size = 15
    var %w = 80
    var %h = 25
    var %x = 380
    var %y = 352

    addControl edit port %x %y %w %h %font %size absolute_top_left

    hadd sbmui port_bg 8355711

    var %text = Nickname
    var %font = "segoe ui symbol"
    var %size = 25
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%sw,%w,%sx).oppositeSide
    var %y = 430

    addControl text nick_label %x %y %w %h %font %size absolute_top_right %text

    var %font = "segoe ui symbol"
    var %size = 15
    var %w = 90
    var %h = 25
    var %x = 380
    var %y = 432

    addControl edit nick %x %y %w %h %font %size absolute_top_left $me

    hadd sbmui nick_cursor $len($me)

    if ($len($me)) hadd sbmui nick_sel 0 $len($me)

    hadd sbmui nick_bg 8355711

    var %text = Connect
    var %font = "segoe ui symbol"
    var %size = 28
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%ww,%w,0).center
    var %y = 500

    addControl menu_text connect %x %y %w %h %font %size absolute_top_left %text

    hadd sbmui connect_disabled $true
  }
  elseif ($1 == create) {
    hadd sbmui focus port

    var %text = $chr(8592) Back
    var %font = "segoe ui symbol"
    var %size = 20
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = 10
    var %y = 5

    addControl menu_text back %x %y %w %h %font %size static %text

    var %text = Enter the server port and a nickname
    var %font = "segoe ui symbol"
    var %size = 27
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%ww,%w,0).center
    var %y = 100

    addControl text title %x %y %w %h %font %size fixed %text

    var %text = Server Address
    var %font = "segoe ui symbol"
    var %size = 25
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = 180
    var %y = 270
    var %sx = %x
    var %sw = %w

    ;addControl text server_label %x %y %w %h %font %size absolute_top_right %text

    var %font = "segoe ui symbol"
    var %size = 15
    var %w = 160
    var %h = 25
    var %x = 380
    var %y = 272

    ;addControl edit server %x %y %w %h %font %size absolute_top_left

    var %text = Server Port
    var %font = "segoe ui symbol"
    var %size = 25
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%sw,%w,%sx).oppositeSide
    var %y = 350

    addControl text port_label %x %y %w %h %font %size absolute_top_right %text

    var %font = "segoe ui symbol"
    var %size = 15
    var %w = 80
    var %h = 25
    var %x = 380
    var %y = 352

    addControl edit port %x %y %w %h %font %size absolute_top_left

    hadd sbmui port_bg 8355711

    var %text = Nickname
    var %font = "segoe ui symbol"
    var %size = 25
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%sw,%w,%sx).oppositeSide
    var %y = 430

    addControl text nick_label %x %y %w %h %font %size absolute_top_right %text

    var %font = "segoe ui symbol"
    var %size = 15
    var %w = 90
    var %h = 25
    var %x = 380
    var %y = 432

    addControl edit nick %x %y %w %h %font %size absolute_top_left $me

    hadd sbmui nick_cursor $len($me)

    if ($len($me)) hadd sbmui nick_sel 0 $len($me)

    hadd sbmui nick_bg 8355711

    var %text = Start
    var %font = "segoe ui symbol"
    var %size = 28
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%ww,%w,0).center
    var %y = 500

    addControl menu_text connect %x %y %w %h %font %size absolute_top_left %text
    
  }
  elseif ($1 == options) {

  }

  hadd sbmui currentWidth 800
  hadd sbmui currentHeight 600
}

