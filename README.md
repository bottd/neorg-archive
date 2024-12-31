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

Two configuration steps are required. First, add an archive workspace:
```lua
require("neorg").setup({
    load = {
        ["core.dirman"] = {
            config = {
                workspaces = {
                    archive = "path/to/your/archive",
                },
            },
        },
        ["external.interim-ls"] = {
        -- find interim-ls options here:
        -- https://github.com/benlubas/neorg-interim-ls?tab=readme-ov-file#install
        },
        ["external.archive"] = {
        -- default config
            config = {
                -- (Optional) Archive workspace name, defaults to "archive"
                workspace = "archive",
                -- (Optional) Enable/disable confirming archive operations
                confirm = true
            }
        }
    },
})
```

## Usage

The archive module adds the following commands:

### `:Neorg archive current-file` 
Moves the currently opened file to the archive: `archive-workspace/workspace-name/path-to-file`

### TODO `:Neorg archive current-directory`
Moves the current file's directory to the archive: `archive-workspace/workspace-name/path-to-directory`
### TODO `:Neorg archive restore`
Moves an archived file back to it's workspace from `archive-workspace/workspace/file,norg` to `workspace/file.norg`
