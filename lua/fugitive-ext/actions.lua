-- stylua: ignore start

--- Fugitive actions
---@alias FugitiveExtAction string | fun(): nil

---Mappings for Fugitive actions
---@class (exact) FugitiveExtActions
---@field stage                        FugitiveExtAction
---@field unstage                      FugitiveExtAction
---@field unstage_all                  FugitiveExtAction
---@field toggle_stage                 FugitiveExtAction
---@field discard                      FugitiveExtAction
---@field inline_diff                  FugitiveExtAction
---@field patch                        FugitiveExtAction
---@field exclude_ignore_add           FugitiveExtAction
---@field exclude_ignore_open          FugitiveExtAction
---@field discard_confirm              FugitiveExtAction
---@field goto_untracked               FugitiveExtAction
---@field goto_unstaged                FugitiveExtAction
---@field goto_staged                  FugitiveExtAction
---@field goto_unpushed                FugitiveExtAction
---@field goto_unpulled                FugitiveExtAction
---@field goto_rebasing                FugitiveExtAction
---@field goto_prev_hunk               FugitiveExtAction
---@field goto_next_hunk               FugitiveExtAction
---@field expand_prev_hunk             FugitiveExtAction
---@field expand_next_hunk             FugitiveExtAction
---@field collapse_curr_goto_prev      FugitiveExtAction
---@field collapse_curr_goto_next      FugitiveExtAction
---@field collapse_curr_expand_prev    FugitiveExtAction
---@field collapse_curr_expand_next    FugitiveExtAction
---@field goto_prev_section            FugitiveExtAction
---@field goto_next_section            FugitiveExtAction
---@field goto_prev_section_end        FugitiveExtAction
---@field goto_next_section_end        FugitiveExtAction
---@field commit                       FugitiveExtAction
---@field commit_amend                 FugitiveExtAction
---@field commit_amend_no_edit         FugitiveExtAction
---@field commit_reword                FugitiveExtAction
---@field fixup_commit                 FugitiveExtAction
---@field fixup_commit_rebase          FugitiveExtAction
---@field squash_commit                FugitiveExtAction
---@field squash_commit_rebase         FugitiveExtAction
---@field squash_edit_msg              FugitiveExtAction
---@field commit_cmdline               FugitiveExtAction
---@field revert_commit                FugitiveExtAction
---@field revert_no_commit             FugitiveExtAction
---@field revert_cmdline               FugitiveExtAction
---@field merge_cmdline                FugitiveExtAction
---@field commit_amend_confirm         FugitiveExtAction
---@field commit_amend_no_edit_confirm FugitiveExtAction
---@field commit_reword_confirm        FugitiveExtAction
---@field fixup_commit_confirm         FugitiveExtAction
---@field fixup_commit_rebase_confirm  FugitiveExtAction
---@field squash_commit_confirm        FugitiveExtAction
---@field squash_commit_rebase_confirm FugitiveExtAction
---@field squash_edit_msg_confirm      FugitiveExtAction
---@field revert_commit_confirm        FugitiveExtAction
---@field revert_no_commit_confirm     FugitiveExtAction
---@field checkout                     FugitiveExtAction
---@field checkout_cmdline             FugitiveExtAction
---@field branch_cmdline               FugitiveExtAction
---@field checkout_confirm             FugitiveExtAction
---@field stash_push                   FugitiveExtAction
---@field stash_pop                    FugitiveExtAction
---@field stash_apply                  FugitiveExtAction
---@field stash_push_idx               FugitiveExtAction
---@field stash_pop_idx                FugitiveExtAction
---@field stash_apply_idx              FugitiveExtAction
---@field stash_cmdline                FugitiveExtAction
---@field stash_push_confirm           FugitiveExtAction
---@field stash_pop_confirm            FugitiveExtAction
---@field stash_apply_confirm          FugitiveExtAction
---@field stash_push_idx_confirm       FugitiveExtAction
---@field stash_pop_idx_confirm        FugitiveExtAction
---@field stash_apply_idx_confirm      FugitiveExtAction
---@field rebase_interactive           FugitiveExtAction
---@field rebase_auto_squash           FugitiveExtAction
---@field rebase_upstream              FugitiveExtAction
---@field rebase_push                  FugitiveExtAction
---@field rebase_continue              FugitiveExtAction
---@field rebase_skip_commit           FugitiveExtAction
---@field rebase_abort                 FugitiveExtAction
---@field rebase_edit_todo             FugitiveExtAction
---@field rebase_mark_reword           FugitiveExtAction
---@field rebase_mark_edit             FugitiveExtAction
---@field rebase_mark_drop             FugitiveExtAction
---@field rebase_cmdline               FugitiveExtAction
---@field rebase_interactive_confirm   FugitiveExtAction
---@field rebase_auto_squash_confirm   FugitiveExtAction
---@field rebase_upstream_confirm      FugitiveExtAction
---@field rebase_push_confirm          FugitiveExtAction
---@field rebase_continue_confirm      FugitiveExtAction
---@field rebase_skip_commit_confirm   FugitiveExtAction
---@field rebase_abort_confirm         FugitiveExtAction
---@field rebase_edit_todo_confirm     FugitiveExtAction
---@field rebase_mark_reword_confirm   FugitiveExtAction
---@field rebase_mark_edit_confirm     FugitiveExtAction
---@field rebase_mark_drop_confirm     FugitiveExtAction
---@field push_cmdline                 FugitiveExtAction
---@field pull_cmdline                 FugitiveExtAction
---@field dot                          FugitiveExtAction
---@field nop                          FugitiveExtAction
local Actions = {}

