local MiniTest = require("mini.test")

local new_set = MiniTest.new_set

local child = MiniTest.new_child_neovim()

local T = new_set({
	hooks = {
		pre_case = function()
			child.restart({ "-u", "scripts/minimal_init.lua" })
		end,
		post_once = child.stop,
	},
})

T[":ArkHelp works"] = function()
	child.cmd("ArkHelp data.frame")
	local title = "## Data Frames"
	local help_win = -99

	local ok1 = vim.wait(20000, function()
		for _, win in ipairs(child.api.nvim_list_wins()) do
			local buf = child.api.nvim_win_get_buf(win)
			if child.lua_get(string.format("vim.bo[%s].filetype", buf)) == "markdown" then
				local lines = child.api.nvim_buf_get_lines(buf, 0, -1, false)
				for _, line in ipairs(lines) do
					if line:match(title) then
						help_win = win
						return true
					end
				end
			end
		end
		return false
	end)

	assert(ok1, string.format("'%s' not found in any open wins after `:ArkHelp data.frame`", title))

	assert(child.api.nvim_win_is_valid(help_win))
	child.api.nvim_set_current_win(help_win)

	-- the data.frame docs have a link to make.names. Find the link then follow
	-- it with `gf`
	child.type_keys([[/http.*make\.names<cr>gf]])

	local ok2 = vim.wait(5000, function()
		local buf = child.api.nvim_win_get_buf(help_win)
		local lines = child.api.nvim_buf_get_lines(buf, 0, -1, false)
		for _, line in ipairs(lines) do
			if
				line:match("Make syntactically valid names out of character vectors")
				and child.lua_get(string.format("vim.bo[%s].filetype", buf)) == "markdown"
			then
				return true
			end
		end
		return false
	end)

	assert(ok2, "Couldn't follow help link to docs for `make.names`")
end

return T
