local help = require("fugitive-ext.help")

-- Open the help window on various events
vim.api.nvim_create_autocmd({ "BufEnter", "WinLeave", "WinResized", "VimResized", "FocusGained", "FocusLost" }, {
	group = vim.api.nvim_create_augroup("FugitiveExtOpen", { clear = true }),
	buffer = 0,
	callback = function()
		help:refresh()
	end,
})

-- Close the help window when the fugitive window is closed
vim.api.nvim_create_autocmd({ "WinClosed", "BufUnload" }, {
	group = vim.api.nvim_create_augroup("FugitiveExtClose", { clear = true }),
	buffer = 0,
	callback = function()
		help:close()
	end,
})

-- Close the help window when rebasing, editing commit msg and gitignore
vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("FugitiveExtEtc", { clear = true }),
	pattern = { "gitcommit", "gitrebase", "gitignore" },
	callback = function()
		help:close()
	end,
})
