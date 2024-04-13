---@class (exact) UI
---@field update_fugitive_header
---| fun(bufnr: number, headers: FugitiveExtUiHeader[], delimiter?: string): nil
local ui = {}

--- tuple of header and keymap (ie. { "Help:", "?" })
---@alias FugitiveExtUiHeader string[]

--- Update the Help header of Fugitive (`Help: g?` -> `Help: ?  Doc: g?`)
function ui.update_fugitive_header(bufnr, headers, delimiter)
	for line_idx, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 4, false)) do
		if vim.startswith(line, "Help: g?") then
			vim.bo.modifiable = true
			vim.bo.readonly = false

			local hl = { 0 }
			local header = ""
			for j, h in ipairs(headers) do
				local delim = j == #headers and "" or delimiter or "  "
				header = header .. h[1] .. " " .. h[2] .. delim
				table.insert(hl, hl[#hl] + #h[1])
				table.insert(hl, hl[#hl] + #h[2] + 1)
				table.insert(hl, hl[#hl] + #delim)
			end
			vim.api.nvim_buf_set_lines(0, line_idx - 1, line_idx, false, { header })
			for j = 1, #hl - 1, 3 do
				vim.api.nvim_buf_add_highlight(
					bufnr,
					-1,
					"fugitiveHelpHeader",
					line_idx - 1,
					hl[j], -- beginnign of help_header_title
					hl[j + 1] -- end of help_header_title (beginning of help_header_key)
				)
				vim.api.nvim_buf_add_highlight(
					bufnr,
					-1,
					"Comment",
					line_idx - 1,
					hl[j + 2], -- beginning of delimiter
					hl[j + 3] and hl[j + 3] or -1 -- end of delimiter or eol (beginning of next help_header_title)
				)
			end
			vim.bo.modifiable = false
			vim.bo.readonly = true
			break
		end
	end
end

return ui
