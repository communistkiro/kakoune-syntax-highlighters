hook global BufCreate .*\.(ijs) %{
  set-option buffer filetype j;
  try %{ tab-length 3; };
  try %{ remove-highlighter global/wrap_-indent; };
  try %{ disable-auto-pairs; };
  set-option buffer matching_pairs ( );
}

hook -group j-highlight global WinSetOption filetype=j %{
  add-highlighter -override window/j ref j;
  hook -once -always buffer BufClose .* %{
    remove-highlighter window/j;
    try %{ enable-auto-pairs; };
    try %{ add-highlighter -override global/wrap_-indent; };
  };
  set-option buffer comment_line 'NB.';
#   set-option buffer comment_block_begin "Note''";
#   set-option buffer comment_block_end ';
# )'
}

hook global WinSetOption filetype=j %{
  require-module j;
  hook window ModeChange pop:insert:.* -group j-trim-indent j-trim-indent
  # hook window InsertChar \n -group j-insert j-insert-on-new-line
  hook window InsertChar \n -group j-indent j-indent-on-new-line
  hook -once -always window WinSetOption filetype=.* %{ remove-hooks window j-.+; };
}

provide-module j %§
  add-highlighter -override shared/j regions;
  add-highlighter -override shared/j/comment1 region (?<![\w'])NB\.(?![:.])         $  fill comment;
  # add-highlighter -override shared/j/comment2 region (?<![\w'])Note\h*'[^)]*'[^)]*  \) fill comment;

  add-highlighter -override shared/j/code default-region group;


  # CONSTANT NUMERAL/VALUE: *10^, *e^, * pi^, real, rational, complex, polar, base-up-to-36 numbers (1-z) to decimal, possibly negative https://www.jsoftware.com/help/dictionary/dcons.htm
  add-highlighter -override shared/j/code/ regex \b_?(?:(?:\d+\.?\d*|_?\d+\.?\d*r_?\d+\.?\d*)(?:e_?\d+|[xp]_?(?:\d*\.?\d+|\d+\.?\d*))?(?<!:)(?:(?:j|a[rd])_?(?:\d+\.?\d*|_?\d+\.?\d*r_?\d+\.?\d*)(?:e_?\d+|[xp]_?(?:\d*\.?\d+|\d+\.?\d*))?(?<!:))?|\d+b_?\w+)x?\b 0:rgb:9977ee;
  # NOUN
  add-highlighter -override shared/j/code/ regex (?:\b[xymn]\b|_?_(?![0-9])\.?|a[.:]) 0:rgb:ee7733;
  # # IDENTIFIERS/VARIABLES
  # add-highlighter -override shared/j/code/ regex \b(?:(?:[a-lo-twzA-Z]\w*|[xymnuv]\w+)(?![.:]))\b 0:rgb:bbddff;
  # CONJUNCTION
  add-highlighter -override shared/j/code/ regex (?:(?<=\h)\.|(?<![-+=<>_*%$~|,\;#/\\{"aiFpqsSuxZ\[\d]):[.:]?|"(?![.:])|`:?|\^:|@[.:]?|&\.?|&::?|(?<![_\^a]):[.:]?|![.:]|F[.:][.:]?|[\[\]]\.|\;\.) 0:rgb:77ee33;
  # VERB
  add-highlighter -override shared/j/code/ regex (?:\[(?![.:])|\](?!\.)|(?:\b[uv]\b|[=!])(?![.:])|[-<>+*%$|,#{][.:]?|\{::|[?^](?!:)\.?|[~}"i][.:]|[\\/]:|\[:|\;(?!\.)|[ACeEIjLopruv]\.|(?:[pqsxZu]|_?\d|_):|p\.\.) 0:rgb:ee3377;
  # HOOK
  add-highlighter -override shared/j/code/ regex (?:\h*(\[(?![.:])|\](?!\.)|(?:\b[uv]\b|[=!])(?![.:])|[-<>+*%$|,#{][.:]?|\{::|[?^](?!:)\.?|[~}"i][.:]|[\\/]:|\[:|\;(?!\.)|[ACeEIjLopruv]\.|(?:[pqsxZu]|_?\d|_):|p\.\.)\h*){2} 0:+ai
  # FORK
  add-highlighter -override shared/j/code/ regex (?:\h*(\[(?![.:])|\](?!\.)|(?:\b[uv]\b|[=!])(?![.:])|[-<>+*%$|,#{][.:]?|\{::|[?^](?!:)\.?|[~}"i][.:]|[\\/]:|\[:|\;(?!\.)|[ACeEIjLopruv]\.|(?:[pqsxZu]|_?\d|_):|p\.\.)\h*){3} 0:+ab
  # ADVERB
  add-highlighter -override shared/j/code/ regex (?:~(?![.:])|[/\\](?!:)\.?|[/\\](?![.:])\.?|/\.\.|[fM]\.|\]:|\}(?![.:])|[a-zA-Z]\w*\h+b\.|b\.|\;\.(?:0|[+_]?[123])) 0:rgb:1177bb;
  # COPULA
  add-highlighter -override shared/j/code/ regex (?:=[.:])) 0:rgb:808080;
  # CONTROL
  add-highlighter -override shared/j/code/ regex (?:\{\{(?![.:])(?:\)[mdvacn]?)?|\}\}(?![.:])|\b(?:assert|break|continue|else(?:if)?|do|for(?:_[a-zA-Z]\w*)?|(?:goto|label)_[a-zA-Z]\w*|if|end|return|select|f?case|throw|try|catch[dt]?|whil(?:e|st))\.) 0:rgb:eeee77;
  # # NOUN, STRING, NOT DEFINITION
  # add-highlighter -override shared/j/code/ regex (?<!\d\h:)\h*('[^\n']*') 1:rgb:9977cc;
  # NOUN, STRING
  add-highlighter -override shared/j/code/ regex (?:'[^\n']*') 0:rgb:9977ee;


  define-command -hidden j-trim-indent %{ try %{ execute-keys -draft -itersel x s \h+$ <ret> d } }
  define-command -hidden j-indent-on-new-line %[
    evaluate-commands -draft -itersel %[
      execute-keys <semicolon>
      try %<
        # if previous line is part of a comment, do nothing
        # execute-keys -draft <a-?>/\*<ret> <a-K>^\h*\bNB\.<ret> # ????????
        fail # fixme
      > catch %<
        # else if previous line closed a paren (possibly followed by words and a comment),
        # copy indent of the opening paren line
        execute-keys -draft kx 1s(\))(.+)*\h*(?://[^\n]+)?\n\z<ret> m<a-semicolon>J <a-S> 1<a-&> # fixme
      > catch %<
        # else indent new lines with the same level as the previous one
        execute-keys -draft K <a-&>
      >
      # filter previous line
      try %< execute-keys -draft k x <a-k>^\h+$<ret> Hd >
      # # indent after lines ending with with {
      # try %[ execute-keys -draft k x <a-k> \{$ <ret> j <a-gt> ]
      # # deindent closing brace when after cursor
      # try %[ execute-keys -draft x <a-k> ^\h*\} <ret> gh / \} <ret> m <a-S> 1<a-&> ]
    ]
  ]
§
