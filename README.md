<p align="center">
  <h1 align="center">soicode.nvim</h2>
</p>

<p align="center">
  Implementation of the soicode
[vscode plugin](https://marketplace.visualstudio.com/items?itemName=swissolyinfo.soicode)
made for the [Swiss Olympiad in Informatics](https://soi.ch).
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

Make sure that you run the `./install.sh` script after you installed the plugin.

I provided two examples with `packer` and `lazy` but if you use something else
check your documentation for this.

<div align="center">
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

[wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim)

</td>
<td>

```lua
-- stable version
use {"soicode.nvim", tag = "*", run = "./install.sh"}
-- dev version
use {"soicode.nvim", run = "./install.sh"}
```

</td>
</tr>
<tr>
<td>

[folke/lazy.nvim](https://github.com/folke/lazy.nvim)

</td>
<td>

```lua
-- stable version
require("lazy").setup({{"soicode.nvim", version = "*", build = "./install.sh"}})
-- dev version
require("lazy").setup({"soicode.nvim", build = "./install.sh"})
```

</td>
</tr>
</tbody>
</table>
</div>

## ☄ Getting started

TODO:
Describe how to use the plugin the simplest way

## ⚙ Configuration

TODO:
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

TODO:

| Command   | Description         |
| --------- | ------------------- |
| `:Toggle` | Enables the plugin. |

## ⌨ Contributing

PRs and issues are always welcome. Make sure to provide as much context as possible when opening one.

## 🎭 Motivation

Soicode VSCode plugin:
[vscode plugin](https://marketplace.visualstudio.com/items?itemName=swissolyinfo.soicode)