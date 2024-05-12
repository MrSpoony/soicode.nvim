<p align="center">
  <h1 align="center">soicode.nvim</h2>
</p>

<p align="center">
  Implementation of the soicode
  <a href="https://marketplace.visualstudio.com/items?itemName=swissolyinfo.soicode">vscode plugin</a>
made for the <a href="https://soi.ch">Swiss Olympiad in Informatics</a>.
inside of neovim.
</p>

## ⚡️ Features

Most of the features present in the soicode plugin are also present here.

- Run code against one sample
- Run code against all samples
- Import testcases from stoml file
- Run compiled code with own input
- Insert a template
- Use the `<soi>` header

## 📋 Installation

> **Important: You need to be on Neovim Nightly, because this plugin uses `vim.system()`**

Make sure that you run the `./install.sh` script after you installed the plugin.

I provided two examples with `packer` and `lazy` but if you use something else
check your documentation for this.

<div>
<table>
<thead>
<tr>
<th>Package manager</th>
<th>Snippet</th>
</tr>
</thead>
<tbody>
<tr>
<td>

[folke/lazy.nvim](https://github.com/folke/lazy.nvim)

</td>
<td>

```lua
-- stable version
require("lazy").setup({
    {
        "soicode.nvim",
        version = "*",
        build = "./install.sh"
        dependencies = {
            -- "rcarriga/nvim-notify"
        }
    },
})
-- dev version
require("lazy").setup({
    {
        "soicode.nvim",
        build = "./install.sh"
        dependencies = {
            -- "rcarriga/nvim-notify"
        }
    },
})
```

</td>
</tr>
</tbody>
</table>
</div>

The plugin `rcarriga/nvim-notify` is recommended but not needed,
because this plugin works a lot with notifications and this plugin (or similar)
provide a nice UI for displaying them on the screen.

## ☄ Getting started

TODO: document

Describe how to use the plugin the simplest way

## ⚙ Configuration

TODO: document

The configuration list sometimes become cumbersome, making it folded by default reduce the noise of the README file.

<details>
<summary>Click to unfold the full list of options with their default values</summary>

> **Note**: The options are also available in Neovim by calling `:h soicode.options`

```lua
require("soicode").setup({
    -- you can copy the full list from lua/soicode/config.lua
})
```

</details>

## 🧰 Commands

TODO: document/create

| Command   | Description         |
| --------- | ------------------- |
| `:Toggle` | Enables the plugin. |

## ⌨ Contributing

PRs and issues are always welcome. Make sure to provide as much context as possible when opening one.

## 📝 Todo list

- [ ] Run interactive tasks (also normal tasks) with own input
- [ ] Add neovim commands for easier access, and shortcut configuration
- [ ] Add template support
- [ ] Add soi header
- [ ] Add stoml auto-copy feature
- [ ] Cache for compiling -> only compile when source has changed, command/flags changed or some time passed.
- [ ] Debugging samples -> DAP configuration etc.?

## 🎭 Motivation

Soicode VSCode plugin:
[vscode plugin](https://marketplace.visualstudio.com/items?itemName=swissolyinfo.soicode)
