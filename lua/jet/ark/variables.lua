local M = {}

local win = -99
local buf = -99

M.setup = function()
	vim.api.nvim_create_user_command("ArkVariables", function(_args)
		require("jet.ark.utils").get_ark_kernel(function(_k)
			if not vim.api.nvim_buf_is_valid(buf) then
				buf = vim.api.nvim_create_buf(false, true)
				vim.keymap.set("n", "q", "<cmd>:q<cr>", { buffer = buf, silent = true })
			end

			if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
				vim.api.nvim_open_win(buf, true, {
					split = "right",
					win = -1,
					style = "minimal",
				})
			end
		end)
	end, { nargs = 0 })
end

---@param _ jupyter.Msg
M.listener = function(_)
	-- vim.print(msg)
end

return M
