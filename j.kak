# Detection
hook global BufCreate .*\.ijs %{
  set-option buffer filetype j
  try %{ execute-keys -draft :rmhl<space>global/wrap_-indent<ret>:disable-auto-pairs<ret> }
}

# Initialization
hook global WinSetOption filetype=j %{
  require-module j
  hook -once -always window WinSetOption filetype=.* %{ remove-hooks window j-.+ }
  try %{ execute-keys -draft :addhl<space>global/wrap_-indent<ret>:enable-auto-pairs<ret> }
}

hook -group j-highlight global WinSetOption filetype=j %{
  add-highlighter window/j ref j
  hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/j }
  try %{ execute-keys -draft :rmhl<space>global/wrap_-indent<ret>:disable-auto-pairs<ret> }
}

provide-module j %§
add-highlighter shared/j regions
add-highlighter shared/j/code default-region group
#add-highlighter shared/j/string  region "'" "[^']*?'" fill string NB. RIP stringed definitions
add-highlighter shared/j/comment1 region 'NB\.(?![:.])'              '$'  fill comment
add-highlighter shared/j/comment2 region "Note\h*'[^)]+'[^)]*?"      '\)' fill comment


add-highlighter shared/j/code/ regex \b_?(?:\d+\.?\d*|_?\d+\.?\d*r_?\d+\.?\d*)(?:e_?\d+|[xp]_?(?:\d*\.?\d+|\d+\.?\d*))?(?<!:)(?:(?:j|a[rd])_?(?:\d+\.?\d*|_?\d+\.?\d*r_?\d+\.?\d*)(?:e_?\d+|[xp]_?(?:\d*\.?\d+|\d+\.?\d*))?(?<!:))?\b \
    0:rgb:9977cc # numerals: *10^, *e^, * pi^, real, rational, complex, polar
add-highlighter shared/j/code/ regex \b(?:_?\d+b_?\w+)\b \
    0:rgb:9977cc # numerals: base-up-to-36 numbers (1-z) to decimal, possibly negative https://www.jsoftware.com/help/dictionary/dcons.htm
add-highlighter shared/j/code/ regex (?:\b[xymn]\b|_(?![0-9])\.?|a[.:]) \
    0:rgb:ff7722 # nouns
add-highlighter shared/j/code/ regex \b(?:(?:[a-lo-twzA-Z]\w*|[xymnuv]\w+)(?![.:]))\b \
    0:rgb:bbddff # variables
add-highlighter shared/j/code/ regex (?:(?<![-+=<>_*%^$~|,#{}"?AabCiFIjLopruv0-9])\.|"(?![.:])|`:?|\^:|@[.:]?|&\.?|&::?|(?<![-+=<>_*%$~|,\;#/\\{"aiFpqsSuxZ\[\d]):[.:]?|(?<![_\^\da]):[.:]?) \
    0:rgb:88ee33 # conjunctions
add-highlighter shared/j/code/ regex (?:\]|(?:\b[uv]\b|[=!])(?![.:])|[-<>+*%$|,#{][.:]?|\{::|[?^](?!:)\.?|[~}"i][.:]|[\;\[\\/]:?|[ACeEIjLopruv]\.|(?:[pqsxZu]|_?\d|_):|p\.\.|_?[0-3]?\d+\h+b\.) \
    0:rgb:ee3377 # verbs
add-highlighter shared/j/code/ regex (?:~(?![.:])|[/\\](?!:)\.?|[/\\](?![.:])\.?|[fM]\.|\]:|\}(?![.:])|[a-zA-Z]\w*\h+b\.) \
    0:rgb:1177bb # adverbs
add-highlighter shared/j/code/ regex (?:=[.:])) \
    0:rgb:eeeeee # copulas
add-highlighter shared/j/code/ regex (?:\{\{(?![.:])(?:\)[mdvacn]?)?|\}\}(?![.:])|(?:assert|break|continue|else(?:if)?|do|for(?:_i(?:jk)?)?|(?:goto|label)_lbl|if|end|return|select|f?case|throw|try|catch[dt]?|whil(?:e|st))\.) \
    0:rgb:eeee88 # controls
add-highlighter shared/j/code/ regex (?:\d|1(?:[358]|28))!:\d+ \
    0:rgb:55ffcc # foreigns


§
# j903 working completely
# TODO HOOK, FOOKS, MODIFIER TRAINS?
