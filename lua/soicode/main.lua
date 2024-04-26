local C = require("soicode.config")
local D = require("soicode.util.debug")
local S = require("soicode.state")

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

---@param s string The string to trim.
---@return string s The trimmed string.
local function trim(s)
    if s == nil then
        return ""
    end
    return s:match("^%s*(.-)%s*$")
end

---@param s string The string to trim.
---@param delim string The delimiter to trim with at the back.
---@return string s The trimmed string.
local function trim_back(s, delim)
    if s == nil then
        return ""
    end
    return s:match("^(.*)" .. delim .. "$")
end

---Compiles the current file.
---@private
function Soicode.compile()
    local compiler = require("soicode.config").options.compiler
    local flags = C.options.flags
    local soi_header = C.options.soi_header

    local command = vim.split(compiler .. " " .. flags, " ")
    if soi_header then
        table.insert(command, "-I")
        local soiheaderdir = "" -- TODO: fix this
        table.insert(command, soiheaderdir)
    end
    local file = Soicode.get_current_cpp_filepath()
    if file == nil then
        vim.notify("Could not find a c++ file", vim.log.levels.ERROR)
        return
    end
    table.insert(command, file)
    table.insert(command, "-o")
    table.insert(command, vim.fn.expand("%:r"))

    local timeout = C.options.compilation_timeout_ms
    if
        C.options.compilation_timeout_ms == nil
        or C.options.compilation_timeout_ms == 0
        or C.options.compilation_timeout_ms == -1
        or C.options.compilation_timeout_ms == false
    then
        timeout = 1000 * 60 * 60 * 24
    end

    local errormessage = ""
    local cmd = vim.system(command, {
        stdout = function(err, data)
            if err ~= nil then
                vim.notify(err, vim.log.levels.ERROR)
                return
            end

            D.log("info", "Got stdout: %s", data)
        end,
        stderr = function(err, data)
            if err ~= nil then
                vim.notify(err, vim.log.levels.ERROR)
                return
            end

            D.log("info", "Got stderr: %s", data)
            if data ~= nil then
                errormessage = errormessage .. data .. "\n"
            end
        end,
        timeout = timeout,
    }):wait()
    local code = cmd.code
    if code ~= 0 then
        if code == 124 then
            vim.notify("Compilation timed out after " .. timeout .. "ms", vim.log.levels.ERROR)
            return
        end
        vim.notify(errormessage, vim.log.levels.ERROR, { title = "Compilation failed" })
    end
end

---Get current c++ file, available file endings are .cpp, .cc, .c, .cxx
---@return string|nil filename The current c++ file or nil if not found.
---@private
function Soicode.get_current_cpp_filepath()
    local prefix = vim.fn.expand("%:r")
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
    local prefix = vim.fn.expand("%:r")
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
---@return Sample[]|nil samples The samples ordered by name from the current file or nil in case of an error.
---@private
function Soicode.get_samples()
    local file = Soicode.get_current_stoml_filepath()
    if file == nil then
        vim.notify("Could not find a stoml file", vim.log.levels.ERROR)
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
    table.sort(samples, function(a, b)
        return a.name < b.name
    end)
    return samples
end

---Run the sample. Make sure the c++ file got compiled before running a sample.
---@param sample Sample The sample to run.
---@return Verdict verdict The verdict of the sample.
---@private
function Soicode.run_sample(sample)
    local executable = vim.fn.expand("%:r")
    local output = {}
    local timeout = C.options.timeout_ms
    if
        C.options.timeout_ms == nil
        or C.options.timeout_ms == 0
        or C.options.timeout_ms == -1
        or C.options.timeout_ms == false
    then
        timeout = 1000 * 60 * 60 * 24
    end
    local handle = vim.system({ executable }, {
        stdin = sample.input,
        stdout = function(err, data)
            if err ~= nil then
                vim.notify(err, vim.log.levels.ERROR)
            end

            D.log("info", "Stdout: %s", data)
            if data ~= nil then
                data = trim_back(data, "\n")
                table.insert(output, { data = data, stdout = true })
            end
        end,
        stderr = function(err, data)
            if err ~= nil then
                vim.notify(err, vim.log.levels.ERROR)
            end

            D.log("info", "Stderr: %s", data)
            if data ~= nil then
                data = trim_back(data, "\n")
                table.insert(output, { data = data, stdout = false })
            end
        end,
        timeout = timeout,
    })
    D.log("info", "Running command: %s", executable)
    D.log("info", "Writing input: %s", sample.input)
    local cmd = handle:wait()
    local code = cmd.code
    local is_tle = code == 124
    if code == 124 then
        code = nil
    end
    D.log("info", "Exit code: %s", code)
    return Soicode.check_sample(sample, output, code, is_tle)
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
---@param code number|nil The exit code of the execution
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
            if sample_lines[sample_line] == nil then
                return {
                    verdict = "IDK2" .. sample_line,
                    sample = sample,
                    output = output,
                    exitcode = code,
                }
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

---Run all samples from the corresponding .stoml, .toml or .soitask file.
---Also compiles the file before running the samples.
---@param skip_compile boolean|nil Whether to skip the compilation step, optional.
---@return Verdict[] verdicts The verdicts of the samples.
---@private
function Soicode.run_all_samples(skip_compile)
    skip_compile = skip_compile or false
    local samples = Soicode.get_samples()
    if samples == nil then
        return {}
    end
    if not skip_compile then
        Soicode.compile()
    end
    local verdicts = {}
    for _, sample in ipairs(samples) do
        local verdict = Soicode.run_sample(sample)
        table.insert(verdicts, verdict)
    end

    return verdicts
