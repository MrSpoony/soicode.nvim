local M = require("soicode.main")
local Soicode = {}

-- Compile the c++ file you are currently in, or the corresponding file from the stoml file you currently have open.
function Soicode.compile()
    if _G.Soicode.config == nil then
        _G.Soicode.config = require("soicode.config").options
    end

    M.compile()
end

-- Get the samples from the current file, or the corresponding stoml file.
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
