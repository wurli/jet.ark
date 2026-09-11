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

	local ok = vim.wait(20000, function()
		for _, win in ipairs(child.api.nvim_list_wins()) do
			local buf = child.api.nvim_win_get_buf(win)
			if not child.bo[buf].filetype == "markdown" then
				return false
			end
			local lines = child.api.nvim_buf_get_lines(buf, 0, -1, false)
			for _, line in ipairs(lines) do
				if line:match(title) then
					return true
				end
			end
		end
		return false
	end)

	assert(ok, string.format("'%s' not found in any open wins after `:ArkHelp data.frame`", title))
end

return T
