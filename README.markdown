**T.vim** 本插件为 vim 提供完全离线的单词翻译功能。

![T.vim Screenshot](./Kapture.gif)

## Installation
选择一个你喜欢的插件管理器来安装插件

<details>
  <summary>Vundle</summary>

1. 按照插件说明安装Vundle
2. 将下面的文本放进你的 `vimrc`.
    ```vim
    call vundle#begin()
      Plugin 'sicong-li/T.vim'
    call vundle#end()
    ```
3. 重新打开你的 vim, 运行命令`:PluginInstall` 来安装插件.
</details>

<details>
  <summary>Vim-Plug</summary>

1. 按照插件说明安装 Vim-Plug
2. 将下面的文本放进你的`vimrc`.
```vim
call plug#begin()
  Plug 'sicong-li/T.vim'
call plug#end()
```
3. 重新打开你的 vim, 运行命令`:PluginInstall` 来安装插件.
</details>

<details>
  <summary>Dein</summary>

1. 按照插件说明安装 Vim-Plug
1. 将下面的文本放进你的`vimrc`.
    ```vim
    call dein#begin()
    ¦ call dein#add('sicong-li/T.vim')
    call dein#end()
    ```
3. 重新打开你的 vim, 运行命令`:PluginInstall` 来安装插件.
</details>

### Option variables
设置快捷键(在需要翻译的单词上使用 \<leader\>t 来进行翻译，leader 键默认为 "\\")
```vim
nnoremap <leader>t :call T#Main(expand('<cword>'))<cr>
```

支持在 visual 模式选词的情况下使用 \<leader\>t 来进行翻译
```vim
vnoremap <leader>t :<c-u>call T#VisualSearch(visualmode())<cr>
```

设置展示最近翻译快捷键
```vim
nnoremap <leader>r :call T#DisplayRecent()<cr>
```

![T recent page](./recent.jpg)


### 其他自定义操作
```vim
" 设置翻译页面展示最近翻译的词条数，默认展示最近五条翻译
let g:displayRecentNum = 5

" 设置记录最近翻译的条数，默认记录最近查询的100 个单词
let g:totalRecentNum = 100

" 设置翻译页面的宽度，默认为 50
let g:TWinSize = 50
```

### Acknowledgments
本项目的翻译词条来源于：[ECDICT](https://github.com/skywind3000/ECDICT)

