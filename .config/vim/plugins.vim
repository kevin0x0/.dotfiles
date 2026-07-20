vim9script
const config_dir = expand('<sfile>:p:h') 
const plugins_dir = config_dir .. '/plugged'

import autoload 'plug.vim'

plug#begin(plugins_dir)

Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-polyglot/vim-polyglot'
Plug 'junegunn/fzf.vim'

plug#end()

nmap <Leader>ff :Files<CR>
nmap <Leader>fg :RG<CR>
