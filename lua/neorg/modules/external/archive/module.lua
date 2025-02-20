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
	confirm = true,
}

module.events.subscribed = {
	["core.neorgcmd"] = {
		["archive.archive-file"] = true,
		["archive.restore-file"] = true,
	},
}

module.setup = function()
	return {
		success = true,
		requires = {
			"core.dirman",
			"core.neorgcmd",
			"external.refactor",
		},
	}
end

module.load = function()
	dirman = module.required["core.dirman"]
	refactor = module.required["external.refactor"]
	neorgcmd = module.required["core.neorgcmd"]

	local archive_workspace = dirman.get_workspace(module.config.public.workspace)
	if not archive_workspace then
		log.fatal("Archive workspace not found! Add " .. module.config.public.workspace .. " to your dirman workspaces")
		return
	end

	neorgcmd.add_commands_from_table({
		archive = {
			min_args = 1,
			max_args = 1,
			args = 1,
			condition = "norg",
			subcommands = {
				["archive-file"] = {
					args = 0,
					name = "archive.archive-file",
				},
				["restore-file"] = {
					args = 0,
					name = "archive.restore-file",
				},
			},
		},
	})
end

module.on_event = function(event)
	if event.split_type[1] == "core.neorgcmd" then
		if event.split_type[2] == "archive.archive-file" then
			module.public.archive_file()
		elseif event.split_type[2] == "archive.restore-file" then
			module.public.restore_file()
		end
	end
end

module.public.archive_file = function()
	if not module.private.confirm_archive_operation("archive file") then
		return
	end

	local workspace = dirman.get_workspace_match()
	if workspace == module.config.public.workspace then
		log.error("Cannot archive files within the archive workspace!")
		return
	end

	local archive_path = tostring(dirman.get_workspace(module.config.public.workspace))
	local current_path = vim.api.nvim_buf_get_name(0)
	local current_workspace_path = tostring(dirman.get_workspace(workspace))

	local new_path = current_path:gsub("^" .. current_workspace_path, archive_path .. "/" .. workspace)

	local success = refactor.rename_file(current_path, new_path)
	if not success then
		log.error("Failed to refactor " .. current_path)
		if module.config.public.refactor_fail then
			return
		end
	end

	if vim.fn.filereadable(current_path) then
		log.info("File not moved to archive, moving to" .. new_path)
		os.rename(current_path, new_path)
	end

	vim.api.nvim_command("edit " .. new_path)
	log.info("Archived file under " .. new_path)
end

module.public.restore_file = function()
	if not module.private.confirm_archive_operation("restore file") then
		return
	end

	local archive_path = tostring(dirman.get_workspace(module.config.public.workspace))
	local current_path = vim.api.nvim_buf_get_name(0)
	if not current_path:match("^" .. archive_path) then
		log.error("Cannot restore files outside of the archive workspace")
		return
	end

	local workspace_name = current_path:match(archive_path .. "/([^/]+)/")
	if not workspace_name then
		log.error("Could not determine original workspace from path")
		return
	end

	local workspace_path = tostring(dirman.get_workspace(workspace_name))
	if not workspace_path then
		log.error("Workspace '" .. workspace_name .. "' not found!")
		return
	end

	local restore_path = current_path:gsub("^" .. archive_path .. "/" .. workspace_name, workspace_path)

	local success = refactor.rename_file(current_path, restore_path)
	if not success then
		log.error("Failed to restore " .. current_path)
		return
	end

	if vim.fn.filereadable(current_path) then
		log.info("File not moved to original location, moving to " .. restore_path)
		os.rename(current_path, restore_path)
	end

	vim.api.nvim_command("edit " .. restore_path)
	log.info("Restored file to " .. restore_path)
end

--- Confirm archive operations based on module configuration
---@param operation string #The name of the operation to confirm, used in user prompt
---@return boolean #Confirmation status, if false abort operation
module.private.confirm_archive_operation = function(operation)
	if module.config.public.confirm then
		return vim.fn.confirm("Are you sure you want to " .. operation .. "? y/n", "&Yes\n&No", 2) == 1
	end
	return true
end

return module
