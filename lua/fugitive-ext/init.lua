local Config = require("fugitive-ext.config")
local Hint = require("fugitive-ext.hint")
local autocmd = require("fugitive-ext.autocmd")

---@class FugitiveExt
---@field config FugitiveExtConfig
---@field hint FugitiveExtHint
local FugitiveExt = {}

FugitiveExt.__index = FugitiveExt

---@return FugitiveExt
function FugitiveExt:new()
	local config = Config.get_default_config()

	local fugitive_ext = setmetatable({
		config = config,
		hint = nil,
	}, self)

	return fugitive_ext
end

local fugitive_ext = FugitiveExt:new()

---@param self FugitiveExt
---@param partial_config? FugitiveExtPartialConfig
---@return FugitiveExt
FugitiveExt.setup = function(self, partial_config)
	if self ~= fugitive_ext then
		---@diagnostic disable-next-line: cast-local-type
		partial_config = self
		self = fugitive_ext
	end

	---@diagnostic disable-next-line: param-type-mismatch
	self.config = Config.merge_config(partial_config, self.config)
    self.hint = Hint:new(self.config)

	if self.config._debug then
		vim.notify("FugitiveExt Debug Mode Enabled", 3)
		vim.api.nvim_set_option("cmdheight", 8)
	end

	-- Setup autocmd
	autocmd.setup(self)

	return self
end

return fugitive_ext