end

---Report all samples to the floating window.
---@private
function Soicode.report_all()
    local verdicts = Soicode.run_all_samples()
    Soicode.open_floating_window()
    Soicode.write_verdicts_to_buf(verdicts, S.buffer)
end

---Writes the verdicts to
---@param verdicts Verdict[] The verdicts to write to the buffer.
---@param buf number The buffer to write to.
---@private
function Soicode.write_verdicts_to_buf(verdicts, buf)
    local lines = {}
    local extmarks = {}

    local line_nr = 0

    local new_extmark = function(text, hl)
        local col = 0
        return {
            col = col,
            line = line_nr,
            opts = {
                end_col = col + vim.fn.strlen(text),
                hl_group = hl,
            },
        }
    end

    local new_multiline_extmark = function(text, hl)
        if type(text) == "string" then
            text = split(trim(text), "\n")
        end
        local last_line = text[#text]

        local col = 0
        return {
            col = col,
            line = line_nr,
            opts = {
                -- end_col = col + vim.fn.strlen(last_line),
                end_line = line_nr + #text,
                hl_group = hl,
            },
        }
    end

    for i, verdict in ipairs(verdicts) do
        if i ~= 1 then
            table.insert(lines, "")
            line_nr = line_nr + 1
        end

        local str = "Sample '" .. verdict.sample.name .. "' "
        local skip_output = false

        if verdict.verdict == "OK" then
            str = str .. "succesful!"
            skip_output = true
        elseif verdict.verdict == "WA" then
            str = str .. "failed!"
        elseif verdict.verdict == "RE" then
            str = str .. "had a runtime error!"
        elseif verdict.verdict == "TLE" then
            str = str .. "timed out!"
        end

        table.insert(lines, str)
        table.insert(extmarks, new_extmark(str, "Soi" .. verdict.verdict))
        line_nr = line_nr + 1

        if not skip_output then
            local expected_title = "Expected:"
            table.insert(lines, expected_title)
            table.insert(extmarks, new_extmark(expected_title, "SoiExpectedTitle"))
            line_nr = line_nr + 1

            local expected_text = split(trim(verdict.sample.output), "\n")
            for _, line in ipairs(expected_text) do
                table.insert(lines, line)
            end
            table.insert(extmarks, new_multiline_extmark(expected_text, "SoiExpected"))
            line_nr = line_nr + #expected_text

            if verdict.output ~= nil and #verdict.output ~= 0 then
                local next_line = "Actual:"
                if verdict.verdict == "RE" then
                    next_line = "Output:"
                end
                table.insert(lines, next_line)
                table.insert(extmarks, new_extmark(next_line, "SoiActualTitle"))
                line_nr = line_nr + 1

                for _, line in ipairs(verdict.output) do
                    table.insert(lines, line.data)
                    if line.stdout then
                        table.insert(extmarks, new_extmark(line.data, "SoiOutput"))
                    else
                        table.insert(extmarks, new_extmark(line.data, "SoiOutputStderr"))
                    end
                    line_nr = line_nr + 1
                end
            end

            local input_title = "Input:"
            table.insert(lines, input_title)
            table.insert(extmarks, new_extmark(input_title, "SoiInputTitle"))
            line_nr = line_nr + 1

            local input_text = split(trim(verdict.sample.input), "\n")
            for _, line in ipairs(input_text) do
                table.insert(lines, line)
            end
            table.insert(extmarks, new_multiline_extmark(input_text, "SoiInput"))
            line_nr = line_nr + #input_text
        end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
    vim.api.nvim_buf_clear_namespace(buf, C.ns, 0, -1)
    for _, extmark in ipairs(extmarks) do
        local ok =
            pcall(vim.api.nvim_buf_set_extmark, buf, C.ns, extmark.line, extmark.col, extmark.opts)
        if not ok then
            vim.notify(
                "extmark: " .. vim.inspect(extmark),
                vim.log.levels.ERROR,
                { title = "Could not set extmark" }
            )
        end
    end
end

---Toggle the floating window.
---@private
function Soicode.toggle_floating_window()
    if S.window == nil then
        Soicode.open_floating_window()
    else
        Soicode.close_floating_window()
    end
end

---Open the floating window.
---@private
function Soicode.open_floating_window()
    if S.buffer == nil then
        S.buffer = vim.api.nvim_create_buf(false, true)
    end

    if S.window ~= nil then
        return
    end

    S.window = vim.api.nvim_open_win(S.buffer, true, {
        relative = "win",
        row = vim.o.lines / 2,
        col = vim.o.columns / 2,
        width = math.floor(vim.o.columns / 2), -- nvim caps it at the right of the screen
        height = math.floor(vim.o.lines / 2), -- nvim caps it at the bottom of the screen
        border = "single",
        title = "soicode output",
    })
    if S.window == 0 then
        vim.notify("Could not open floating window", vim.log.levels.ERROR)
        return
    end

    S:save()
end

---Close the floating window.
---@private
function Soicode.close_floating_window()
    if S.window ~= nil then
        vim.api.nvim_win_close(S.window, true)
        S.window = nil
    end

    S:save()
end

return Soicode
