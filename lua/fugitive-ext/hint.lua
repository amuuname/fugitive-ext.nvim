---@class FugitiveExtHint
---@field content string[] content generated from the `config.hint.sections`
---@field section_width SectionWidth max width of key and desc for each section
---@field win_id? number hint floating window id
---@field bufnr? number hint buffer number
---@field fugitive_width? number fugitive window width
---@field fugitive_height? number fugitive window height
---@field config FugitiveExtConfig
local FugitiveExtHint = {}

FugitiveExtHint.__index = FugitiveExtHint

---@alias SectionName string
---@alias SectionWidth { [SectionName]: { key: number, desc: number} }

---@param config FugitiveExtConfig
function FugitiveExtHint:new(config)
    if config._debug then
        vim.notify("FugitiveExtHint:new", 3)
    end
    local data = self:generate_data(config)
    return setmetatable({
        content = data.content,
        section_width = data.section_width,
        win_id = nil,
        bufnr = nil,
        fugitive_width = nil,
        fugitive_height = nil,
        config = config,
    }, self)
end

---@param config FugitiveExtConfig
---@return { content: string[], section_width: SectionWidth }
function FugitiveExtHint:generate_data(config)
    if config._debug then
        vim.notify("FugitiveExtHint:generate_data", 3)
    end
    local align_str = require("plenary.strings").align_str

    local sections = config.hint.sections
    local padding = config.hint.padding

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

    -- Generate hint content
    ---@type string[]
    local content = {}

    if config.hint.title then
        local header = align_str("", padding.line_leader, false)
        for _, section in ipairs(sections) do
            local len = section_width[section.title].key
                + padding.key_desc
                + section_width[section.title].desc
                + padding.section
            header = header .. align_str(section.title, len, false)
        end
        table.insert(content, header)
    end
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

--- Open the hint
---@param opts { force: boolean } -- { force: whether to open the hint regardless of the fugitive window height }
function FugitiveExtHint:open(opts)
    -- early return if hint is already open
    if self:_is_opened() then
        if self.config._debug then
            vim.notify("FugitiveExtHint:open - early return")
        end
        return
    end

    self.fugitive_width = vim.api.nvim_win_get_width(0)
    self.fugitive_height = vim.api.nvim_win_get_height(0)

    -- early return if the fugitive window is too short
    if not opts.force and self.fugitive_height < self.config.hint.fugitive_min_height then
        if self.config._debug then
            vim.notify("FugitiveExtHint:open - window too short")
        end
        return
    end

    if self.config._debug then
        vim.notify("FugitiveExtHint:open")
    end

    -- create hint buffer and window
    self.bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_text(self.bufnr, 0, 0, 0, 0, self.content)
    vim.api.nvim_set_option_value("filetype", "fugitive_ext_hint", { buf = self.bufnr })
    vim.api.nvim_set_option_value("modifiable", false, { buf = self.bufnr })
    vim.api.nvim_set_option_value("readonly", true, { buf = self.bufnr })
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

--- Close the hint
function FugitiveExtHint:close()
    local closed = false
    if self:_is_opened() then
        vim.api.nvim_win_close(self.win_id, true)
        vim.api.nvim_buf_delete(self.bufnr, { force = true })
        self.win_id = nil
        self.bufnr = nil
        self.fugitive_width = nil
        self.fugitive_height = nil
        vim.opt_local.scrolloff = -1
        closed = true
    end
    if self.config._debug then
        vim.notify("FugitiveExtHint:close -- " .. (closed and "closed" or "not closing"))
    end
end

--- Refresh the hint
function FugitiveExtHint:refresh()
    -- early return if user turned off the hint
    if not self.config.hint.visibility then
        if self.config._debug then
            vim.notify("FugitiveExtHint:refresh - early return")
        end
        return
    end
    if self:_fugitive_resized() then
        if self.config._debug then
            vim.notify("FugitiveExtHint:refresh - resized")
        end
        self:close()
        self:open({ force = false })
    else
        if self.config._debug then
            vim.notify("FugitiveExtHint:refresh - not resized")
        end
        self:open({ force = false })
    end
end

--- Toggle the hint
function FugitiveExtHint:toggle()
    if self:_is_opened() then
        if self.config._debug then
            vim.notify("FugitiveExtHint:toggle - off")
        end
        self:close()
        self.config.hint.visibility = false
    else
        if self.config._debug then
            vim.notify("FugitiveExtHint:toggle - on")
        end
        self:open({ force = true })
        self.config.hint.visibility = true
    end
end

--- Check if the fugitive window is resized
function FugitiveExtHint:_fugitive_resized()
    return self.fugitive_width ~= vim.api.nvim_win_get_width(0)
        or self.fugitive_height ~= vim.api.nvim_win_get_height(0)
end

--- Apply syntax highlighting to the hint
function FugitiveExtHint:_apply_highlight()
    local num_lines = #self.content
        - (self.config.hint.title and 1 or 0)
        - (self.config.hint.padding.header and 1 or 0)
        - (self.config.hint.padding.footer and 1 or 0)

    -- prevent cursor from going below the hint
    local winnr = vim.api.nvim_get_current_win()
    vim.api.nvim_set_option_value("scrolloff", #self.content + 1, { win = winnr })

    -- apply syntax highlighting
    local sections = self.config.hint.sections
    local widths = self.section_width
    local padding = self.config.hint.padding
    local hl_idxs = { padding.line_leader }

    for _, section in ipairs(sections) do
        table.insert(hl_idxs, widths[section.title].key + padding.key_desc + hl_idxs[#hl_idxs])
        table.insert(hl_idxs, widths[section.title].desc + padding.section + hl_idxs[#hl_idxs])
    end

    if self.config.hint.title then
        vim.api.nvim_buf_add_highlight(self.bufnr, -1, "FugitiveExtSection", 0, 0, -1)
    end
    local start = (self.config.hint.title and 1 or 0) + (self.config.hint.padding.header and 1 or 0)
    local end_ = start + num_lines
    for i = start, end_ do
        for j = 1, #hl_idxs - 1, 2 do
            vim.api.nvim_buf_add_highlight(self.bufnr, -1, "FugitiveExtKey", i, hl_idxs[j], hl_idxs[j + 1])
            vim.api.nvim_buf_add_highlight(self.bufnr, -1, "FugitiveExtDesc", i, hl_idxs[j + 1], hl_idxs[j + 2])
        end
    end
end

---@return boolean: Whether the hint is currently opened (buffer and window are valid)
function FugitiveExtHint:_is_opened()
    return self.bufnr
            and self.win_id
            and vim.api.nvim_buf_is_valid(self.bufnr)
            and vim.api.nvim_win_is_valid(self.win_id)
        or false
end

return FugitiveExtHint
