hook global BufCreate .*\.((z)?sh(rc|_profile)?|profile) %{
    set-option buffer filetype zsh
}

hook global WinSetOption filetype=zsh %{
    require-module zsh
    set-option window static_words %opt{zsh_static_words}

    hook window ModeChange pop:insert:.* -group zsh-trim-indent zsh-trim-indent
    hook window InsertChar \n -group zsh-insert zsh-insert-on-new-line
    hook window InsertChar \n -group zsh-indent zsh-indent-on-new-line
    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window zsh-.+ }
}

hook -group zsh-highlight global WinSetOption filetype=zsh %{
    add-highlighter window/zsh ref zsh
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/zsh }
}

provide-module zsh %§

add-highlighter shared/zsh regions
add-highlighter shared/zsh/code default-region group
add-highlighter shared/zsh/arithmetic    region -recurse \(.*?\( (\$|(?<=for)\h*)\(\( \)\) group
add-highlighter shared/zsh/double_string region %{(?<!\\)(?:\\\\)*\K"} %{(?<!\\)(?:\\\\)*"} group
add-highlighter shared/zsh/single_string region %{(?<!\\)(?:\\\\)*\K'} \' fill string
add-highlighter shared/zsh/expansion     region -recurse (?<!\\)(?:\\\\)*\K\$\{ (?<!\\)(?:\\\\)*\K\$\{ \}|\n fill value
add-highlighter shared/zsh/comment       region (?<!\\)(?:\\\\)*(?:^|\h)\K# '$' fill comment
add-highlighter shared/zsh/heredoc       region -match-capture '<<-?\h*''?(\w+)''?' '^\t*(\w+)$' fill string
add-highlighter shared/zsh/herestring    region -match-capture <<<\h*(['"]?)\S+ (['"]?) fill string
add-highlighter shared/zsh/flags         region -recurse (?<=\$\{)\( (?<=\$\{)\( \) group # globbing flags kind of too
add-highlighter shared/zsh/arithmetic/expansion ref zsh/double_string/expansion
add-highlighter shared/zsh/double_string/fill fill string

evaluate-commands %sh@
    printf %s\\n 'declare-option str-list zsh_static_words if export declare function else float end do typeset then integer \{ select readonly coproc \} ! case \[\[ repeat done for while time esac until local fi nocorrect foreach elif unset rehash popd ulimit local jobs disable \[ compfiles printf autoload noglob pushln zle readonly exit false times sysopen sched setopt getln builtin let bg zstat which unhash pwd zparseopts logout disown type source eval comptags compdescribe compctl zmodload sysseek syswrite zregexparse history return exec compadd emulate chdir ttyctl test comparguments pushd functions float zstyle print declare comptry alias shift \. bindkey typeset true hash compset cd compvalues getopts compgroups export enable limit echotc echo wait dirs syserror unsetopt read integer bye echoti compquote unfunction fc vared unalias kill compcall where fg zformat suspend unlimit break set continue command zcompile whence umask sysread trap zsystem log private';
    printf %s\\n 'add-highlighter shared/zsh/code/ regex (?<!-)\b(if|export|declare|function|else|float|end|do|typeset|then|integer|\{|select|readonly|coproc|\}|!|case|\[\[|repeat|done|for|while|time|esac|until|local|fi|nocorrect|foreach|elif)\b(?!-) 0:keyword';
    printf %s\\n 'add-highlighter shared/zsh/code/builtin regex (?<!-)\b(unset|rehash|popd|ulimit|local|jobs|disable|\[|compfiles|printf|autoload|noglob|pushln|zle|readonly|exit|false|times|sysopen|sched|setopt|getln|builtin|let|bg|zstat|which|unhash|pwd|zparseopts|logout|disown|type|source|eval|comptags|compdescribe|compctl|zmodload|sysseek|syswrite|zregexparse|history|return|exec|compadd|emulate|chdir|ttyctl|test|comparguments|pushd|functions|float|zstyle|print|declare|comptry|alias|shift|\.|bindkey|typeset|true|hash|compset|cd|compvalues|getopts|compgroups|export|enable|limit|echotc|echo|wait|dirs|syserror|unsetopt|read|integer|bye|echoti|compquote|unfunction|fc|vared|unalias|kill|compcall|where|fg|zformat|suspend|unlimit|break|set|continue|command|zcompile|whence|umask|sysread|trap|zsystem|log|private)\b(?!-) 0:builtin';
@

add-highlighter shared/zsh/code/operators          regex [\[\]\(\)&|]{1,2}                                  0:operator
add-highlighter shared/zsh/code/variable           regex ((?<![-:])\b\w+)=                                  1:variable
add-highlighter shared/zsh/code/alias              regex \balias(\h+[-+]\w)*\h+([\w-.]+)=                   2:variable
add-highlighter shared/zsh/code/function           regex ^\h*(\S+|\(\))\h*\(\)                              1:function
add-highlighter shared/zsh/code/subshell           regex \s((\()\s+.*\s+(\))|(\{)\s+.*\s+(\}))\s            2:operator 3:operator
add-highlighter shared/zsh/code/range              regex (\{\S+\.\.\S+(?:\.\.\S+)?\})                       0:operator
add-highlighter shared/zsh/code/unscoped_expansion regex (?<!\\)(?:\\\\)*\K\$(\w+|#|@|\?|\$|!|-|\*)         0:value
add-highlighter shared/zsh/double_string/expansion regex (?<!\\)(?:\\\\)*\K\$(\w+|#|@|\?|\$|!|-|\*|\{.+?\}) 0:value
add-highlighter shared/zsh/redirections            regex (?:<{1,2}|>{1,2})[&|]? 0:operator


# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden zsh-trim-indent %{
    # remove trailing white spaces
    try %{ execute-keys -draft -itersel <a-x> s \h+$ <ret> d }
}

# This is at best an approximation, since shell syntax is very complex.
# Also note that this targets plain sh syntax, not bash - bash adds a whole
# other level of complexity. If your bash code is fairly portable this will
# probably work.
#
# Of necessity, this is also fairly opinionated about indentation styles.
# Doing it "properly" would require far more context awareness than we can
# bring to this kind of thing.
define-command -hidden zsh-insert-on-new-line %[
    evaluate-commands -draft -itersel %[
        # copy '#' comment prefix and following white spaces
        try %{ execute-keys -draft k <a-x> s ^\h*\K#\h* <ret> y gh j P }
    ]
]

# Use custom object matching to copy indentation for the various logical
# blocks.
#
# Note that we're using a weird non-ascii character instead of [ or { here
# because the '[' and '{' characters need to be available for the commands.
define-command -hidden zsh-indent-on-new-line %¶
    evaluate-commands -draft -itersel %@
        # preserve previous line indent
        try %{ execute-keys -draft <semicolon> K <a-&> }
        # filter previous line
        try %{ execute-keys -draft k : zsh-trim-indent <ret> }

        # Indent loop syntax, e.g.:
        # for foo in bar; do
        #       things
        # done
        #
        # or:
        #
        # while foo; do
        #       things
        # done
        #
        # or equivalently:
        #
        # while foo
        # do
        #       things
        # done
        #
        # indent after do
        try %{ execute-keys -draft <space> k <a-x> <a-k> \bdo$ <ret> j <a-gt> }
        # copy the indentation of the matching for/when - matching on the do
        # statement, so we don't need to duplicate this for the two loop
        # structures.
        try %{ execute-keys -draft <space> k <a-x> <a-k> \bdone$ <ret> gh [c\bdo\b,\bdone\b <ret> <a-x> <a-S> 1<a-&> <space> j K <a-&> }

        # Indent if/then/else syntax, e.g.:
        # if [ $foo = $bar ]; then
        #       things
        # else
        #       other_things
        # fi
        #
        # or equivalently:
        # if [ $foo = $bar ]
        # then
        #       things
        # else
        #       other_things
        # fi
        #
        # indent after then
        try %{ execute-keys -draft <space> k <a-x> <a-k> \bthen$ <ret> j <a-gt> }
        # copy the indentation of the matching if
        try %{ execute-keys -draft <space> k <a-x> <a-k> \bfi$ <ret> gh [c\bif\b,\bfi\b <ret> <a-x> <a-S> 1<a-&> <space> j K <a-&> }
        # copy the indentation of the matching if, and then re-indent afterwards
        try %{ execute-keys -draft <space> k <a-x> <a-k> \belse$ <ret> gh [c\bif\b,\bfi\b <ret> <a-x> <a-S> 1<a-&> <space> j K <a-&> j <a-gt> }

        # Indent case syntax, e.g.:
        # case "$foo" in
        #       bar) thing1;;
        #       baz)
        #               things
        #               ;;
        #       *)
        #               default_things
        #               ;;
        # esac
        #
        # or equivalently:
        # case "$foo"
        # in
        #       bar) thing1;;
        # esac
        #
        # indent after in
        try %{ execute-keys -draft <space> k <a-x> <a-k> \bin$ <ret> j <a-gt> }
        # copy the indentation of the matching case
        try %{ execute-keys -draft <space> k <a-x> <a-k> \besac$ <ret> gh [c\bcase\b,\besac\b <ret> <a-x> <a-S> 1<a-&> <space> j K <a-&> }
        # indent after )
        try %{ execute-keys -draft <space> k <a-x> <a-k> ^\s*\(?[^(]+[^)]\)$ <ret> j <a-gt> }
        # deindent after ;;
        try %{ execute-keys -draft <space> k <a-x> <a-k> ^\s*\;\;$ <ret> j <a-lt> }

        # Indent compound commands as logical blocks, e.g.:
        # {
        #       thing1
        #       thing2
        # }
        #
        # or in a function definition:
        # foo () {
        #       thing1
        #       thing2
        # }
        #
        # We don't handle () delimited compond commands - these are technically very
        # similar, but the use cases are quite different and much less common.
        #
        # Note that in this context the '{' and '}' characters are reserved
        # words, and hence must be surrounded by a token separator - typically
        # white space (including a newline), though technically it can also be
        # ';'. Only vertical white space makes sense in this context, though,
        # since the syntax denotes a logical block, not a simple compound command.
        try %= execute-keys -draft <space> k <a-x> <a-k> (\s|^)\{$ <ret> j <a-gt> =
        # deindent closing }
        try %= execute-keys -draft <space> k <a-x> <a-k> ^\s*\}$ <ret> <a-lt> j K <a-&> =
        # deindent closing } when after cursor
        try %= execute-keys -draft <a-x> <a-k> ^\h*\} <ret> gh / \} <ret> m <a-S> 1<a-&> =

    @
¶

§
