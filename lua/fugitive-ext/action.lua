--- List of fugitive-native + extended actions
---@class FugitiveExtActions
local Actions = {}

---Action for keymap
---@alias FugitiveExtAction string | fun(): nil TODO: make into enum

--- Feed escaped keys to Nvim (`:h vim.api.nvim_feedkeys`)
---@param keys string
local function feed_escaped_keys(keys)
	keys = vim.api.nvim_replace_termcodes(keys, true, true, true)
	vim.api.nvim_feedkeys(keys, "n", true)
end

--- :Git push
---@type FugitiveExtAction
Actions.push = function()
	local keys = ":Git push "
	feed_escaped_keys(keys)
end

--- :Git pull
Actions.pull = function()
	local keys = ":Git pull "
	feed_escaped_keys(keys)
end

--- Confirm to `commit --amend --no-edit`
Actions.commit_amend_no_edit = function()
	vim.ui.input({ prompt = "Are you sure to `commit --amend --no-edit`? (y/n)" }, function(input)
		if input and string.match(input, "^%s*(.-)%s*$") == "y" then
			feed_escaped_keys("<Plug>fugitive:ce")
		end
	end)
end

--- Confirm to discard changes
Actions.discard = function()
	vim.ui.input({ prompt = "Are you sure to discard changes? (y/n)" }, function(input)
		if input and string.match(input, "^%s*(.-)%s*$") == "y" then
			feed_escaped_keys("<Plug>fugitive:X")
		end
	end)
end

-- TODO: all fugitive commands

return Actions
