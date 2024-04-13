local Autocmd = {}

--- Setup autocmd
---@param fugitive_ext FugitiveExt
function Autocmd.setup(fugitive_ext)
	local augroup = function(name)
		return vim.api.nvim_create_augroup("FugitiveExt" .. name, { clear = true })
	end

	-- Open the help window on various events
	vim.api.nvim_create_autocmd({ "BufEnter", "WinLeave", "WinResized", "VimResized", "FocusGained", "FocusLost", "WinScrolled"}, {
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
end

return Autocmd
