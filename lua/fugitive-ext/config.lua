---@diagnostic disable: unused-local

---@class FugitiveExtConfig
---@field fugitive FugitiveConfig
---@field help FugitiveExtHelpConfig
local Config = {}

---@class FugitiveConfig
---@field line_number boolean
---@field relative_number boolean
---@field keymaps { [string]: FugitiveExtAction }

---@class FugitiveExtHelpConfig
---@field visibility boolean
---@field header boolean
---@field separator boolean
---@field min_fugitive_win_height number
---@field sections HelpTable
---@field padding Padding

---@alias HelpItem string[] Keymap, description tuple
---@alias HelpTable { [string]: HelpItem[] } Key: Section, Val: list of help items

--
---@class FugitiveExtPartialConfig
---@field fugitive? FugitiveConfig
---@field help? FugitiveExtHelpConfig

---@class FugitiveExtPartialHelpConfig
---@field visibility? boolean
---@field header? boolean
---@field separator? boolean
---@field min_fugitive_win_height? number
---@field sections? HelpTable
---@field padding? Padding

---@return FugitiveExtConfig
function Config.get_default_config()
	vim.notify("Config.get_default_config")
	return {
		fugitive = {
			line_number = false, -- vim.wo.number
			relative_number = false, -- vim.wo.relativenumber
			keymaps = {},
		},

		help = {
			visibility = true, -- automatically open help when fugitive opens
			header = true, -- display help section header
			separator = true, -- display separator between fugitive and help
			min_fugitive_win_height = 40, -- Minimum height of fugitive to show help menu.
			padding = {
				header = true, -- empty line after header
				footer = true, -- empty line before footer
				line_leader = 2, -- number of spaces to pad the beginning of each line
				key_desc = 2, -- number of spaces between key and description
				section = 5, -- number of spaces between sections
			},
			-- tips to display in the help window
			sections = {
				nav = {
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
				staging = {
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
				commit = {
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
				rebase_stash = {
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
		},
	}
end

---@param partial_config FugitiveExtPartialConfig
---@param config FugitiveExtConfig
---@return FugitiveExtConfig
function Config.merge_config(partial_config, config)
	vim.notify("Config.merge_config")
	partial_config = partial_config or {}
	config = config or Config.get_default_config()
	for k, v in pairs(partial_config) do
		if k == "fugitive" then
			config.fugitive = vim.tbl_extend("force", config.fugitive, v)
		elseif k == "help" then
			config.help = vim.tbl_extend("force", config.help, v)
		else
			config[k] = vim.tbl_extend("foxce", config[k] or {}, v)
		end
	end
	return config
end

return Config