--- Feed escaped keys
---@param keys string
local function feed_escaped_keys(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), "n", true)
end

--- Strip whitespace
local function trim(input)
    return input and string.match(input, "^%s*(.-)%s*$")
end

--- Conform before performing action
local function confirm_action(action, prompt)
    return function()
        vim.ui.input({ prompt = prompt }, function(input)
            if trim(input) == "y" then
                feed_escaped_keys(action)
            end
        end)
    end
end

--- [[ Staging ]]

Actions.stage               = "<Plug>fugitive:s"  -- Stage
Actions.unstage             = "<Plug>fugitive:u"  -- Unstage
Actions.unstage_all         = "<Plug>fugitive:U"  -- Unstage all
Actions.toggle_stage        = "<Plug>fugitive:a"  -- Toggle stage/unstage
Actions.discard             = "<Plug>fugitive:X"  -- Discard changes
Actions.inline_diff         = "<Plug>fugitive:="  -- Inline diff
Actions.patch               = "<Plug>fugitive:I"  -- Patch
Actions.exclude_ignore_add  = "<Plug>fugitive:gI" -- Open `.git/info/exclude` or `.gitignore` and add current file under the cursor
Actions.discard_confirm = confirm_action(Actions.discard, "Are you sure to discard changes? (y/n)")

--- [[ Navigation ]]

Actions.goto_untracked            = "<Plug>fugitive:gu"                 -- Goto untracked
Actions.goto_unstaged             = "<Plug>fugitive:gU"                 -- Goto unstaged
Actions.goto_staged               = "<Plug>fugitive:gs"                 -- Goto staged
Actions.goto_unpushed             = "<Plug>fugitive:gp"                 -- Goto unpushed
Actions.goto_unpulled             = "<Plug>fugitive:gP"                 -- Goto unpulled
Actions.goto_rebasing             = "<Plug>fugitive:gr"                 -- Goto rebasing
Actions.goto_prev_hunk            = "<Plug>fugitive:("                  -- Jump to previous hunk
Actions.goto_next_hunk            = "<Plug>fugitive:)"                  -- Jump to next hunk
Actions.expand_prev_hunk          = "<Plug>fugitive:[c"                 -- Jump and expand previous hunk
Actions.expand_next_hunk          = "<Plug>fugitive:]c"                 -- Jump and expand next hunk
Actions.collapse_curr_goto_prev   = "<Plug>fugitive:[m"                 -- Collapse current and goto previous
Actions.collapse_curr_goto_next   = "<Plug>fugitive:]m"                 -- Collapse current and goto next
Actions.collapse_curr_expand_prev = "<Plug>fugitive:[m<Plug>fugitive:i" -- Collapse current and expand previous
Actions.collapse_curr_expand_next = "<Plug>fugitive:]m<Plug>fugitive:i" -- Collapse current and expand next
Actions.goto_prev_section         = "<Plug>fugitive:[["                 -- Previous section
Actions.goto_next_section         = "<Plug>fugitive:]]"                 -- Next section
Actions.goto_prev_section_end     = "<Plug>fugitive:[]"                 -- Previous section end
Actions.goto_next_section_end     = "<Plug>fugitive:]["                 -- Next section end
Actions.exclude_ignore_open       = "<Plug>fugitive:gi"                 -- Open `.git/info/exclude` or `.gitignore`

