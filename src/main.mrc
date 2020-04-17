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

alias sbmreg_validserver return ^(?:(?:25[0-5]|2[0-4]\d|1?\d\d?)(?:\.(?!$)|$)){4}|^(?:\w+\.)+\w+$
alias sbmreg_validport return ^(?:[1-9]|\d{1,4}|[1-5]\d{4}|6(?:[0-4]\d{3}|5(?:[0-4]\d{2}|5(?:[0-2]\d|3[0-5]))))$
