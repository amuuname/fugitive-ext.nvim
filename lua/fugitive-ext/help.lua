---@class FugitiveExtHelp
---@field on boolean indicates whether the user turned on/off the help
---@field content string[] content generated from the `config.help.sections`
---@field section_width SectionWidth max width of key and desc for each section
---@field win_id? number help floating window id
---@field bufnr? number help buffer number
---@field fugitive_bufnr? number fugitive buffer number
---@field fugitive_width? number fugitive window width
---@field fugitive_height? number fugitive window height
---@field config FugitiveExtConfig
local FugitiveExtHelp = {}

FugitiveExtHelp.__index = FugitiveExtHelp

---@alias SectionName string
---@alias SectionWidth { [SectionName]: { key: number, desc: number} }

---@param config FugitiveExtConfig
function FugitiveExtHelp:new(config)
	if config._debug then
		vim.notify("FugitiveExtHelp:new")
	end
	local data = self:setup(config)
	return setmetatable({
		on = config.help.visibility,
		content = data.content,
		section_width = data.section_width,
		win_id = nil,
		bufnr = nil,
		fugitive_bufnr = nil,
		fugitive_width = nil,
		fugitive_height = nil,
		config = config,
	}, self)
end

---@param config FugitiveExtConfig
---@return { content: string[], section_width: SectionWidth }
function FugitiveExtHelp:setup(config)
	if config._debug then
		vim.notify("FugitiveExtHelp:setup")
	end
	local align_str = require("plenary.strings").align_str

	local sections = config.help.sections
	local padding = config.help.padding

	---@type SectionWidth
	local section_width = {}
	local max_num_entries = 0
	for _, section in ipairs(sections) do
		max_num_entries = math.max(max_num_entries, #section.entries)
		local max_key, max_desc = 0, 0
		for _, entry in ipairs(section.entries) do
			max_key = math.max(max_key, #entry[1])
			max_desc = math.max(max_desc, #entry[2])
		end
		section_width[section.title] = { key = max_key, desc = max_desc }
	end

	-- Generate help content
	---@type string[]
	local content = {}

	local header = align_str("", padding.line_leader, false)
	for _, section in ipairs(sections) do
		local len = section_width[section.title].key
			+ padding.key_desc
			+ section_width[section.title].desc
			+ padding.section
		header = header .. align_str(section.title, len, false)
	end
	table.insert(content, header)

	if padding.header then
		table.insert(content, "")
	end

	for i = 1, max_num_entries do
		local line = align_str("", padding.line_leader, false)
		for _, section in ipairs(sections) do
			local entry = section.entries[i] or {}
			local key = entry[1] or ""
			local desc = entry[2] or ""
			line = line
				.. align_str(key, section_width[section.title].key + padding.key_desc, false)
				.. align_str(desc, section_width[section.title].desc + padding.section, false)
		end
		table.insert(content, line)
	end

	if padding.footer then
		table.insert(content, "")
	end

	return { content = content, section_width = section_width }
end

--- Open the help window
---@param opts { force: boolean } -- { force: whether to open the help window regardless of the fugitive window height }
function FugitiveExtHelp:open(opts)
	-- early return if help is already open
	if self:_is_opened() then
		if self.config._debug then
			vim.notify("FugitiveExtHelp:open - early return")
		end
		return
	end
	-- self:close() -- ???

	self.fugitive_width = vim.api.nvim_win_get_width(0)
	self.fugitive_height = vim.api.nvim_win_get_height(0)
	self.fugitive_bufnr = vim.api.nvim_win_get_buf(0)

	-- early return if the fugitive window is too short
	if not opts.force and self.fugitive_height < self.config.help.fugitive_min_height then
		if self.config._debug then
			vim.notify("FugitiveExtHelp:open - window too short")
		end
		return
	end

	if self.config._debug then
		vim.notify("FugitiveExtHelp:open")
	end

	-- create help buffer and window
	self.bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_text(self.bufnr, 0, 0, 0, 0, self.content)
	vim.api.nvim_buf_set_option(self.bufnr, "filetype", "fugitive_ext_help")
	vim.api.nvim_buf_set_option(self.bufnr, "modifiable", false)
	vim.api.nvim_buf_set_option(self.bufnr, "readonly", true)
	self.win_id = vim.api.nvim_open_win(self.bufnr, false, {
		relative = "win",
		anchor = "NW",
		width = vim.api.nvim_win_get_width(0),
		height = #self.content,
		style = "minimal",
		border = { { "─", "WinSeparator" }, { "─", "WinSeparator" }, { "─", "WinSeparator" }, "", "", "", "", "" },
		row = vim.api.nvim_win_get_height(0) - (#self.content + 1), -- #content + #border_lines
		col = 0,
		focusable = false,
		noautocmd = true,
	})

	self:_apply_highlight()
end

--- Close the help window
function FugitiveExtHelp:close()
	local closed = false
	if self:_is_opened() then
		vim.api.nvim_win_close(self.win_id, true)
		vim.api.nvim_buf_delete(self.bufnr, { force = true })
		self.win_id = nil
		self.bufnr = nil
		self.fugitive_bufnr = nil
		self.fugitive_width = nil
		self.fugitive_height = nil
		closed = true
	end
	if self.config._debug then
		vim.notify("FugitiveExtHelp:close -- " .. (closed and "closed" or "not closing"))
	end
end

--- Refresh the help window
function FugitiveExtHelp:refresh()
	-- early return if user turned off the help
	if not self.on then
		if self.config._debug then
			vim.notify("FugitiveExtHelp:refresh - early return")
		end
		return
	end
	if self:_fugitive_resized() then
		if self.config._debug then
			vim.notify("FugitiveExtHelp:refresh - resized")
		end
		self:close()
		self:open({ force = false })
	else
		if self.config._debug then
			vim.notify("FugitiveExtHelp:refresh - not resized")
		end
		self:open({ force = false })
	end
end

--- Toggle the help window
function FugitiveExtHelp:toggle()
	if self:_is_opened() then
		if self.config._debug then
			vim.notify("FugitiveExtHelp:toggle - off")
		end
		self:close()
		self.on = true
	else
		if self.config._debug then
			vim.notify("FugitiveExtHelp:toggle - on")
		end
		self:open({ force = true })
		self.on = false
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
	local sections = self.config.help.sections
	local widths = self.section_width
	local padding = self.config.help.padding
	local hl_idxs = { padding.line_leader }

	for _, section in ipairs(sections) do
		local title = section.title
		table.insert(hl_idxs, widths[title].key + padding.key_desc + hl_idxs[#hl_idxs])
		table.insert(hl_idxs, widths[title].desc + padding.section + hl_idxs[#hl_idxs])
	end

	if self.config.help.header then
		vim.api.nvim_buf_add_highlight(self.bufnr, -1, "FugitiveExtSection", 0, 0, -1)
	end
	local start = (self.config.help.header and 1 or 0) + (self.config.help.padding.header and 1 or 0)
	local end_ = start + num_lines
	for i = start, end_ do
		for j = 1, #hl_idxs - 1, 2 do
			vim.api.nvim_buf_add_highlight(self.bufnr, -1, "FugitiveExtKey", i, hl_idxs[j], hl_idxs[j + 1])
			vim.api.nvim_buf_add_highlight(self.bufnr, -1, "FugitiveExtDesc", i, hl_idxs[j + 1], hl_idxs[j + 2])
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
