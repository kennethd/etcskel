"" type 'vimtutor' if you are unfamiliar with vi/vim
"" boolean options can be set/unset during editing session by typing ':set <option>' or ':set no<option>'
set tabstop=8           " see ':h tabstop' for explanation of first four options
set expandtab           " turn tabs into a series of spaces
set softtabstop=4       " how many spaces each tab should appear to indent by
set shiftwidth=4        " num spaces for cindent, SHIFT->>, SHIFT-<<
set autoindent          " smart indenting
set modeline            " support modeline use
set bs=2                " more intuitive backspace handling. same as ":set backspace=indent,eol,start" 
set hls                 " hilight search term(s)
set ignorecase          " allow /foo to match 'foo' 'Foo' 'FOO' etc..
set incsearch           " search-as-you-type
set nocompatible        " use 'vim', screw compatibility with old 'vi'
set nowrap              " do not "soft wrap" lines to fit screen by default
set ruler               " show cursor position as line,column (+ maybe % of file displayed)
set autowrite           " write to file before changing buffers
syntax on               " use syntax highlighting for known filetypes
set number              " display line numbers on left side of screen when editing
set showmatch           " hilight matching brace/bracket while editing
set showcmd             " show (partial) command in the last line of the screen
set bg=dark             " use dark colors
set tw=78               " textwidth (column to wrap text)
