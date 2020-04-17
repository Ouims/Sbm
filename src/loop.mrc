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

  if ($hget(sbm,view) == connect) {
    hadd sbmui connect_disabled $true

    if ($iptype($hget(sbmui,server_text)) != $null) && ($regex($hget(sbmui,port_text),$sbmreg_validport)) && ($hget(sbmui,nick_text) != $null) {
      hadd sbmui connect_disabled $false
    }
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
      var %x = $iif($hget(sbmui,$+(%focus,_cursor)) > 0,$width($left($hget(sbmui,$+(%focus,_text)),$v1),$hget(sbmui,$+(%focus,_font)),$hget(sbmui,$+(%focus,_fontsize))),0)
      drawline -rn @sbm 0 1 $calc($hget(sbmui,$+(%focus,_x)) + 10 + %x) $calc($hget(sbmui,$+(%focus,_y)) + 6) $calc($hget(sbmui,$+(%focus,_x)) + 10 + %x) $calc($hget(sbmui,$+(%focus,_y)) + 21)
    }
  }

  drawdot @sbm

  .timersbm -ho 1 0 if (!$isalias(loop)) .timersbm -cho 1 0 $!timer(sbm).com $(|) else loop
}