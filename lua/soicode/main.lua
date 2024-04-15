local D = require("soicode.util.debug")

-- internal methods
local Soicode = {}

---@class Sample
---@field name string The name of the sample.
---@field input string The input given to the sample.
---@field output string The expected output.

---@class OutputLine This describes a line of output
---@field data string The actual line printed
---@field stdout boolean Whether the line was printed to stdout or stderr.

---@class Verdict
---@field verdict "OK"|"WA"|"TLE"|"RE" The verdict of the sample.
---@field sample Sample The sample the Verdict corresponds to.
---@field output OutputLine[] The output lines of the execution.
---@field exitcode number|nil The exit code of the execution, is nil when verdict is "TLE".

---Compiles the current file.
---@private
function Soicode.compile()
    local flags = _G.Soicode.config.flags
    local soi_header = _G.Soicode.config.soi_header
    local args = vim.split(flags, " ")
    if soi_header then
        table.insert(args, "-I")
        local soiheaderdir = "" -- TODO: fix this
        table.insert(args, soiheaderdir)
    end
    local file = Soicode.get_current_cpp_filepath()
    if file == nil then
        vim.notify("Could not find a c++ file", "error")
        return
    end
    table.insert(args, file)
    table.insert(args, "-o")
    table.insert(args, vim.fn.expand("%:p:r"))
    local compiler = require("soicode.config").options.compiler
    local errormessage = ""
    local j = require("plenary.job"):new({
        command = compiler,
        args = args,
        on_stdout = function(_, data)
            D.log("info", "Got stdout: %s", data)
        end,
        on_stderr = function(_, data)
            D.log("info", "Got stderr: %s", data)
            errormessage = errormessage .. data .. "\n"
        end,
    })
    D.log("info", "Compiling with command: %s %s", compiler, table.concat(args, " "))
    local timeout = _G.Soicode.config.compilation_timeout_ms
    if
        _G.Soicode.config.compilation_timeout_ms == nil
        or _G.Soicode.config.compilation_timeout_ms == 0
        or _G.Soicode.config.compilation_timeout_ms == -1
        or _G.Soicode.config.compilation_timeout_ms == false
    then
        timeout = 1000 * 60 * 60 * 24
    end
    local status, err = pcall(function()
        j:sync(timeout)
    end)
    local code = j.code
    if not status then
        error(err)
    end
    if code ~= 0 then
        vim.notify(errormessage, "error", { title = "Compilation failed" })
    end
end

---Get current c++ file, available file endings are .cpp, .cc, .c, .cxx
---@return string|nil filename The current c++ file or nil if not found.
---@private
function Soicode.get_current_cpp_filepath()
    local prefix = vim.fn.expand("%:p:r")
    local files = vim.fn.glob(prefix .. ".*", false, true)
    for _, file in ipairs(files) do
        if
            string.match(file, "%.cpp$")
            or string.match(file, "%.cc$")
            or string.match(file, "%.c$")
            or string.match(file, "%.cxx$")
        then
            D.log("info", "Using file: %s", file)
            return file
        end
    end
    D.log("Could not find a c++ file, found files: %s", table.concat(files, ", "))
    return nil
end

---Get current stoml file, available file endings are .stoml, .toml, .soitask
---@return string|nil filename The current stoml file or nil if not found.
---@private
function Soicode.get_current_stoml_filepath()
    local prefix = vim.fn.expand("%:p:r")
    local files = vim.fn.glob(prefix .. ".*", false, true)
    for _, file in ipairs(files) do
        if
            string.match(file, "%.stoml$")
            or string.match(file, "%.toml$")
            or string.match(file, "%.soitask$")
        then
            D.log("info", "Using file: %s", file)
            return file
        end
    end
    D.log("Could not find a stoml file, found files: %s", table.concat(files, ", "))
    return nil
end

---Get samples from the current file.
---@return Sample[]|nil samples The samples from the current file or nil in case of an error.
---@private
function Soicode.get_samples()
    local file = Soicode.get_current_stoml_filepath()
    if file == nil then
        vim.notify("Could not find a stoml file", "error")
        return nil
    end
    local toml = io.open(file, "r"):read("a")
    D.log("info", toml)
    local parsed = require("soicode.toml").parse(toml)
    D.tprint(parsed)
    D.tprint(parsed.sample)
    if parsed.sample == nil then
        return {}
    end
    local samples = {}
    for key, sample in pairs(parsed.sample) do
        D.log("info", "%s", key)
        D.tprint(sample)
        local s = {
            name = "sample." .. key,
            input = sample.input,
            output = sample.output,
        }
        D.tprint(sample)
        table.insert(samples, s)
    end
    return samples
end

---Run the sample. Make sure the c++ file got compiled before running a sample.
---@param sample Sample The sample to run.
---@return Verdict verdict The verdict of the sample.
---@private
function Soicode.run_sample(sample)
    local executable = vim.fn.expand("%:p:r")
    local output = {}
    local timeout = _G.Soicode.config.timeout_ms
    if
        _G.Soicode.config.timeout_ms == nil
        or _G.Soicode.config.timeout_ms == 0
        or _G.Soicode.config.timeout_ms == -1
        or _G.Soicode.config.timeout_ms == false
    then
        timeout = 1000 * 60 * 60 * 24
    end
    local j = require("plenary.job"):new({
        command = executable,
        args = {},
        writer = sample.input,
        on_stdout = function(_, data)
            D.log("info", "Stdout: %s", data)
            if data ~= "" then
                table.insert(output, { data = data, stdout = true })
            end
        end,
        on_stderr = function(_, data)
            D.log("info", "Stderr: %s", data)
            if data ~= "" then
                table.insert(output, { data = data, stdout = false })
            end
        end,
    })
    D.log("info", "Running command: %s", executable)
    D.log("info", "Writing input: %s", sample.input)
    local status, err = pcall(function()
        j:sync(timeout)
    end)
    local code = j.code
    local is_tle = false
    if not status and err ~= nil and err:match("was unable to complete in") ~= nil then
        is_tle = true
    elseif not status then
        error(err)
    end
    D.log("info", "Exit code: %s", code)
    return Soicode.check_sample(sample, output, code, is_tle)
end

local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

local function split(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(str, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
    table.insert(result, string.sub(str, from))
    return result
end

---Check the sample
---@param sample Sample The sample to check.
---@param output OutputLine[] The output of the execution.
---@param code number The exit code of the execution
---@param is_tle boolean Whether the execution was a TLE.
---@return Verdict verdict The veridct of the sample.
---@private
function Soicode.check_sample(sample, output, code, is_tle)
    local verdict = "OK"

    local sample_lines = split(trim(sample.output), "\n")
    local sample_line = 1
    local has_error = false
    for _, line in ipairs(output) do
        if line.stdout then
            if #sample_lines < sample_line then
                verdict = "WA"
                break
            end
            if trim(line.data) ~= trim(sample_lines[sample_line]) then
                verdict = "WA"
            end
            sample_line = sample_line + 1
        else
            has_error = true
        end
    end

    if sample_line ~= #sample_lines + 1 then
        verdict = "WA"
    end

    if verdict == "WA" and has_error then
        verdict = "RE"
    end

    -- Error codes and TLE take precedence
    if is_tle then
        verdict = "TLE"
        goto ret
    elseif code ~= 0 then
        verdict = "RE"
        goto ret
    end

    ::ret::
    return {
        verdict = verdict,
        sample = sample,
        output = output,
        exitcode = code,
    }
end

return Soicode
