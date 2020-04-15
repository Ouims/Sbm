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