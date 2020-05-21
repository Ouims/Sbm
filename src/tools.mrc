/**
*
* Tokenizes a string based on a delimiter or quotes just as mIRC does for native commands.
*
* @identifier $sbmgetparams
*
* @param <parameters>       String containing your parameters
* @param [delimiter=\x20]   The delimiter for your parameters
*
* @returns  String tokenized into $cr based on a specified delimiter or double quotes.
*
* @global
*
*/
alias sbmgetparams {
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
* Align helper.
*
* @identifier $sbmalign
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
* @global
*
*/
alias sbmalign {
  if ($prop == center) && ($calc(($1 - $2) / 2 + $3) > $3) return $v1
  elseif ($prop == oppositeSide) && ($calc($1 - $2 + $3) > $3) return $v1

  return $3
}

alias Lum tokenize 44 $rgb($1) | return $calc(0.2126 * $brightness($1) + 0.7152 * $brightness($2) + 0.0722* $brightness($3))
alias brightness var %res = $1 / 255 | return $iif(%res <= 0.03928, $calc(%res / 12.92), $calc((( %res + 0.055) / 1.055) ^ 2.4))
alias contrast tokenize 32 $sorttok($Lum($1) $Lum($2),32,nr) | return $calc( ($1 + 0.05) / ($2 + 0.05) )
