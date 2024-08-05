# ntangle-notebook.nvim

Jupyter frontend for literate python files.

![](https://github.com/jbyuki/gifs/blob/main/jupyternotebook.png)

Main Features
-------------

* No external dependencies

* Multiple kernel support

* Visual range execution

Requirements
------------

* [ntangle-inc.nvim](https://github.com/jbyuki/ntangle-inc.nvim)
* [Jupyter notebook](https://jupyter.org/install) (`jupyter lab` is recommended)

> [!WARNING]
> Full support only for ntangle v2 (*.t2 files)

Configuration
-------------

### Keybindings

```lua
vim.api.nvim_create_autocmd({"BufRead", "BufNew"}, {
  pattern = { "*.py.t2" },
  callback = function(ev) 
    local opts = { buffer = ev.buf, silent=true }
    vim.keymap.set("n", "<leader>r", function() 
      require"ntangle-notebook".send_ntangle_v2() 
    end, opts)

    vim.keymap.set('v', '<leader>r', ":SendNTangleV2<CR>",  opts)
  end
})
```

### Runtime dir

Set the runtime directory. It can be found by running `jupyter --runtime-dir` or `python -m jupyter --runtime-dir`.

```lua
vim.g.ntangle_notebook_runtime_dir = "..."
```

Usage
-----

- Start jupyter and launch a kernel
- Execute `:lua require"ntangle-notebook".connect()`
- Choose a kernel if multiple are proposed

- Open a `*.py.t2` file and execute code by:
  - In normal mode: Press `<leader>r`.
  - In visual mode: Select a region and `<leader>r`.
