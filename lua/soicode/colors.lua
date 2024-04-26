local M = {}

M.colors = {

    OK = "DiagnosticOk",
    WA = "DiagnosticError",
    TLE = "DiagnosticError",
    RE = "DiagnosticError",

    ExpectedTitle = "DiagnosticSignInfo",
    ActualTitle = "DiagnosticSignInfo",
    InputTitle = "DiagnosticSignInfo",

    Expected = "String",
    Output = "String",
    OutputStderr = "DiagnosticWarn",
    Input = "String",
}

M.did_setup = false

function M.set_hl()
    for hl_group, link in pairs(M.colors) do
        vim.api.nvim_set_hl(0, "Soi" .. hl_group, {
            link = link,
            default = true,
        })
    end
end

function M.setup()
    if M.did_setup then
        return
    end

    M.did_setup = true

    M.set_hl()

    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            M.set_hl()
        end,
    })
end

return M
