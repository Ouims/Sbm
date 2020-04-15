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
