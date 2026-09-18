local MiniTest = require("mini.test")

local new_set = MiniTest.new_set

local child = MiniTest.new_child_neovim()

local T = new_set({
	hooks = {
		pre_once = function()
			child.restart({ "-u", "scripts/minimal_init.lua" })
			child.lua([[
				require("jet.api").get_kernel({ ft = "r" }, function(k)
					_G.k = k
					k:start_lua_client(function(k)
						k:send_lua({
							'mtcars <- mtcars',
							'my_string <- "hello world"',
							'my_fn <- factor(letters)',
							'my_numbers <- 1:3',
							'my_letters <- list(a = 1:3, b = "hello")',
						}, false, function() _G.done = true end)
					end)
				end)
			]])

			local ok = vim.wait(10000, function() return child.lua_get("_G.done") ~= vim.NIL end)
			assert(ok, "Failed to start Ark")
		end,
		post_once = child.stop,
	},
})

T[":ArkVars opens the variables pane"] = function()
	child.cmd([[ArkVars]])

	local ok = vim.wait(5000, function()
		for _, win in pairs(child.api.nvim_list_wins()) do
			local buf = child.api.nvim_win_get_buf(win)
			if child.lua_get(string.format("vim.bo[%d].filetype", buf)) == "arkvars" then
				child.lua(string.format("_G.vars_win, _G.vars_buf = %d, %d", win, buf))
				return true
			end
		end
		return false
	end)

	assert(ok, "No buffer with 'arkvars' filetype found after :ArkVars")
end

T["Vars window has expected category headers"] = function()
	local lines = child.lua_get("vim.api.nvim_buf_get_lines(_G.vars_buf, 0, -1, false)")
	local text = table.concat(lines, "\n")

	assert(text:find("DATA"), "Did not find DATA in vars buf")
	assert(text:find("VALUES"), "Did not find VALUES in vars buf")
end

T["Vars window has the expected variables"] = function()
	local lines = child.lua_get("vim.api.nvim_buf_get_lines(_G.vars_buf, 0, -1, false)")
	local text = table.concat(lines, "\n")

	assert(text:find("mtcars"), "Did not find mtcars in vars buf")
	assert(text:find("my_string"), "Did not find my_string in vars buf")
	assert(text:find("my_fn"), "Did not find my_fn in vars buf")
	assert(text:find("my_numbers"), "Did not find my_numbers in vars buf")
	assert(text:find("my_letters"), "Did not find my_letters in vars buf")
end

T["Vars can be expanded"] = function()
	child.lua("vim.api.nvim_set_current_buf(_G.vars_buf)")

	local n_lines_before = child.api.nvim_buf_line_count(child.lua_get("_G.vars_buf"))
	child.type_keys("/mtcars<enter><enter>")

	local ok = vim.wait(5000, function()
		local n_lines_after = child.api.nvim_buf_line_count(child.lua_get("_G.vars_buf"))
		return n_lines_after > n_lines_before
	end)

	assert(ok, "<Enter> over mtcars did not increase line count")
end

return T
