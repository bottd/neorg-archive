local neorg = require("neorg.core")
local modules, log = neorg.modules, neorg.log

local dirman ---@type core.dirman
local neorgcmd ---@type core.neorgcmd
local refactor ---@type external.refactor

local module = modules.create("external.archive")

module.config.public = {
  -- (Optional) Archive workspace name, defaults to "archive"
  workspace = "archive",
  -- (Optional) Enable/disable confirming archive operations
  confirm = true
}

module.events.subscribed = {
  ["core.neorgcmd"] = {
    ["archive.current-file"] = true,
    ["archive.current-directory"] = true,
    ["archive.restore"] = true,
  },
}


module.setup = function()
  return {
    success = true,
    requires = {
      "core.dirman",
      "core.neorgcmd",
      "external.refactor"
    },
  }
end

module.load = function()
  dirman = module.required["core.dirman"]
  refactor = module.required["external.refactor"]
  neorgcmd = module.required["core.neorgcmd"]

  local archive_workspace = dirman.get_workspace(module.config.public.workspace)
  if (not archive_workspace) then
    log.fatal("[neorg-archive] Archive workspace not found! Please add one to your Neorg config")
    return
  end

  neorgcmd.add_commands_from_table({
    archive = {
      min_args = 1,
      max_args = 1,
      args = 1,
      condition = "norg",
      subcommands = {
        ["current-file"] = {
          args = 0,
          name = "archive.current-file",
        },
        ["current-directory"] = {
          args = 0,
          name = "archive.current-directory",
        },
        ["restore"] = {
          args = 0,
          name = "archive.restore",
        },


      },
    },
  })
end

module.on_event = function(event)
  if event.split_type[1] == "core.neorgcmd" then
    if event.split_type[2] == "archive.current-file" then
      module.public.archive_current_file()
    elseif event.split_type[2] == "archive.current-directory" then
      module.public.archive_current_directory()
    elseif event.split_type[2] == "archive.restore" then
      module.public.restore()
    end
  end
end

module.public.archive_current_file = function()
  if (not module.private.confirm_archive_operation("archive current file")) then
    return
  end

  local workspace = dirman.get_workspace_match()
  if (workspace == module.config.public.workspace) then
    log.error("Cannot archive files within the archive workspace!")
    return
  end

  local archive_path = tostring(dirman.get_workspace(module.config.public.workspace))
  local current_path = vim.api.nvim_buf_get_name(0)
  local current_workspace_path = tostring(dirman.get_workspace(workspace))

  local new_path = current_path:gsub("^" .. current_workspace_path, archive_path .. "/" .. workspace)

  local success = refactor.rename_file(current_path, new_path)
  if (not success) then
    log.error("Failed to archive " .. current_path)
  end

  if (vim.fn.filereadable(current_path)) then
    log.info("[neorg-archive] File not moved to archive, moving to" .. new_path)
    os.rename(current_path, new_path)
  end

  vim.api.nvim_command('edit ' .. new_path)
  log.info("Archived file under " .. new_path)
end

module.public.archive_current_directory = function()
  if (not module.private.confirm_archive_operation("archive current directory")) then
    return
  end

  local workspace = dirman.get_current_workspace()
  if (workspace == module.config.public.workspace) then
    log.error("Cannot archive files within the archive workspace!")
    return
  end
  -- TODO
end

module.public.archive_restore = function()
  if (not module.private.confirm_archive_operation("restore current file")) then
    return
  end
  -- TODO
end


--- Confirm archive operations based on module configuration
---@param operation string #The name of the operation to confirm, used in user prompt
---@return boolean #Confirmation status, if false abort operation
module.private.confirm_archive_operation = function(operation)
  if (module.config.public.confirm) then
    return vim.fn.confirm("Are you sure you want to " .. operation .. "? y/n", "&Yes\n&No", 2) == 1
  end
  return true
end

return module
