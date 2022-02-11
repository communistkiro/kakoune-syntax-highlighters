# kakoune-syntax-highlighters
To use, copy/move/symlink the files to either `/usr/share/kak/autoload/rc/filetype/` (for some UNIX-based OS's, check where yours' system-wide configuration files reside), or to `~/.config/kak/autoload/`, wherein it is assumed `/usr/share/kak/autoload/rc/` has been symlinked.​

## j
All j903 primitives appearing on NuVoc are highlighted. The bitwise operation `m b.` I have added to verbs, since it is a verb, not an adverb, as I see it. All parts of speech, most/all numerals, foreigns are grouped. You can change the colors to ones for sure defined in a color scheme, red, blue, green, white, black, etc., if you'd like. With a fairly dark background color of `#170e12` it appears as follows: ![](https://github.com/communistkiro/kakoune-syntax-highlighters/blob/master/scrot.png).

## zsh
Based off the provided syntax file for shell, would like to achieve something akin to [this](https://github.com/zdharma/fast-syntax-highlighting/), but I can't wrap my head around recursive regexing yet.
​
## hledger
Based off the provided syntax file for ledger, very little changed. I can guarantee that a basic double-entry file will render proper, but given I don't know how much hledger and ledger differ, everything else is up in the air for now.
