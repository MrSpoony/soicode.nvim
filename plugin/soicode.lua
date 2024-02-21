-- You can use this loaded variable to enable conditional parts of your plugin.
if _G.SoicodeLoaded then
    return
end

_G.SoicodeLoaded = true

vim.api.nvim_create_user_command("Soicode", function()
    require("soicode").toggle()
end, {})
