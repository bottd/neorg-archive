# Neorg Archive
[![LuaRocks](https://img.shields.io/luarocks/v/bottd/neorg-archive?logo=lua&color=purple)](https://luarocks.org/modules/bottd/neorg-archive)

Create and manage an archival workspace for your Neorg notes.


## Installing

This module depends on [neorg-interim-ls](https://github.com/benlubas/neorg-interim-ls). Note the temporary nature of interim-ls, this plugin will be updated once an official Neorg LSP is created.

Rocks.nvim 🗿

`:Rocks install neorg-archive`

<details>
  <summary>Lazy.nvim</summary>

```lua
-- neorg.lua
{
    "nvim-neorg/neorg",
    lazy = false,
    version = "*",
    config = true,
    dependencies = {
        { "bottd/neorg-archive" }
    }
}
```
</details>

## Config

```
["external.interim-ls"] = {
  -- find interim-ls options here:
  -- https://github.com/benlubas/neorg-interim-ls?tab=readme-ov-file#install
}
["external.archive"] = {
    -- default config
    config = {
        -- (Optional) Archive workspace name, defaults to "archive"
        workspace = "archive",
    }
},
```
