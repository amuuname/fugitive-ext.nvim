---@class FugitiveExtHelp
---@field on boolean indicates whether the user turned on/off the help
---@field win_id? number
---@field bufnr? number
---@field content string[] content generated from the `tips` table (from config)
---@field section_lens SectionLengths max len of key and desc for each section
---@field fugitive_bufnr? number
---@field fugitive_width? number
---@field fugitive_height? number
---@field config FugitiveExtConfig
local FugitiveExtHelp = {}
FugitiveExtHelp.__index = FugitiveExtHelp

---@alias SectionName string
---@alias SectionLengths { [SectionName]: { key: number, desc: number} }

---@class Padding
---@field header boolean
---@field footer boolean
---@field line_leader number
---@field key_desc number
---@field section number

---@param config FugitiveExtConfig
function FugitiveExtHelp:new(config)
	local data = self:setup(config)
	return setmetatable({
		on = config.help.visibility,
		win_id = nil,
		bufnr = nil,
		tips = {},
		content = data.content,
		padding = data.lengths,
		fugitive_bufnr = nil,
		fugitive_width = nil,
		fugitive_height = nil,
		config = config,
	}, self)
end

---@param config FugitiveExtConfig
---@return { content: string[], lengths: SectionLengths }
function FugitiveExtHelp:setup(config)
	local align_str = require("plenary.strings").align_str

	local sections = config.help.sections
	local padding = config.help.padding

	---@type SectionLengths
	local lengths = {}

	---@type integer: Maximum number of help_entry among all sections
	local max_num_tips = 0
	for section, tips in pairs(sections) do
		max_num_tips = math.max(max_num_tips, #tips)
		local max_key, max_desc = 0, 0
		for _, tip in ipairs(tips) do
			max_key = math.max(max_key, #tip[1])
			max_desc = math.max(max_desc, #tip[2])
		end
		lengths[section].key = max_key
		lengths[section].desc = max_desc
	end

	-- Generate help content
	---@type string[]
	local content = {}

	local header = align_str("", padding.line_leader, false)
	for section, _ in pairs(sections) do
		header = header .. align_str(section, lengths[section].key + lengths[section].desc, false)
	end
	table.insert(content, header)

	if padding.header then
		table.insert(content, "")
	end

	for i = 1, max_num_tips do
		local line = align_str("", padding.line_leader, false)
		for section, tips in pairs(sections) do
			line = line .. align_str(tips[i][1] or "", lengths[section].key + lengths[section].desc, false)
		end
		table.insert(content, line)
	end

	if padding.footer then
		table.insert(content, "")
	end

	return { content = content, lengths = lengths }
end

--- Open the help window
---@param opts { force: boolean }
function FugitiveExtHelp:open(opts)
	-- early return if help is already open
	if self:_is_opened() then
		return
	end
	-- self:close() -- ???

	self.fugitive_width = vim.api.nvim_win_get_width(0)
	self.fugitive_height = vim.api.nvim_win_get_height(0)

	-- early return if the fugitive window is too short
	if not opts.force and self.fugitive_height < self.config.help.min_fugitive_win_height then
		return
	end

	self.bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_text(self.bufnr, 0, 0, 0, 0, self.content)

	---@type integer|nil: floating window id
	self.win_id = vim.api.nvim_open_win(self.bufnr, false, {
		relative = "win",
		anchor = "NW",
		width = vim.api.nvim_win_get_width(0),
		height = #self.content,
		style = "minimal",
		border = { { "─", "WinSeparator" }, { "─", "WinSeparator" }, { "─", "WinSeparator" }, "", "", "", "", "" },
		row = vim.api.nvim_win_get_height(0) - (#self.content + 1), -- #content + #border_lines
		col = 0,
		-- focusable = false,
		noautocmd = true,
	})

	self:_apply_highlight()
end

--- Close the help window
function FugitiveExtHelp:close()
	if self:_is_opened() then
		vim.api.nvim_win_close(self.win_id, true)
		vim.api.nvim_buf_delete(self.bufnr, { force = true })
		self.win_id = nil
		self.bufnr = nil
		self.fugitive_bufnr = nil
		self.fugitive_width = nil
		self.fugitive_height = nil
	end
end

--- Refresh the help window
function FugitiveExtHelp:refresh()
	if not self.on then
		-- early return if user turned off the help
		return
	end
	if self:_fugitive_resized() then
		self:close()
		self:open({ force = false })
	else
		self:open({ force = false })
	end
end

--- Toggle the help window
function FugitiveExtHelp:toggle()
	if self:_is_opened() then
		self:close()
		---@type boolean|nil: Whether the help window is closed
		vim.g.fugitive_ext_disabled = true
	else
		self:open({ force = true })
		vim.g.fugitive_ext_disabled = false
	end
end

--- Check if the fugitive window is resized
function FugitiveExtHelp:_fugitive_resized()
	return self.fugitive_width ~= vim.api.nvim_win_get_width(0)
		or self.fugitive_height ~= vim.api.nvim_win_get_height(0)
end

--- Apply syntax highlighting to the help window
function FugitiveExtHelp:_apply_highlight()
	local num_lines = #self.content
		- (self.config.help.padding.header and 1 or 0)
		- (self.config.help.padding.footer and 1 or 0)
		- (self.config.help.separator and 1 or 0)

	-- prevent cursor from going below the help window
	vim.api.nvim_win_set_option(self.win_id, "scrolloff", num_lines)

	-- apply syntax highlighting
	local highlights = { 0 }
	for _, lenghts in pairs(self.section_lens) do
		table.insert(highlights, lenghts.key + highlights[#highlights])
		table.insert(highlights, lenghts.desc + highlights[#highlights])
	end
	if self.config.help.header then
		vim.api.nvim_buf_add_highlight(self.bufnr, -1, "FugitiveExtSection", 0, 0, -1)
	end
	local starting_line_idx = (self.config.help.header and 1 or 0) + (self.config.help.padding.header and 1 or 0)
	for i = starting_line_idx, num_lines do
		for j = 1, #highlights, 2 do
			vim.api.nvim_buf_add_highlight(self.bufnr, -1, "FugitiveExtKey", i, highlights[j], highlights[j + 1])
			vim.api.nvim_buf_add_highlight(self.bufnr, -1, "FugitiveExtDesc", i, highlights[j + 1], highlights[j + 2])
		end
	end
end

---@return boolean: Whether the help is currently opened (buffer and window are valid)
function FugitiveExtHelp:_is_opened()
	return self.bufnr
			and self.win_id
			and vim.api.nvim_buf_is_valid(self.bufnr)
			and vim.api.nvim_win_is_valid(self.win_id)
		or false
end

return FugitiveExtHelp
