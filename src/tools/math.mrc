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
