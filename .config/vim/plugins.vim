vim9script
const config_dir = expand('<sfile>:p:h') 
const plugins_dir = config_dir .. '/plugged'

import autoload 'plug.vim'

plug#begin(plugins_dir)

Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'

plug#end()
