local neorg = require("neorg.core")
local modules, lib, log = neorg.modules, neorg.lib, neorg.log

local dirman ---@type core.dirman
local refactor ---@type external.refactor

local module = modules.create("external.archive")

module.config.public = {
  -- (Optional) Archive workspace name, defaults to "archive"
  workspace = "archive",
}

module.events.subscribed = {
  ["core.neorgcmd"] = {
    ["external.archive.current-file"] = true,
    ["external.archive.current-directory"] = true,
    ["external.archive.restore"] = true,
  },
}


module.setup = function()
  return {
    success = true,
    requires = {
      "core.dirman",
      "external.interim-ls"
    },
  }
end

module.load = function()
  dirman = module.required["core.dirman"]
  refactor = module.required["external.refactor"]
end

module.on_event = function(event)
  if event.split_type[1] == "core.neorgcmd" then
    if event.split_type[2] == "archive.current-file" then
      module.public.archive_current_file()
    elseif event.split_type[2] == "archive.current-directory" then
      module.public.archive_current_file()
    elseif event.split_type[2] == "archive.restore" then
      module.public.archive_current_file()
    end
  end
end

module.public.archive_current_file = function()
  local workspace = dirman.get_current_workspace()

  local _, archive_path = dirman.get_workspace(module.config.public.workspace)

  -- get current workspace
  -- get workspace path
  -- get archive workspace path
  -- use refactor module to move file archive workspace path / workspace-name / subpath of prior workspace
end

module.public.archive_current_directory = function()
end

module.public.archive_restore = function()
end

return module
