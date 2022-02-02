# Detection
hook global BufCreate .*\.ijs %{
  set-option buffer filetype j
  disable-auto-pairs
}

# Initialization
hook global WinSetOption filetype=j %{
  require-module j
  hook -once -always window WinSetOption filetype=.* %{ remove-hooks window j-.+ }
  enable-auto-pairs
}

hook -group j-highlight global WinSetOption filetype=j %{
  add-highlighter window/j ref j
  hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/j }
  disable-auto-pairs
}

provide-module j %§
add-highlighter shared/j regions
#add-highlighter shared/j/string  region "'" "[^']*?'" fill string
add-highlighter shared/j/comment1 region 'NB\.'                  '$' fill comment
add-highlighter shared/j/comment2 region "Note\h*'[^)]+'[^)]*?" '\)' fill comment

add-highlighter shared/j/code default-region group
#### regex-heavy
add-highlighter shared/j/code/ regex (?:\b[xymn]\b|_\.?|a[.:]) \
    0:rgb:ff7722 # noun 
add-highlighter shared/j/code/ regex \b_?(?:\d+\.?\d*|_?\d+\.?\d*r_?\d+\.?\d*)(?:e_?\d+|[xp]_?(?:\d*\.?\d+|\d+\.?\d*))?(?<!:)(?:(?:j|a[rd])_?(?:\d+\.?\d*|_?\d+\.?\d*r_?\d+\.?\d*)(?:e_?\d+|[xp]_?(?:\d*\.?\d+|\d+\.?\d*))?(?<!:))?\b \
    0:rgb:9966cc # numerals: *10^, *e^, * pi^, real, rational, complex, polar
add-highlighter shared/j/code/ regex \b(?:\d+b_?\w+)\b \
    0:rgb:9966cc # numerals: arbitrary-base numbers to decimal
add-highlighter shared/j/code/ regex \b(?:(?:[a-lo-twzA-Z]\w*|[xymnuv]\w+)(?![.:]))\b \
    0:rgb:bbddff # variables
add-highlighter shared/j/code/ regex (?:(?<![-+=<>_*%^$~|,#{}"?AabCiFIjLopruv.])\.(?!\.)|"(?![.:])|`:?|\^:|@[.:]?|&\.?|&::?|(?<![-+=<>_*%$~|,\;#/\\{"aiFpqsSuxZ\[\d]):[.:]?|(?<!_\^\d):[.:]?) \
    0:rgb:66dd44 # conjunction
add-highlighter shared/j/code/ regex (?:\]|(?:\b[uv]\b|[=!])(?![.:])|[-<>+*%$|,#{][.:]?|\{::|[?^](?<!:)\.?|[~}"i][.:]|[\;\[]:?|[ACeEIjLopruv]\.|(?:[pqsxZu]|_?\d|_):|p\.\.|_?[0-3]?\d+\h+b\.) \
    0:rgb:f92672 # verb ff2299
add-highlighter shared/j/code/ regex (?:~(?![.:])|[/\\](?!:)\.?|[/\\]\.?|[fM]\.|\]:|\}(?![.:])|[a-zA-Z]\w*\h+b\.) \
    0:rgb:1177bb # adverb 22ff44
add-highlighter shared/j/code/ regex (?:=[.:]|(?:(?:\{\{(?:\)[mdvacn]?)?|\}\})(?![.:]))) \
    0:rgb:ffff44 # copula eeee22
add-highlighter shared/j/code/ regex \b(?:(?:assert|break|continue|else(?:if)?|do|for(?:_i(?:jk)?)?|(?:goto|label)_lbl|if|end|return|select|f?case|throw|try|catch[dt]?|whil(?:e|st))\.) \
    0:rgb:ffccff # control
add-highlighter shared/j/code/ regex (?:\d|1(?:[358]|28))!:\d+  \
    0:rgb:55ffcc # foreigns


# TODO HOOKS AND FORKS
§
