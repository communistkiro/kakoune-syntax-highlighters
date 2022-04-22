# Detection
# ---------

# The .hledger suffix is not required by hledger, but the best I can do.
hook global BufCreate .*\.journal %{
    set-option buffer filetype hledger
}

# Initialization
# --------------

hook global WinSetOption filetype=hledger %{
    require-module hledger

    hook window InsertChar \n -group hledger-indent hledger-indent-on-new-line
    hook window ModeChange pop:insert:.* -group hledger-trim-indent hledger-trim-indent

    hook -once -always window WinSetOption filetype=.* %{
        remove-hooks window hledger-.+
        unset-option window static_words  # Remove static completion
    }
}

hook -group hledger-highlight global WinSetOption filetype=hledger %{
    add-highlighter window/hledger ref hledger
    hook -once -always window WinSetOption filetype=.* %{
        remove-highlighter window/hledger
    }
}

# Completion
# ----------

hook -group hledger-complete global WinSetOption filetype=hledger %{
    set-option window static_words account note alias payee check assert eval default apply fixed bucket capture comment commodity format nomarket define end include tag test year
}

provide-module hledger %[

# Highlighters
# ------------
#
# TODO: highlight tag comments

add-highlighter shared/hledger regions

# The following highlighters implement
# https://www.hledger-cli.org/3.0/doc/hledger3.html#Transactions-and-Comments

add-highlighter shared/hledger/transaction region '^[0-9]' '^(?=\H)' group
add-highlighter shared/hledger/transaction/first_line regex \
    '^([0-9].*?)\h.*?((  +|\t+);.*?)?$' 1:function 2:string
add-highlighter shared/hledger/transaction/posting regex \
    '^\h+([^\h;].*?)((  +|\t+).*?)?((  +|\t+);.*?)?$' 1:type 2:value 4:string
add-highlighter shared/hledger/transaction/note regex '^\h+;[^$]*?$' 0:string

add-highlighter shared/hledger/comment region '^(;|#|%|\||\*)' '$' fill comment

# TODO: Improve
add-highlighter shared/hledger/other region '^(P|=|~)' '$' fill meta

# The following highlighters implement
# https://www.hledger-cli.org/3.0/doc/hledger3.html#Command-Directives

# Add highlighters for simple one-line command directives
evaluate-commands %sh{
    # TODO: Is `expr` also a command directive? The documentation confuses me.
    for cmd in 'apply account' 'apply fixed' 'assert' 'bucket' 'check' 'end' 'include' 'apply tag' 'test' 'year'; do
        echo "add-highlighter shared/hledger/ region '^${cmd}' '.' fill function"
    done
}

add-highlighter shared/hledger/account region '^account' '^(?=\H)' group
add-highlighter shared/hledger/account/first_line regex '^account'    0:function
add-highlighter shared/hledger/account/note       regex '^\h*note'    0:function
add-highlighter shared/hledger/account/alias      regex '^\h*alias'   0:function
add-highlighter shared/hledger/account/payee      regex '^\h*payee'   0:function
add-highlighter shared/hledger/account/check      regex '^\h*check'   0:function
add-highlighter shared/hledger/account/assert     regex '^\h*assert'  0:function
add-highlighter shared/hledger/account/eval       regex '^\h*eval'    0:function
add-highlighter shared/hledger/account/default    regex '^\h*default' 0:function

add-highlighter shared/hledger/alias region '^alias' '$' group
add-highlighter shared/hledger/alias/keyword regex '^alias'             0:function
add-highlighter shared/hledger/alias/key     regex '^alias\h([^$=]*)=?' 1:variable
add-highlighter shared/hledger/alias/value   regex '^alias\h.*?=(.*?)$' 1:value

add-highlighter shared/hledger/capture region '^capture' '$' group
add-highlighter shared/hledger/capture/keyword regex '^capture'                      0:function
add-highlighter shared/hledger/capture/account regex '^capture\h+(.*?)(  +|\t+|$)'   1:type
add-highlighter shared/hledger/capture/regex   regex '^capture\h+.*?(  +|\t+)(.*?)$' 2:value

add-highlighter shared/hledger/comment_block region '^comment' '^end comment' \
    fill comment

add-highlighter shared/hledger/commodity region '^commodity' '^(?=\H)' group
add-highlighter shared/hledger/commodity/first_line regex '^commodity'   0:function
add-highlighter shared/hledger/commodity/note       regex '^\h*note'     0:function
add-highlighter shared/hledger/commodity/format     regex '^\h*format'   0:function
add-highlighter shared/hledger/commodity/nomarket   regex '^\h*nomarket' 0:function
add-highlighter shared/hledger/commodity/alias      regex '^\h*alias'    0:function
add-highlighter shared/hledger/commodity/default    regex '^\h*default'  0:function

add-highlighter shared/hledger/define region '^define' '$' group
add-highlighter shared/hledger/define/keyword regex '^define'             0:function
add-highlighter shared/hledger/define/key     regex '^define\h([^$=]*)=?' 1:variable
add-highlighter shared/hledger/define/value   regex '^define\h.*?=(.*?)$' 1:value

add-highlighter shared/hledger/payee region '^payee' '^(?=\H)' group
add-highlighter shared/hledger/payee/first_line regex '^payee'    0:function
add-highlighter shared/hledger/payee/alias      regex '^\h*alias' 0:function
add-highlighter shared/hledger/payee/uuid       regex '^\h*uuid'  0:function

add-highlighter shared/hledger/tag region '^tag' '^(?=\H)' group
add-highlighter shared/hledger/tag/first_line regex '^tag'       0:function
add-highlighter shared/hledger/tag/check      regex '^\h*check'  0:function
add-highlighter shared/hledger/tag/assert     regex '^\h*assert' 0:function

# Commands
# --------

define-command -hidden hledger-indent-on-new-line %[
    evaluate-commands -draft -itersel %[
        # preserve previous line indent
        try %[ execute-keys -draft <semicolon> K <a-&> ]
        # cleanup trailing whitespaces from previous line
        try %[ execute-keys -draft k <a-x> s \h+$ <ret> d ]
        # indent after the first line of a transaction
        try %[ execute-keys -draft k<a-x> <a-k>^[0-9]<ret> j<a-gt> ]
    ]
]

define-command -hidden hledger-trim-indent %{
    try %{ execute-keys -draft <semicolon> <a-x> s ^\h+$ <ret> d }
}

]
