---@diagnostic disable: unused-local

---@class FugitiveExtConfig
---@field fugitive FugitiveConfig
---@field help FugitiveExtHelpConfig
---@field _debug boolean
local Config = {}

---@class FugitiveConfig
---@field line_number boolean
---@field relative_number boolean
---@field keymaps { [string]: FugitiveExtAction }

---@class FugitiveExtHelpConfig
---@field visibility boolean -- Default visibility of help window when opening fugitive
---@field header boolean -- Display help section header
---@field separator boolean -- Display separator between fugitive and help window
---@field fugitive_min_height number -- Minimum height of fugitive to show help window
---@field sections HelpTable -- Entries to display in the help window
---@field padding Padding -- Padding settings

---@alias HelpTable HelpSection[] List of help sections
---@alias HelpSection { title: string, entries: HelpItem[] } Section with title and entries
---@alias HelpItem string[] Keymap, description tuple

---@class Padding
---@field header boolean -- Empty line after header
---@field footer boolean -- Empty line as a footer
---@field line_leader number -- Number of spaces to pad the beginning of each line
---@field key_desc number -- Number of spaces between key and description
---@field section number -- Number of spaces between sections

---@class FugitiveExtPartialConfig
---@field fugitive? FugitiveConfig
---@field help? FugitiveExtHelpConfig
---@field _debug? boolean

---@class FugitiveExtPartialHelpConfig
---@field visibility? boolean
---@field header? boolean
---@field separator? boolean
---@field fugitive_min_height? number
---@field sections? HelpTable
---@field padding? Padding

---@return HelpTable: Default help sections
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
	return {
		fugitive = {
			line_number = false, -- vim.wo.number
			relative_number = false, -- vim.wo.relativenumber
			keymaps = vim.defaulttable(),
            _debug = false,
		},
        -- config for help window
		help = {
			visibility = true, -- Default visibility of help window when opening fugitive
            header = true, -- Display help section header
            separator = true, -- Display separator between fugitive and help window
            fugitive_min_height = 40, -- Minimum height of fugitive to show help window
            padding = {
				header = true, -- Empty line after header
				footer = true, -- Empty line before footer
				line_leader = 2, -- Number of spaces to pad the beginning of each line
				key_desc = 2, -- Number of spaces between key and description
				section = 5, -- Number of spaces between sections
			},
			-- entries to display in the help window
			sections = sections,
		},
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
		elseif k == "help" then
			config.help = vim.tbl_extend("force", config.help, v)
        elseif k == "_debug" then
            config._debug = v
		else
			config[k] = vim.tbl_extend("force", config[k] or {}, v)
		end
	end
	return config
end

return Config
