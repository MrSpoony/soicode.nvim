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

---Run the sample. Make sure the c++ file got compiled before running a sample.
---@param sample Sample The sample to run.
---@return Verdict verdict The verdict of the sample.
---
---@usage `require("soicode").run_sample({name="sample.01", inupt="1 2", output="3"})`
function Soicode.run_sample(sample)
    if _G.Soicode.config == nil then
        _G.Soicode.config = require("soicode.config").options
    end

    return M.run_sample(sample)
end

-- setup Soicode options and merge them with user provided ones.
function Soicode.setup(opts)
    _G.Soicode.config = require("soicode.config").setup(opts)
end

_G.Soicode = Soicode

return _G.Soicode