-- [[ Commit ]]

Actions.commit               = "<Plug>fugitive:cc"        -- Commit
Actions.commit_amend         = "<Plug>fugitive:ca"        -- Commit --amend
Actions.commit_amend_no_edit = "<Plug>fugitive:ce"        -- Commit --amend --no-edit
Actions.commit_reword        = "<Plug>fugitive:cw"        -- Commit reword
Actions.fixup_commit         = "<Plug>fugitive:cf"        -- Fixup commit
Actions.fixup_commit_rebase  = "<Plug>fugitive:cF"        -- Fixup commit then rebase
Actions.squash_commit        = "<Plug>fugitive:cs"        -- Squash commit
Actions.squash_commit_rebase = "<Plug>fugitive:cS"        -- Squash commit then rebase
Actions.squash_edit_msg      = "<Plug>fugitive:cA"        -- Squash commit with edit message
Actions.commit_cmdline       = "<Plug>fugitive:c<space>"  -- :Git commit
Actions.revert_commit        = "<Plug>fugitive:crc"       -- Revert commit `git revert`
Actions.revert_no_commit     = "<Plug>fugitive:crn"       -- Revert commit `git revert --no-commit`
Actions.revert_cmdline       = "<Plug>fugitive:cr<space>" -- :Git revert
Actions.merge_cmdline        = "<Plug>fugitive:cm<space>" -- :Git merge
Actions.commit_amend_confirm         = confirm_action(Actions.commit_amend,         "Are you sure to `commit --amend`? (y/n)")
Actions.commit_amend_no_edit_confirm = confirm_action(Actions.commit_amend_no_edit, "Are you sure to `commit --amend --no-edit`? (y/n)")
Actions.commit_reword_confirm        = confirm_action(Actions.commit_reword,        "Are you sure to `commit --amend --only`? (y/n)")
Actions.fixup_commit_confirm         = confirm_action(Actions.fixup_commit,         "Are you sure to `fixup!`? (y/n)")
Actions.fixup_commit_rebase_confirm  = confirm_action(Actions.fixup_commit_rebase,  "Are you sure to `fixup!` then rebase? (y/n)")
Actions.squash_commit_confirm        = confirm_action(Actions.squash_commit,        "Are you sure to `squash!`? (y/n)")
Actions.squash_commit_rebase_confirm = confirm_action(Actions.squash_commit_rebase, "Are you sure to `squash!` then rebase? (y/n)")
Actions.squash_edit_msg_confirm      = confirm_action(Actions.squash_edit_msg,      "Are you sure to `squash!` with edit message? (y/n)")
Actions.revert_commit_confirm        = confirm_action(Actions.revert_commit,        "Are you sure to `revert commit`? (y/n)")
Actions.revert_no_commit_confirm     = confirm_action(Actions.revert_no_commit,     "Are you sure to `revert commit --no-commit`? (y/n)")

-- [[ Checkout/Branch ]]

Actions.checkout         = "<Plug>fugitive:coo"       -- Checkout
Actions.checkout_cmdline = "<Plug>fugitive:co<space>" -- :Git checkout
Actions.branch_cmdline   = "<Plug>fugitive:cb<space>" -- :Git branch
Actions.checkout_confirm = confirm_action(Actions.checkout, "Are you sure to checkout commit? (y/n)")

--- [[ Stashing ]]

