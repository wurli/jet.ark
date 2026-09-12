local MiniTest = require("mini.test")

local new_set = MiniTest.new_set

local child = MiniTest.new_child_neovim()

local T = new_set({
	hooks = {
		pre_case = function() child.restart({ "-u", "scripts/minimal_init.lua" }) end,
		post_once = child.stop,
	},
})

T["kernel records stream from output in Kernel.output_stream"] = function()
	child.lua([[
		_G.k = require("jet.core.kernel").init_owned({ spec_path = "test-kernels/ark/kernel.json" })
		_G.k:start_lua_client(function(k)
			k:send_lua("print(99 + 99)")
		end)
	]])

	---@type string[]
	local lines = {}
	local stream
	local ok = vim.wait(20000, function()
		stream = child.lua_get("_G.k.output_stream.complete_lines")
		lines = child.lua_get("_G.k.output_stream.complete_lines:items()")
		for _, l in ipairs(lines) do
			if l:find("198") then
				return true
			end
		end
		return false
	end)

	assert(ok, "Kernel didn't record the expected output\noutput lines: " .. vim.inspect(lines))
end

return T
