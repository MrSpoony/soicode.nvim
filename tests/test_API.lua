local helpers = dofile("tests/helpers.lua")

-- See https://github.com/echasnovski/mini.nvim/blob/main/lua/mini/test.lua for more documentation

local child = helpers.new_child_neovim()
local eq_config = helpers.expect.config_equality
local eq_type_global, eq_type_config =
    helpers.expect.global_type_equality, helpers.expect.config_type_equality
local expect, eq = helpers.expect, helpers.expect.equality

local T = MiniTest.new_set({
    hooks = {
        -- This will be executed before every (even nested) case
        pre_case = function()
            -- Restart child process with custom 'init.lua' script
            child.restart({ "-u", "scripts/minimal_init.lua" })
        end,
        -- This will be executed one after all tests from this set are finished
        post_once = child.stop,
    },
})

-- Tests related to the `setup` method.
T["setup()"] = MiniTest.new_set()

T["setup()"]["sets exposed methods and default options value"] = function()
    child.lua([[require('soicode').setup()]])

    -- global object that holds your plugin information
    eq_type_global(child, "_G.Soicode", "table")

    -- public methods
    eq_type_global(child, "_G.Soicode.compile", "function")
    eq_type_global(child, "_G.Soicode.get_samples", "function")

    -- config
    eq_type_global(child, "_G.Soicode.config", "table")

    -- assert the value, and the type
    eq_config(child, "debug", false)
    eq_type_config(child, "debug", "boolean")
end

T["setup()"]["overrides default values"] = function()
    child.lua([[require('soicode').setup({
        -- write all the options with a value different than the default ones
        debug = true,
    })]])

    -- assert the value, and the type
    eq_config(child, "debug", true)
    eq_type_config(child, "debug", "boolean")
end

T["compile()"] = MiniTest.new_set()

T["compile()"]["should compile"] = function()
    child.lua([[
    _G.messages = {}
    vim.notify = function(msg, level, opts)
        table.insert(_G.messages, {msg=msg, level=level, opts=opts})
    end
    ]])
    child.cmd("edit tests/testfiles/shouldcompile.cpp")
    child.lua("require('soicode').compile()")
    local messages = child.lua_get("_G.messages")
    eq(messages, {})
end

T["compile()"]["should not compile"] = function()
    child.lua([[
    _G.messages = {}
    vim.notify = function(msg, level, opts)
        table.insert(_G.messages, {msg=msg, level=level, opts=opts})
    end
    ]])
    child.cmd("edit tests/testfiles/shouldfail.cpp")
    child.lua("require('soicode').compile()")
    local messages = child.lua_get("_G.messages")
    eq(#messages, 1)
end

T["get_samples()"] = MiniTest.new_set()

T["get_samples()"]["can parse the .stoml samples"] = function()
    child.cmd("edit tests/testfiles/test.stoml")
    local samples = child.lua_get("require('soicode').get_samples()")
    eq(samples, {
        {
            name = "sample.01",
            input = "5 0\n",
            output = "5\n",
        },
        {
            name = "sample.02",
            input = "5 3\n0 1\n1 2\n2 3\n",
            output = "3\n",
        },
    })
end

T["run_sample()"] = MiniTest.new_set({
    hooks = {
        pre_once = function()
            child.cmd("edit tests/testfiles/addition.cpp")
            child.lua("require('soicode').compile()")
        end,
        pre_case = function()
            child.cmd("edit tests/testfiles/addition.cpp")
        end,
    },
})

T["run_sample()"]["can run a sample sucessfully"] = function()
    local verdict = child.lua_get([[
        require('soicode').run_sample({ name='sample.01', input='2 3\n', output='5\n' })
    ]])
    eq(verdict.exitcode, 0)
    eq(verdict.verdict, "OK")
end

T["run_sample()"]["can detect correct WA"] = function()
    local verdict = child.lua_get([[
        require('soicode').run_sample({ name='sample.01', input='200000000000 3\n', output='5\n' })
    ]])
    eq(verdict.exitcode, 0)
    eq(verdict.verdict, "WA")
end

T["run_sample()"]["can detect correct RE on exitcode"] = function()
    local verdict = child.lua_get([[
        require('soicode').run_sample({ name='sample.01', input='69 2\n', output='5\n' })
    ]])
    eq(verdict.exitcode, 1)
    eq(verdict.verdict, "RE")
end

T["run_sample()"]["can detect correct RE on assert"] = function()
    local verdict = child.lua_get([[
        require('soicode').run_sample({ name='sample.01', input='6969 2\n', output='5\n' })
    ]])
    eq(verdict.verdict, "RE")
end

T["run_sample()"]["can detect correct TLE"] = function()
    local verdict = child.lua_get([[
        require('soicode').run_sample({ name='sample.01', input='420 2\n', output='5\n' })
    ]])
    eq(verdict.verdict, "TLE")
end

T["run_all_samples()"] = MiniTest.new_set()

T["run_all_samples()"]["can run all samples sucessfully"] = function()
    child.cmd("edit tests/testfiles/addition.cpp")
    local verdicts = child.lua_get([[
        require('soicode').run_all_samples()
    ]])
    eq(#verdicts, 5)
    eq(verdicts[1].verdict, "OK")
    eq(verdicts[2].verdict, "WA")
    eq(verdicts[3].verdict, "RE")
    eq(verdicts[4].verdict, "RE")
    eq(verdicts[5].verdict, "TLE")
end

return T
