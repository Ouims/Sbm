alias scaleTest {
  window -pdBfCfo +l @sbm -1 -1 800 600

  hmake sbmui 1

  var %ww = $window(@sbm).dw
  var %wh = $window(@sbm).dh

  hadd sbmui originalWidth %ww
  hadd sbmui originalHeight %wh
  hadd sbmui currentWidth %ww
  hadd sbmui currentHeight %wh

  screen $1

  drawcontrols
}

alias screen {
  var %ww = $hget(sbmui,originalWidth)
  var %wh = $hget(sbmui,originalHeight)

  hdel -w sbmui *_*

  if ($1 == init) || ($1 == $null) {
    addControl logo logo 10 20 780 300 null null fixed

    var %text = Connect to game
    var %font = tahoma
    var %font = "segoe ui symbol"
    var %size = 55
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $calc((%ww - %w) / 2)
    var %y = 360

    addControl text connect %x %y %w %h %font %size relative %text

    var %text = Create a game
    var %font = "segoe ui symbol"
    var %size = 55
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $calc((%ww - %w) / 2)
    var %y = 440

    addControl text create %x %y %w %h %font %size relative %text

    var %text = Options
    var %font = impact
    var %font = "segoe ui symbol"
    var %size = 55
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $calc((%ww - %w) / 2)
    var %y = 520

    addControl text options %x %y %w %h %font %size relative %text
  }
  elseif ($1 == connect) {
    var %text = $chr(8592) Back
    var %font = "segoe ui symbol"
    var %size = 20
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = 10
    var %y = 5

    addControl text back %x %y %w %h %font %size static %text

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

    addControl edit nick %x %y %w %h %font %size absolute_top_left

    var %text = Connect
    var %font = "segoe ui symbol"
    var %size = 28
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%ww,%w,0).center
    var %y = 500

    addControl text connect %x %y %w %h %font %size absolute_top_left %text
  }
  elseif ($1 == create) {
    var %text = $chr(8592) Back
    var %font = "segoe ui symbol"
    var %size = 20
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = 10
    var %y = 5

    addControl text back %x %y %w %h %font %size static %text

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

    addControl edit nick %x %y %w %h %font %size absolute_top_left

    var %text = Start
    var %font = "segoe ui symbol"
    var %size = 28
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%ww,%w,0).center
    var %y = 500

    addControl text connect %x %y %w %h %font %size absolute_top_left %text
  }
  elseif ($1 == options) {

  }
}

alias drawcontrols {
  if ($window(@sbm)) {
    var %ow = 800
    var %oh = 600
    var %ww = $window(@sbm).dw
    var %wh = $window(@sbm).dh

    var %scale = $calc(1 / $max($calc(%ow / %ww),$calc(%oh / %wh)))

    drawrect -nrf @sbm $rgb(255,255,255) 1 0 0 %ww %wh
    
    if (%ww != $hget(sbmui,currentWidth)) || (%wh != $hget(sbmui,currentHeight)) {
      hadd sbmui resize $true

      hadd sbmui currentWidth %ww
      hadd sbmui currentHeight %wh
    }

    noop $hfind(sbmui,*_type,0,w,drawControl $left($1,-5))

    hadd sbmui resize $false

    drawdot @sbm

    .timertest -ho 1 0 drawcontrols
  }
  else hfree sbmui
}