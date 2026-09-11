# jet.ark

jet.ark is an Neovim plugin which extends
[jet.nvim](https://github.com/wurli/jet.nvim) to provide language features for
R using the [Ark](https://github.com/posit-dev/ark) jupyter kernel.



## Features

* [x] R console implemented via Jet
* [x] R 'expression' detection, allowing you to send units of code with a
  single keystroke
* [x] A LSP server which is aware of your R session (e.g. providing completions
  for dataframe column names and other session-specific stuff)
* [x] Resizable plots
* [x] `:ArkHelp {topic}` command (with followable hyperlinks), powered by Ark's `help` comm
* [ ] Debug adaptor
* [ ] Variables pane
* [ ] Connections pane

## Installation

You'll need to install [Ark](https://github.com/posit-dev/ark) and tell jet.ark
where the binary lives. In the future this plugin will handle downloading Ark
for you.

``` lua
-- You'll need to include both jet.nvim and jet.ark
vim.pack.add({ "https://github.com/wurli/jet.nvim" })
vim.pack.add({ "https://github.com/wurli/jet.ark" })

require("jet").setup({})
require("jet.ark").setup({
	ark_binary_path = "path-to-ark-binary",
})
```

## Keymaps

See [jet.nvim](https://github.com/wurli/jet.nvim#keymaps) for advice on
creating keymaps, e.g. to send code to the R console.

## Usage

Use `:Jet repl` to open R. Ark's LSP will start automatically and attach to any
R buffer you have open.

``` lua
-- You can set a keymap to toggle the R console like so
vim.keymap.set("n", "<leader>jr", function()
	require("jet.core.api").get_any({ filetype = "r" }, {}, function(k)
		k:toggle_term()
	end)
end, { desc = "Open R (Jet)" })
```
