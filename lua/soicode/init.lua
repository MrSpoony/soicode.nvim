local M = require("soicode.main")
local Soicode = {}

--- Compile the c++ file you are currently in, or the corresponding file from the stoml file you currently have open.
---
---@usage `require("soicode").compile()`
function Soicode.compile()
    if _G.Soicode.config == nil then
        _G.Soicode.config = require("soicode.config").options
    end

    M.compile()
end

--- Get the samples from the current file, or the corresponding stoml file.
---
---@return Sample[]|nil samples The samples from the current file or nil in case of an error.
---
---@usage `require("soicode").get_samples()`
function Soicode.get_samples()
    if _G.Soicode.config == nil then
        _G.Soicode.config = require("soicode.config").options
    end

    return M.get_samples()
end

-- setup Soicode options and merge them with user provided ones.
function Soicode.setup(opts)
    _G.Soicode.config = require("soicode.config").setup(opts)
end

_G.Soicode = Soicode

return _G.Soicode
