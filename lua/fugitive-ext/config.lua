---@class FugitiveExtConfig
---@field fugitive FugitiveConfig
---@field hint FugitiveExtHintConfig
---@field _debug boolean
local Config = {}

---@class FugitiveConfig
---@field line_number boolean                                --  show/hide line number in fugitive buffer
---@field relative_number boolean                            --  show/hide relative number in fugitive buffer
---@field help_header string[][]                             --  list of header and keymap (i.e. { "Help:", "g?" }, { "Hint:", "?" })
---@field help_header_delimiter string                       --  Delimiter between hint header and keymap

---@class FugitiveExtHintConfig
---@field toggle_key string                                  --  Keymap to toggle hint
---@field visibility boolean                                 --  Default visibility of hint when opening fugitive
---@field title boolean                                      --  Display hint section title
---@field fugitive_min_height number                         --  Minimum height of fugitive to show hint
---@field sections HintSection[]                             --  Entries to display in the hint
---@field padding PaddingConfig                              --  Padding settings

---@alias HintSection { title: string, entries: HintItem[] } --  Section title and entries
---@alias HintItem string[]                                  --  [ Keymap, description ] tuple

---@class PaddingConfig
---@field header boolean                                     --  Empty line after header
---@field footer boolean                                     --  Empty line as a footer
---@field line_leader number                                 --  Number of spaces to pad the beginning of each line
---@field key_desc number                                    --  Number of spaces between key and description
---@field section number                                     --  Number of spaces between sections

---@class FugitiveExtPartialConfig
---@field fugitive? FugitivePartialConfig
---@field hint? FugitiveExtHintPartialConfig
---@field _debug? boolean

---@class FugitivePartialConfig
---@field line_number? boolean                               --  show/hide line number in fugitive buffer
---@field relative_number? boolean                           --  show/hide relative number in fugitive buffer
---@field help_header? string[][]                            --  list of header and keymap (i.e. { "Help:", "g?" }, { "Hint:", "?" })
---@field help_header_delimiter? string                      --  Delimiter between hint header and keymap

---@class FugitiveExtHintPartialConfig
---@field toggle_key? string                                 --  Keymap to toggle hint
---@field visibility? boolean                                --  Default visibility of hint when opening fugitive
---@field title? boolean                                     --  Display hint section title
---@field fugitive_min_height? number                        --  Minimum height of fugitive to show hint
---@field sections? HintSection[]                            --  Entries to display in the hint
---@field padding? PaddingPartialConfig                      --  Padding settings

---@class PaddingPartialConfig
---@field header? boolean                                    --  Empty line after header
---@field footer? boolean                                    --  Empty? line as a footer
---@field line_leader? number                                --  Number of spaces to pad the beginning of each line
---@field key_desc? number                                   --  Number of spaces between key and description
---@field section? number                                    --  Number of spaces between sections

---@return FugitiveExtConfig
function Config.get_default_config()
    -- stylua: ignore start
    return {
        -- config for fugitive buffer
        fugitive = {
            line_number = false,          -- `vim.wo.number` for fugitive buffer
            relative_number = false,      -- `vim.wo.relativenumber` for fugitive buffer
            help_header = {               -- Help header line to replace
                { "Help:", "g?" },
                { "Hint:", "?" },
            },
            help_header_delimiter = "  ", -- Delimiter between each help_header entries
        },
        -- config for hint
        hint = {
            toggle_key = "?",             -- Keymap to toggle hint
            visibility = true,            -- Default visibility of hint when opening fugitive
            title = true,                 -- Display hint section titles
            fugitive_min_height = 40,     -- Minimum height of fugitive to show hint
            padding = {
                header = true,            -- Empty line before hint
                footer = true,            -- Empty line after hint
                line_leader = 2,          -- Number of spaces to pad the beginning of each line
                key_desc = 1,             -- Number of spaces between key and description
                section = 3,              -- Number of spaces between sections
            },
            sections = {                  -- entries to display in the hint
                {
                    title = "Navigation",
                    entries = {
                        { "gu", "untracked" },
                        { "gU", "unstaged" },
                        { "gs", "staged" },
                        { "gp", "unpushed" },
                        { "gP", "unpulled" },
                        { "gr", "rebasing" },
                        { "gi", "exclude/ignore" },
                        { "gI", "exclude/ignore++" },
                        { "i", "expand next" },
                        { "(, )", "goto prev/next" },
                        { "[c, ]c", "expand prev/next" },
                    },
                },
                {
                    title = "Stage/Stash",
                    entries = {
                        { "s", "stage" },
                        { "u", "unstage" },
                        { "-, a", "stage/unstage" },
                        { "X", "discard" },
                        { "=", "inline diff" },
                        { "I", "patch" },
                        { "coo", "checkout" },
                        { "czz, czw", "push stash" },
                        { "czp", "pop stash" },
                        { "cza", "apply stash" },
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
                        { "cf, cF", "fixup!" },
                        { "cs, cS", "squash!" },
                        { "crc", "revert commit" },
                        { "c<sp>", ":Git commit" },
                        { "cr<sp>", ":Git revert" },
                        { "cm<cp>", ":Git merge" },
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
            },
        },
        _debug = false, -- Debug mode
    }
    -- stylua: ignore end
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
            config.hint = vim.tbl_deep_extend("force", config.hint, v)
        elseif k == "_debug" then
            config._debug = v
        else
            config[k] = vim.tbl_extend("force", config[k] or {}, v)
        end
    end
    return config
end

return Config
