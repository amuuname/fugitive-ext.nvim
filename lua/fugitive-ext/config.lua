---@diagnostic disable: unused-local

---@class FugitiveExtConfig
---@field fugitive FugitiveConfig
---@field hint FugitiveExtHintConfig
---@field _debug boolean
local Config = {}

---@class FugitiveConfig
---@field line_number boolean
---@field relative_number boolean
---@field hint_header string[][] -- list of header and keymap (i.e. { "Help:", "g?" }, { "Hint:", "?" })
---@field hint_header_delimiter string -- Delimiter between hint header and keymap

---@class FugitiveExtHintConfig
---@field visibility boolean -- Default visibility of hint when opening fugitive
---@field header boolean -- Display hint section header
---@field separator boolean -- Display separator between fugitive and hint
---@field fugitive_min_height number -- Minimum height of fugitive to show hint
---@field sections HintTable -- Entries to display in the hint
---@field padding Padding -- Padding settings

---@alias HintTable HintSection[] List of hint sections
---@alias HintSection { title: string, entries: HintItem[] } Section with title and entries
---@alias HintItem string[] Keymap, description tuple

---@class Padding
---@field header boolean -- Empty line after header
---@field footer boolean -- Empty line as a footer
---@field line_leader number -- Number of spaces to pad the beginning of each line
---@field key_desc number -- Number of spaces between key and description
---@field section number -- Number of spaces between sections

---@class FugitiveExtPartialConfig
---@field fugitive? FugitiveConfig
---@field hint? FugitiveExtHintConfig
---@field _debug? boolean

---@class FugitiveExtPartialHintConfig
---@field visibility? boolean
---@field header? boolean
---@field separator? boolean
---@field fugitive_min_height? number
---@field sections? HintTable
---@field padding? Padding

---@return HintTable: Default hint sections
local function default_sections()
	local sections = {
		{
			title = "Navigation",
			entries = {
				{ "gU", "untracked" },
				{ "gu", "unstaged" },
				{ "gs", "staged" },
				{ "gp", "unpushed" },
				{ "gP", "unpulled" },
				{ "gr", "rebasing" },
				{ "gi", "exclude/ignore" },
				{ "gI", "exclude/ignore++" },
				{ "i", "next hunk & exp" },
				{ "[c, ]c", "expand prev/next" },
				{ "(, )", "goto prev/next" },
			},
		},

		{
			title = "Stage/Stash",
			entries = {
				{ "s", "stage" },
				{ "u", "unstage" },
				{ "a", "stage/unstage" },
				{ "-", "stage/unstage" },
				{ "X", "discard" },
				{ "=", "inline diff" },
				{ "I", "patch" },
				{ "coo", "checkout" },
				{ "czz", "stash push" },
				{ "czp", "stash pop" },
				{ "cz<sp>", ":Git stash" },
			},
		},

		{
			title = "Commit",
			entries = {
				{ "cc", "commit" },
				{ "ca", "amend" },
				{ "ce", "amend no-edit" },
				{ "cw", "reword" },
				{ "cf", "fixup!" },
				{ "cs", "squash!" },
				{ "crc", "revert commit" },
				{ "c<sp>", ":Git commit" },
				{ "cr<sp>", ":Git revert" },
				{ "cm<cp>", ":Git merge" },
				{ "P", ":Git push" },
			},
		},

		{
			title = "Rebase",
			entries = {
				{ "ri", "interactive" },
				{ "rr", "continue" },
				{ "rs", "skip commit" },
				{ "ra", "abort" },
				{ "re", "edit todo" },
				{ "rw", "mark reword" },
				{ "rm", "mark edit" },
				{ "rd", "mark drop" },
				{ "r<sp>", ":Git rebase" },
			},
		},
	}
	return sections
end

---@return FugitiveExtConfig
function Config.get_default_config()
	local sections = default_sections()
    -- stylua: ignore
	return {
		fugitive = {
			line_number = false,      -- vim.wo.number
			relative_number = false,  -- vim.wo.relativenumber
            hint_header = { { "Help:", "g?" }, { "Hint:", "?" }, },
            hint_header_delimiter = "  ",
		},
		hint = {                      -- config for hint
			visibility = true,        -- Default visibility of hint when opening fugitive
			header = true,            -- Display hint section header
			separator = true,         -- Display separator between fugitive and hint
			fugitive_min_height = 40, -- Minimum height of fugitive to show hint
			padding = {
				header = true,        -- Empty line after header
				footer = true,        -- Empty line before footer
				line_leader = 2,      -- Number of spaces to pad the beginning of each line
				key_desc = 2,         -- Number of spaces between key and description
				section = 5,          -- Number of spaces between sections
			},
			sections = sections,      -- entries to display in the hint

		},
		_debug = false, -- Debug mode
	}
end

---@param partial_config? FugitiveExtPartialConfig
---@param config? FugitiveExtConfig
---@return FugitiveExtConfig
function Config.merge_config(partial_config, config)
	partial_config = partial_config or {}
	config = config or Config.get_default_config()
	for k, v in pairs(partial_config) do
		if k == "fugitive" then
			config.fugitive = vim.tbl_extend("force", config.fugitive, v)
		elseif k == "hint" then
			config.hint = vim.tbl_extend("force", config.hint, v)
		elseif k == "_debug" then
			config._debug = v
		else
			config[k] = vim.tbl_extend("force", config[k] or {}, v)
		end
	end
	return config
end

return Config
