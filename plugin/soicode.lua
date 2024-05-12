-- You can use this loaded variable to enable conditional parts of your plugin.
if _G.SoicodeLoaded then
    return
end

_G.SoicodeLoaded = true

local possible_subcommands = {
    "compile",
    "run_all",
    "run_one",
    "run",
    "run_with_own_input",
    "create_stoml",
    "toggle_stoml",
    "split_stoml",
    "copy_input",
    "insert_template",
}

---@generic T
---@param list T[]
---@param pred fun(v: T): boolean
---@return T|nil
local function find(list, pred)
    for _, v in ipairs(list) do
        if pred(v) then
            return v
        end
    end
    return nil
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

vim.api.nvim_create_user_command("Soi", function(opts)
    local args = split(opts.args, " ")
    local arg = args[1]
    if arg == "compile" then
        require("soicode").compile()
    elseif arg == "run_all" then
        require("soicode").report_all()
    elseif arg == "run_one" then
        local samples = require("soicode").get_samples()
        if samples == nil then
            vim.ui.notify("Could not find any samples")
            return
        end
        vim.ui.select(samples, {
            prompt = "Which sample to run: ",
            format_item = function(item)
                return item.name
            end,
        }, function(sample)
            require("soicode").report_one(sample)
        end)
    elseif arg == "run" then
        if #args < 2 then
            vim.notify("Missing argument")
            return
        end
        require("soicode").compile()
        local samples = require("soicode").get_samples()
        if samples == nil then
            vim.ui.notify("Could not find any samples")
            return
        end
        local verdicts = {}
        for i = 2, #args do
            local sample = find(samples, function(sample)
                return sample.name == args[i]
            end)
            if sample == nil then
                vim.notify("Could not find sample " .. args[i])
                goto continue
            end
            table.insert(verdicts, require("soicode").run_sample(sample))
            ::continue::
        end
        require("soicode").open_floating_window()
        require("soicode").report(verdicts)
    elseif arg == "run_with_own_input" then
        -- TODO: add
    elseif arg == "create_stoml" then
        -- TODO: add
    elseif arg == "toggle_stoml" then
        -- TODO: add
    elseif arg == "split_stoml" then
        -- TODO: add
    elseif arg == "copy_input" then
        -- TODO: add
    elseif arg == "insert_template" then
    elseif vim.tbl_contains(possible_subcommands, arg) then
        vim.notify("Unhandled command")
    else
        vim.notify("Unknown command")
    end
end, {
    nargs = 1,
    complete = function()
        return possible_subcommands
    end,
    desc = "Run commands from the soicode extension",
})
