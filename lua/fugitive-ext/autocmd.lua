local Autocmd = {}

--- Setup autocmd
---@param fugitive_ext FugitiveExt
function Autocmd.setup(fugitive_ext)
	local augroup = function(name)
		return vim.api.nvim_create_augroup("FugitiveExt" .. name, { clear = true })
	end

	local config = fugitive_ext.config

	-- Open the hint on various events
    -- stylua: ignore
	vim.api.nvim_create_autocmd({
		"BufEnter",                 -- new fugitive window and nav between other vim windows
		"WinLeave",                 -- fugitive focur lost
		"VimResized",               -- when size of tmux pane (vim) is changed
		"FocusGained", "FocusLost", -- nav between tmux panes
		"WinResized",               -- NOTE: not sure when this is triggered
		"WinScrolled",              -- NOTE: not sure when this is triggered
	}, {
		group = augroup("Open"),
		pattern = "fugitive://*/.git//",
		callback = function(ev)
			if config._debug then
				vim.notify("Autocmd.setup - Open - " .. ev.event, 3)
			end
            vim.keymap.set("n", "?", function() fugitive_ext.hint:toggle() end , { buffer = ev.buf })
			fugitive_ext.hint:refresh()
		end,
	})

	-- Close the hint when the fugitive window is closed
	vim.api.nvim_create_autocmd({ "WinClosed", "BufUnload" }, {
		group = augroup("Close"),
		pattern = "fugitive://*/.git//",
		callback = function(ev)
			if config._debug then
				vim.notify("Autocmd.setup - Close - " .. ev.event, 3)
			end
			fugitive_ext.hint:close()
		end,
	})

	-- Close the hint when rebasing, editing commit msg and gitignore
	vim.api.nvim_create_autocmd("BufEnter", {
		group = augroup("Etc"),
		pattern = { "gitcommit", "gitrebase", "gitignore" },
		callback = function(ev)
			if config._debug then
				vim.notify("Autocmd.setup - Etc" .. ev.event, 3)
			end
			fugitive_ext.hint:close()
		end,
	})

	-- Update fugitive header (i.e. `Help: g?` --> `Help: g?, Hint: ?`)
	vim.api.nvim_create_autocmd("FileType", {
		group = augroup("UI"),
		pattern = "fugitive",
		callback = function(ev)
			if config._debug then
				vim.notify("Autocmd.setup - UI", 3)
			end

			local window = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_option(window, "number", config.fugitive.line_number)
			vim.api.nvim_win_set_option(window, "relativenumber", config.fugitive.relative_number)

			local ui = require("fugitive-ext.ui")
			ui.update_fugitive_header(ev.buf, config.fugitive.hint_header, config.fugitive.hint_header_delimiter)
		end,
	})
end

return Autocmd
