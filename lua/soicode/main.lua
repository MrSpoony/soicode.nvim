local D = require("soicode.util.debug")

-- internal methods
local Soicode = {}

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
    D.log("info", "Compiling with command: %s, args: %s", compiler, table.concat(args, " "))
    local _, code = j:sync()
    if code ~= 0 then
        vim.notify(errormessage, "error", { title = "Compilation failed"})
    end
end

---Get current c++ file, available file endings are .cpp, .cc, .c, .cxx
---@return string|nil filename The current c++ file or nil if not found.
---@private
function Soicode.get_current_cpp_filepath()
    local prefix = vim.fn.expand("%:p:r")
    local files = vim.fn.glob(prefix .. ".*", false, true)
    for _, file in ipairs(files) do
        if string.match(file, "%.cpp$")
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
        if string.match(file, "%.stoml$")
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

---@class Sample
---@field name string
---@field input string
---@field output string

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

return Soicode
