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
    loadOptions

    window -pdBfCfo +l @sbm -1 -1 800 600

    .hmake sbm
    hmake sbmui 1
    
    hadd sbmui originalWidth 800
    hadd sbmui originalHeight 600
    hadd sbmui currentWidth 800
    hadd sbmui currentHeight 600

    view menu

    loop
  }
}