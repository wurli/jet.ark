local MiniTest = require("mini.test")

local new_set = MiniTest.new_set

local child = MiniTest.new_child_neovim()

local T = new_set({
	hooks = {
		pre_once = function()
			child.restart({ "-u", "scripts/minimal_init.lua" })
			child.lua([[
				require("jet.api").get_kernel({ filtetype = "r" }, function(k)
					k:start_lua_client(function()
						_G.kernel = k
					end)
				end)
			]])

			vim.wait(10000, function()
				return child.lua_get("_G.kernel and _G.kernel.session_id") ~= vim.NIL
			end)
		end,
		post_once = child.stop,
	},
})

T["Console resize is registered in R"] = function()
	child.lua([[_G.kernel:term_open()]])

	local term_open, console_win = vim.wait(5000, function()
		local win = child.lua_get("_G.kernel.term:win()")
		return win ~= vim.NIL, win
	end)

	assert(term_open, "Could not open terminal buffer")

	local get_width = function()
		child.lua([[
			_G.width = nil
			_G.kernel:send_lua('getOption("width")', false, function(res)
				_G.width = res.content.data["text/plain"]
			end)
		]])

		local has_width, width_opt = vim.wait(5000, function()
			local res = child.lua_get("_G.width")
			return res ~= vim.NIL, res
		end)

		assert(has_width, "Could not get initial console width")

		---@diagnostic disable-next-line: need-check-nil
		local width = tonumber(width_opt:match("%d+$"))
		assert(width, "Couldn't get term width as number")

		return width
	end

	local initial_width = get_width()

	child.api.nvim_win_resize(console_win, initial_width + 10, -1, {})

	local final_width = get_width()

	assert(
		final_width > initial_width,
		string.format("Final console width %s is not bigger than initial width %s", final_width, initial_width)
	)
end

return T
