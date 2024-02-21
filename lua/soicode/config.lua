local Soicode = {}

--- Your plugin configuration with its default values.
---
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
Soicode.options = {
    -- Prints useful logs about what event are triggered, and reasons actions are executed.
    debug = false,
}

--- Define your soicode setup.
---
---@param options table Module config table. See |Soicode.options|.
---
---@usage `require("soicode").setup()` (add `{}` with your |Soicode.options| table)
function Soicode.setup(options)
    options = options or {}

    Soicode.options = vim.tbl_deep_extend("keep", options, Soicode.options)

    return Soicode.options
end

return Soicode
