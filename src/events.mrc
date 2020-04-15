on *:close:@sbm: {
  hfree sbm
  hfree sbmui
  .timersbm off   
}

menu @sbm {
  mouse: {
    hadd sbmui active $null

    noop $hfind(sbmui,*_type,0,w,hadd sbmui active $iif($cooInControl($left($1,-5),$mouse.x,$mouse.y),$left($1,-5),$hget(sbmui,active)))
  }
  sclick: {
    if ($hget(sbmui,active)) echo -a sclicked $v1
  }
}