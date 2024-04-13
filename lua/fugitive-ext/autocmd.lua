local Autocmd = {}

--- Setup autocmd
---@param fugitive_ext FugitiveExt
function Autocmd.setup(fugitive_ext)
	local augroup = function(name)
		return vim.api.nvim_create_augroup("FugitiveExt" .. name, { clear = true })
	end

	-- Open the help window on various events
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
			if fugitive_ext.config._debug then
				vim.notify("Autocmd.setup - Open - " .. ev.event, 3)
			end
			fugitive_ext.help:refresh()
		end,
	})

	-- Close the help window when the fugitive window is closed
	vim.api.nvim_create_autocmd({ "WinClosed", "BufUnload" }, {
		group = augroup("Close"),
		pattern = "fugitive://*/.git//",
		callback = function(ev)
			if fugitive_ext.config._debug then
				vim.notify("Autocmd.setup - Close - " .. ev.event, 3)
			end
			fugitive_ext.help:close()
		end,
	})

	-- Close the help window when rebasing, editing commit msg and gitignore
	vim.api.nvim_create_autocmd("BufEnter", {
		group = augroup("Etc"),
		pattern = { "gitcommit", "gitrebase", "gitignore" },
		callback = function(ev)
			if fugitive_ext.config._debug then
				vim.notify("Autocmd.setup - Etc" .. ev.event, 3)
			end
			fugitive_ext.help:close()
		end,
	})

	-- Update fugitive header (Help: g? --> Help: ?, Doc: g?)
	vim.api.nvim_create_autocmd("FileType", {
		group = augroup("UI"),
		pattern = "fugitive",
		callback = function(ev)
			if fugitive_ext.config._debug then
				vim.notify("Autocmd.setup - UI", 3)
			end
			local ui = require("fugitive-ext.ui")
			ui.update_fugitive_header(ev.buf, {
				{ "Help:", "?" },
				{ "Doc:", "g?" },
			}, "  ")
		end,
	})
end

return Autocmd
