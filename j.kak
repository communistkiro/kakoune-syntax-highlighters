# Detection
hook global BufCreate .*\.ijs %{
  set-option buffer filetype j
  try %{
    remove-highlighter global/wrap_-indent
    disable-auto-pairs
  }
}

# Initialization
hook -group j-highlight global WinSetOption filetype=j %{
  add-highlighter window/j ref j
  hook -once -always window WinSetOption filetype=.* %{
    remove-highlighter window/j
    try %{
      enable-auto-pairs
      add-highlighter global/wrap_-indent
    }
  }
  set-option buffer comment_line 'NB.'
  set-option buffer comment_block_begin "Note''"
  set-option buffer comment_block_end   '
)'
}

hook global WinSetOption filetype=j %{
  require-module j
  hook -once -always window WinSetOption filetype=.* %{ remove-hooks window j-.+ }
}

provide-module j %§
add-highlighter shared/j regions
add-highlighter shared/j/comment1 region (?<![\w'])NB\.(?![:.])         $  fill comment
add-highlighter shared/j/comment2 region (?<![\w'])Note\h*'[^)]*'[^)]*  \) fill comment

add-highlighter shared/j/code default-region group

# numerals/value: *10^, *e^, * pi^, real, rational, complex, polar, base-up-to-36 numbers (1-z) to decimal, possibly negative https://www.jsoftware.com/help/dictionary/dcons.htm
add-highlighter shared/j/code/ regex \b_?(?:(?:\d+\.?\d*|_?\d+\.?\d*r_?\d+\.?\d*)(?:e_?\d+|[xp]_?(?:\d*\.?\d+|\d+\.?\d*))?(?<!:)(?:(?:j|a[rd])_?(?:\d+\.?\d*|_?\d+\.?\d*r_?\d+\.?\d*)(?:e_?\d+|[xp]_?(?:\d*\.?\d+|\d+\.?\d*))?(?<!:))?|\d+b_?\w+)x?\b 0:rgb:9977cc

# nouns/value
add-highlighter shared/j/code/ regex (?:\b[xymn]\b|_?_(?![0-9])\.?|a[.:]) 0:rgb:ff7722

# variables/variables
add-highlighter shared/j/code/ regex \b(?:(?:[a-lo-twzA-Z]\w*|[xymnuv]\w+)(?![.:]))\b 0:rgb:bbddff

# nouns/strings, not definitions
add-highlighter shared/j/code/ regex "(?<!\d :)\h*'[^']*'" 0:rgb:9977cc

# conjunctions
add-highlighter shared/j/code/ regex (?:(?<=\h)\.|(?<![-+=<>_*%$~|,\;#/\\{"aiFpqsSuxZ\[\d]):[.:]?|"(?![.:])|`:?|\^:|@[.:]?|&\.?|&::?|(?<![_\^a]):[.:]?|\;\.(?:0|[+_][123])?|![.:]|F[.:][.:]?|[\[\]]\.) 0:rgb:88ee33

# verbs/functions
add-highlighter shared/j/code/ regex (?:\[(?![.:])|\](?!\.)|(?:\b[uv]\b|[=!])(?![.:])|[-<>+*%$|,#{][.:]?|\{::|[?^](?!:)\.?|[~}"i][.:]|[\\/]:|\[:|\;(?!\.)|[ACeEIjLopruv]\.|(?:[pqsxZu]|_?\d|_):|p\.\.) 0:rgb:ee3377

# adverbs
add-highlighter shared/j/code/ regex (?:~(?![.:])|[/\\](?!:)\.?|[/\\](?![.:])\.?|[fM]\.|\]:|\}(?![.:])|[a-zA-Z]\w*\h+b\.|b\.) 0:rgb:1177bb

# copulas
add-highlighter shared/j/code/ regex (?:=[.:])) 0:rgb:dddddd

# controls/keywords
add-highlighter shared/j/code/ regex (?:\{\{(?![.:])(?:\)[mdvacn]?)?|\}\}(?![.:])|(?:assert|break|continue|else(?:if)?|do|for(?:_[a-zA-Z]\w*)?|(?:goto|label)_[a-zA-Z]\w*|if|end|return|select|f?case|throw|try|catch[dt]?|whil(?:e|st))\.) 0:rgb:eeee88

# WIP
# declare-user-mode j




§
