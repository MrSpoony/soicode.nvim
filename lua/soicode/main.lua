local D = require("soicode.util.debug")

-- internal methods
local Soicode = {}

-- state
local S = {
    -- Boolean determining if the plugin is enabled or not.
    enabled = false,
}

---Toggle the plugin by calling the `enable`/`disable` methods respectively.
---@private
function Soicode.toggle()
    if S.enabled then
        return Soicode.disable()
    end

    return Soicode.enable()
end

---Initializes the plugin.
---@private
function Soicode.enable()
    if S.enabled then
        return S
    end

    S.enabled = true

    return S
end

---Disables the plugin and reset the internal state.
---@private
function Soicode.disable()
    if not S.enabled then
        return S
    end

    -- reset the state
    S = {
        enabled = false,
    }

    return S
end

return Soicode
