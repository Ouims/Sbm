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
* @global
*
*/
alias -l max {
  if ($1 > $2) return $1
  return $2
}

/**
*
* Bundles all mirc files under a folder into a single file.
*
* @command /bundle
*
* @param <source> The source folder.
* @param <destination> The destination folder.
* @param <name> The name of the file (myProject.mrc).
* @param [depth] The depth, defaults to 1, of searching within the specified folder.
*
* @global
*
*/
alias bundle {
  tokenize 13 $getParameters($1-)

  var %dir = $noqt($2)
  var %depth = 1

  if ($right($noqt($2),1) != $chr(92)) var %dir = $+($noqt($2),$v2)

  if ($4 != $null) var %depth = $4

  var %file = $+(%dir,$3)

  if (!$exists(%file)) write $qt(%file) $crlf

  write -c $qt(%file)

  noop $findfile($1,*.mrc,0,%depth,noop $addFile(%file,$1-))

  echo $color(info) -es * Bundling process of %file has completed
}

/**
*
* Appends a destination file to a source file.
*
* @identifier $addFile
*
* @param <file> the destination file
* @param <file> the source file
*
*/
alias -l addFile {
  .copy -a $qt($2) $qt($1)
  write $qt($1) $crlf

  return $null
}

/**
*
* Removes unnecessary lines from source file, such as empty lines, multi-line comments, and single line comments.
*
* @command /cleanCodeFile
*
* @param <source>  the source/code file
*
* @global
*
*/
alias cleanCodeFile {
  var %file = $qt($1-)

  hmake cleanCodeFileLines 1

  set %ccfl_in_multi_line_comment $false

  filter -fkng %file addLinesToCleanTable /^\x20*(\/\*.*|\*\/|;.*|)$/

  unset %ccfl_in_multi_line_comment

  noop $hfind(cleanCodeFileLines,*,0,w,cleanFile %file $hget(cleanCodeFileLines,$1))

  hfree cleanCodeFileLines

  echo $color(info) -es * Cleaning of %file has completed
}

/**
*
* Adds lines to the hash table depending on previous lines.
*
* @identifier $addLinesToCleanTable
*
* @param <line [text]>  the line number and text in the line
*
*/
alias -l addLinesToCleanTable {
  tokenize 32 $1-

  var %text = $2-
  var %line = $calc($hget(cleanCodeFileLines,0).item + 1)

  if (!%ccfl_in_multi_line_comment) {
    if ($left(%text,2) == $+($chr(47),$chr(42))) {
      hadd cleanCodeFileLines %line $1

      set %ccfl_in_multi_line_comment $true
    }
    elseif (%text == $null) || ($left(%text,1) == $chr(59)) hadd cleanCodeFileLines %line $1
  }
  else {
    if ($left(%text,2) == $+($chr(42),$chr(47))) {
      dec %line

      hadd cleanCodeFileLines %line $hget(cleanCodeFileLines,%line) $1

      set %ccfl_in_multi_line_comment $false
    }
  }
}

/**
*
* Removes lines from file based on data from cleanCodeFileLines hash table
*
* @command /cleanFile
*
* @param <file>  the file
* @param <lines> the lines
*
*/
alias -l cleanFile {
  tokenize 13 $getParameters($1-)

  if ($0 == 2) write $+(-dl,$2) $1
  else {
    var %lines = $calc($3 - $2 + 1)

    while (%lines) {
      write $+(-dl,$2) $1

      dec %lines
    }
  }
}





/*
The previous was all generic stuff, the following is sbm specific.
*/

/**
*
* Checks for src folder changes.
*
* @event appactive
*
*/
on *:appactive: {
  if ($appactive) {
    var %last_modification = %sbm_src_modification

    if (!%sbm_src_modification) {
      set %sbm_src_modification 0
      %last_modification = 0
    }

    noop $findfile($scriptdirsrc,*.mrc,0,2,var %last_modification = $max($file($1).mtime,%last_modification))

    if (%last_modification != %sbm_src_modification) {
      set %sbm_src_modification $v1

      bundle $qt($scriptdirsrc) $qt($scriptdirdist) sbm.mrc 2
      
      .reload -rs $qt($scriptdirdist\sbm.mrc)
    }
  }
}

/**
*
* Creates a release version of the project.
*
* @command /releaseSBM
*
* @global
*
*/
alias releaseSBM {
  bundle $qt($scriptdirsrc) $qt($scriptdirdist) sbm.mrc 2

  if (!$isdir($scriptdirdist\assets\)) .mkdir $qt($scriptdirdist\assets\)

  noop $findfile($scriptdirsrc\assets,*,0,2,.copy -o $qt($1) $qt($+($scriptdirdist\assets\,$nopath($1))))

  cleanCodeFile $qt($scriptdirdist\sbm.mrc)
      
  .reload -rs $qt($scriptdirdist\sbm.mrc)
}