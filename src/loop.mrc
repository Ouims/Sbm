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

  drawdot @sbm

  .timersbm -ho 1 0 if (!$isalias(loop)) .timersbm -cho 1 0 $!timer(sbm).com $(|) else loop
}