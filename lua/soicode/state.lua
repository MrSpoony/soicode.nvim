local D = require("soicode.util.debug")

local State = {
    buffer = nil,
    window = nil,
}

---Sets the state to it's original value
---
---@private
function State:reset()
    self.buffer = nil
    self.win = nil
end

---Saves the state in the global _G.Soicode.state object.
---
---@private
function State:save()
    D.log("state.save", "saving state globally to _G.YourPluginName.state")

    _G.Soicode.state = self
end

return State
