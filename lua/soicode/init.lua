local M = require("soicode.main")
local S = require("soicode.state")

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
---@usage `require("soicode").run_sample({name="sample.01", input="1 2", output="3"})`
function Soicode.run_sample(sample)
    if _G.Soicode.config == nil then
        _G.Soicode.config = require("soicode.config").options
    end

    return M.run_sample(sample)
end

---Run all samples from the corresponding .stoml, .toml or .soitask file.
---Also compiles the file before running the samples.
---@param skip_compile boolean|nil Whether to skip the compilation step, optional.
---@return Verdict[] verdicts The verdicts of the samples.
---
---@usage `require("soicode").run_all_samples()`
function Soicode.run_all_samples(skip_compile)
    if _G.Soicode.config == nil then
        _G.Soicode.config = require("soicode.config").options
    end

    return M.run_all_samples(skip_compile)
end

---Report all samples to the floating window.
---@usage `require("soicode").report_all()`
function Soicode.report_all()
    if _G.Soicode.config == nil then
        _G.Soicode.config = require("soicode.config").options
    end

    return M.report_all()
end

---Report one sample to the floating window.
---@param sample Sample The sampne to report
---
---@usage `require("soicode").report_one({name="sample.01", input="1 2", output="3"})`
function Soicode.report_one(sample)
    if _G.Soicode.config == nil then
        _G.Soicode.config = require("soicode.config").options
    end

    return M.report_one(sample)
end

---Write the verdicts to the buffer.
---@param verdicts Verdict[] The verdicts to write to the buffer.
---
---@usage `require("soicode").write_verdicts_to_buf({
---    {
---        verdict="OK",
---        sample={
---            name="sample.01",
---            input="1 2",
---            output="3"
---        },
---        output={
---            {data="3", stdout=true},
---            {data="", stdout=true}
---        },
---        exitcode=0
---    }
---})`
function Soicode.report(verdicts)
    if _G.Soicode.config == nil then
        _G.Soicode.config = require("soicode.config").options
    end

    return M.write_verdicts_to_buf(verdicts, S.buffer)
end

---Toggle the floating window.
---@usage `require("soicode").toggle_floating_window()`
function Soicode.toggle_floating_window()
    if _G.Soicode.config == nil then
        _G.Soicode.config = require("soicode.config").options
    end

    return M.toggle_floating_window()
end

---Open the floating window.
---@usage `require("soicode").open_floating_window()`
function Soicode.open_floating_window()
    if _G.Soicode.config == nil then
        _G.Soicode.config = require("soicode.config").options
    end

    return M.open_floating_window()
end

---Close the floating window.
---@usage `require("soicode").close_floating_window()`
function Soicode.close_floating_window()
    if _G.Soicode.config == nil then
        _G.Soicode.config = require("soicode.config").options
    end

    return M.close_floating_window()
end

---Runs the current file with your own input.
---@usage `require("soicode").run_with_own_input()`
function Soicode.run_with_own_input()
    if _G.Soicode.config == nil then
        _G.Soicode.config = require("soicode.config").options
    end

    return M.run_with_own_input()
end

-- setup Soicode options and merge them with user provided ones.
function Soicode.setup(opts)
    _G.Soicode.config = require("soicode.config").setup(opts)
    S:reset()
end

_G.Soicode = Soicode

return _G.Soicode
