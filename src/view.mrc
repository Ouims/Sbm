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

    if ($hget(sbm,view) == lobby) {
      sockclose sbmclient
      hdel -w sbm nick*
      hdel sbm owner
      hdel -w sbm player?
      hdel sbm scroll
      hfree -w sbmchat
      if ($isalias(sbmserv)) sbmserv stop
    }
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

    addControl edit nick %x %y %w %h %font %size absolute_top_left $me

    hadd sbmui nick_cursor $len($me)

    if ($len($me)) hadd sbmui nick_sel 0 $len($me)

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
    hadd sbmui server_text 127.0.0.1

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

    addControl edit port %x %y %w %h %font %size absolute_top_left 8000

    hadd sbmui port_cursor 4
    hadd sbmui port_sel 0 4

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

    var %text = Start
    var %font = "segoe ui symbol"
    var %size = 28
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = $align(%ww,%w,0).center
    var %y = 500

    addControl menu_text connect %x %y %w %h %font %size absolute_top_left %text

    hadd sbmui connect_disabled $true
  }
  elseif ($1 == options) {

  }
  elseif ($1 == lobby) {
    hadd sbmui focus chat
    var %text = $chr(8592) Leave
    var %font = "segoe ui symbol"
    var %size = 20
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = 10
    var %y = 5

    addControl menu_text back %x %y %w %h %font %size static %text

    var %text = Start
    var %font = "segoe ui symbol"
    var %size = 35
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = 350
    var %y = 20

    addControl text start %x %y %w %h %font %size fixed %text
    
    var %text = Waiting for the game to start...
    var %font = "segoe ui symbol"
    var %size = 25
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = 220
    var %y = 100

    addControl text message %x %y %w %h %font %size fixed %text

    addControl wrapper menu 0 0 800 400 null null static
    addControl sprite white 80 200 32 32 null null fixed 16777215 640 108 16 16 $qt($scriptdirassets\sbm.png)
    addControl sprite black 280 200 32 32 null null fixed 16777215 656 108 16 16 $qt($scriptdirassets\sbm.png)
    addControl sprite orange 480 200 32 32 null null fixed 16777215 672 108 16 16 $qt($scriptdirassets\sbm.png)
    addControl sprite blue 680 200 32 32 null null fixed 16777215 688 108 16 16 $qt($scriptdirassets\sbm.png)

    var %text = Play
    var %font = "segoe ui symbol"
    var %size = 14
    var %w = $width(%text,%font,%size)
    var %h = $height(%text,%font,%size)
    var %x = 81
    var %y = 235

    addControl play_text select_white %x %y %w %h %font %size fixed %text
    addControl play_text select_black 281 %y %w %h %font %size fixed %text
    addControl play_text select_orange 481 %y %w %h %font %size fixed %text
    addControl play_text select_blue 681 %y %w %h %font %size fixed %text

    hadd sbmui menu_hidden $true
    hadd sbmui start_hidden $true
    hadd sbmui start_parent menu
    hadd sbmui message_parent menu
    hadd sbmui white_parent menu
    hadd sbmui black_parent menu
    hadd sbmui orange_parent menu
    hadd sbmui blue_parent menu
    hadd sbmui select_white_parent menu
    hadd sbmui select_black_parent menu
    hadd sbmui select_orange_parent menu
    hadd sbmui select_blue_parent menu

    addcontrol chat display 0 400 785 160 "segoe ui symbol" 11 static
    addcontrol elevator up 785 400 15 20 "segoe ui symbol" 14 static $chr(9650)
    addcontrol scroll scroll 785 425 15 115 "segoe ui symbol" 14 static
    addcontrol elevator down 785 540 15 20 "segoe ui symbol" 14 static $chr(9660)
    addControl edit chat 5 570 760 25 15 15 "segoe ui symbol" 15 static

    hadd sbmui display_current 0
  }

  if ($hget(sbm,view) == lobby) {
    hfree -w sbmchat
    hdel -w sbm player?
  }

  hadd sbm view $1

  hadd sbmui currentWidth 800
  hadd sbmui currentHeight 600
}