local M = require("soicode.main")
local Soicode = {}

-- Toggle the plugin by calling the `enable`/`disable` methods respectively.
function Soicode.toggle()
    -- when the config is not set to the global object, we set it
    if _G.Soicode.config == nil then
        _G.Soicode.config = require("soicode.config").options
    end

    _G.Soicode.state = M.toggle()
end

-- starts Soicode and set internal functions and state.
function Soicode.enable()
    if _G.Soicode.config == nil then
        _G.Soicode.config = require("soicode.config").options
    end

    local state = M.enable()

    if state ~= nil then
        _G.Soicode.state = state
    end

    return state
end

-- disables Soicode and reset internal functions and state.
function Soicode.disable()
    _G.Soicode.state = M.disable()
end

-- setup Soicode options and merge them with user provided ones.
function Soicode.setup(opts)
    _G.Soicode.config = require("soicode.config").setup(opts)
end

_G.Soicode = Soicode

return _G.Soicode
