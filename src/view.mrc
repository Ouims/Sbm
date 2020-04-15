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
}