# Merged File Search

## features

This is a *locate wrapper* which does:

- execute a locate search on *both* zero, one or more *remote servers* and the *local machine*
- do this in parrallel
- merge and rank-sort the results based on keywords
- map remote paths to local paths
- pipe this to fzf (the fuzzy finder)
- copy the selection to the clipboard
- if applicable, open *and select* the file in Thunar

I use this on my personal machines to easily find files on both the local computer and a remote file storage. I like to be able to quickly type "search foo bar" or click an icon in my dock or press Super-F, start the search, fine-tune the search using fzf, and open the filemanager Thunar with the selected file already selected.

## intended use

The scripts are meant to be used in an XFCE environment. I din't test other desktop environments; probably you don't need to change very much to adapt it. The intended users know a bit about Linux command line and/or scripting use and can edit the settings in the shellscripts.

## dependencies

You might need a few helper programs installed, such as fzf, zenity, xsel, gdbus, bash, xrdb, pidof, tput, xhost, sed, wc, locate ;-) and more; the scripts do dependency checking when being run.

## shortcomings

The ranked sorting might be a bit slow; maybe I should create a small program in C for that in the future. A stand-alone version is provided as `SortOnKeyWordsRanked.sh`; it should be improved.

## usage

I recommend to bind a key to this script. For e.g. XFCE, you bind Super-F using:

	xfconf-query --create --channel xfce4-keyboard-shortcuts --property "/commands/custom/<Super>f" --type string  --set "/home/evert/bin/search-gui"

In a terminal (CLI), you have to use an alias or add the script to the PATH. When you want to search for *foo* and *bar*, do:

	search foo bar

Personally I like cairo-dock so I've dragged the `File Search.desktop` file to it.

## author

Have fun!

~Evert

Version: 2019-01-31

Created by [Evert Mouw](post@evert.net)

License: [WTFPL](http://www.wtfpl.net/)
