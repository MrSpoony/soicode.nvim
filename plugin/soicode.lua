-- You can use this loaded variable to enable conditional parts of your plugin.
if _G.SoicodeLoaded then
    return
end

_G.SoicodeLoaded = true

local possible_subcommands = {
    "compile",
    "run_all",
    "run_one",
    "run_with_own_input",
    "create_stoml",
    "toggle_stoml",
    "split_stoml",
    "copy_input",
    "insert_template",
}

vim.api.nvim_create_user_command("Soi", function(opts)
    local args = opts.args
    if args == "compile" then
        require("soicode").compile()
    elseif args == "run_all" then
    elseif args == "run_one" then
    elseif args == "run_with_own_input" then
    elseif args == "create_stoml" then
    elseif args == "toggle_stoml" then
    elseif args == "split_stoml" then
    elseif args == "copy_input" then
    elseif args == "insert_template" then
    elseif vim.tbl_contains(possible_subcommands, args) then
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
