local Soicode = {}

--- Your plugin configuration with its default values.
---
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
Soicode.options = {
    -- Prints useful logs about what event are triggered, and reasons actions are executed.
    debug = false,
    -- Compiler to use
    compiler = "g++",
    -- Additional flags,
    flags = {
        "-Wall",
        "-Wextra",
        "-std=c++20",
        "-g3",
        "-ggdb3",
        "-fsanitize=address,undefined",
        "-D_GLIBCXX_DEBUG",
    },
    -- Use the soi header
    soi_header = true,
    -- Where to store additon files such as the soi header
    additional_files_dir = vim.fn.expand("$HOME/.local/share/nvim/soicode"),
    -- Timeout for TLE in milliseconds, 0, nil, false or -1 to disable (1 day will be set as hardmax)
    timeout_ms = 1000,
    -- Timeout for code compilation in milliseconds, 0, nil, false or -1 to disable (1 day will be set as hardmax)
    compilation_timeout_ms = 10000,
    -- Run in background, and don't block the UI
    run_in_background = true,
}

Soicode.ns = vim.api.nvim_create_namespace("soicode")

--- Define your soicode setup.
---
---@param options table Module config table. See |Soicode.options|.
---
---@usage `require("soicode").setup()` (add `{}` with your |Soicode.options| table)
function Soicode.setup(options)
    options = options or {}

    Soicode.options = vim.tbl_deep_extend("keep", options, Soicode.options)

    require("soicode.colors").setup()

    return Soicode.options
end

return Soicode