Actions.stash_push              = "<Plug>fugitive:czz"       -- Stash push
Actions.stash_pop               = "<Plug>fugitive:czP"       -- Pop stash
Actions.stash_apply             = "<Plug>fugitive:czA"       -- Apply stash
Actions.stash_push_idx          = "<Plug>fugitive:czw"       -- Stash push (keep index)
Actions.stash_pop_idx           = "<Plug>fugitive:czp"       -- Pop stash (preserve index)
Actions.stash_apply_idx         = "<Plug>fugitive:cza"       -- Apply stash (preserve index)
Actions.stash_cmdline           = "<Plug>fugitive:cz<space>" -- Stash cmdline
Actions.stash_push_confirm      = confirm_action(Actions.stash_push,      "Are you sure to push stash? (y/n)")
Actions.stash_pop_confirm       = confirm_action(Actions.stash_pop,       "Are you sure to pop stash? (y/n)")
Actions.stash_apply_confirm     = confirm_action(Actions.stash_apply,     "Are you sure to apply stash? (y/n)")
Actions.stash_push_idx_confirm  = confirm_action(Actions.stash_push_idx,  "Are you sure to push stash (keeping index)? (y/n)")
Actions.stash_pop_idx_confirm   = confirm_action(Actions.stash_pop_idx,   "Are you sure to pop stash (preserving index)? (y/n)")
Actions.stash_apply_idx_confirm = confirm_action(Actions.stash_apply_idx, "Are you sure to apply stash (preserving index)? (y/n)")

--- [[ Rebase ]]

Actions.rebase_interactive = "<Plug>fugitive:ri"       -- Interactive rebase
Actions.rebase_auto_squash = "<Plug>fugitive:rf"       -- Auto squash rebase
Actions.rebase_upstream    = "<Plug>fugitive:ru"       -- Rebase against @{upstream}
Actions.rebase_push        = "<Plug>fugitive:rp"       -- Rebase against @{push}
Actions.rebase_continue    = "<Plug>fugitive:rr"       -- Continue rebase
Actions.rebase_skip_commit = "<Plug>fugitive:rs"       -- Skip current commit
Actions.rebase_abort       = "<Plug>fugitive:ra"       -- Abort rebase
Actions.rebase_edit_todo   = "<Plug>fugitive:re"       -- Edit todo
Actions.rebase_mark_reword = "<Plug>fugitive:rw"       -- Interactive rebase (Mark reword)
Actions.rebase_mark_edit   = "<Plug>fugitive:rm"       -- Interactive rebase (Mark edit)
Actions.rebase_mark_drop   = "<Plug>fugitive:rd"       -- Interactive rebase (Mark drop)
Actions.rebase_cmdline     = "<Plug>fugitive:r<space>" -- Rebase cmdline
Actions.rebase_interactive_confirm = confirm_action(Actions.rebase_interactive, "Are you sure to rebase interactively? (y/n)")
Actions.rebase_auto_squash_confirm = confirm_action(Actions.rebase_auto_squash, "Are you sure to rebase with auto squash? (y/n)")
Actions.rebase_upstream_confirm    = confirm_action(Actions.rebase_upstream,    "Are you sure to rebase against @{upstream}? (y/n)")
Actions.rebase_push_confirm        = confirm_action(Actions.rebase_push,        "Are you sure to rebase against @{push}? (y/n)")
Actions.rebase_continue_confirm    = confirm_action(Actions.rebase_continue,    "Are you sure to continue rebase? (y/n)")
Actions.rebase_skip_commit_confirm = confirm_action(Actions.rebase_skip_commit, "Are you sure to skip current commit? (y/n)")
Actions.rebase_abort_confirm       = confirm_action(Actions.rebase_abort,       "Are you sure to abort rebase? (y/n)")
Actions.rebase_edit_todo_confirm   = confirm_action(Actions.rebase_edit_todo,   "Are you sure to edit todo? (y/n)")
Actions.rebase_mark_reword_confirm = confirm_action(Actions.rebase_mark_reword, "Are you sure to mark reword? (y/n)")
Actions.rebase_mark_edit_confirm   = confirm_action(Actions.rebase_mark_edit,   "Are you sure to mark edit? (y/n)")
Actions.rebase_mark_drop_confirm   = confirm_action(Actions.rebase_mark_drop,   "Are you sure to mark drop? (y/n)")

--- [[ Push/Pull ]]

Actions.push_cmdline = function() --- Push cmdline
    local keys = ":Git push "
    feed_escaped_keys(keys)
end
Actions.pull_cmdline = function() --- Pull cmdline
    local keys = ":Git pull "
    feed_escaped_keys(keys)
end

--- [[ Misc ]]

Actions.dot = "<Plug>fugitive:." -- populate command-line with file under cursor
Actions.nop = "<Nop>"

return Actions
