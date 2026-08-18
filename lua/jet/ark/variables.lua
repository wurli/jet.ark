local M = {}

-- local win = -99
-- local buf = -99
--
-- ---@param msg table
-- local call_comm = function(msg)
-- 	require("jet.ark.utils").get_ark_kernel(function(k)
-- 		k:comm_send("positron.variables", msg)
-- 	end)
-- end
--
-- vim.api.nvim_create_user_command("ArkVariables", function(args)
-- 	if not vim.api.nvim_buf_is_valid(buf) then
-- 		buf = vim.api.nvim_create_buf(false, true)
-- 		vim.keymap.set("n", "q", "<cmd>:q<cr>", { buffer = buf, silent = true })
-- 	end
--
-- 	if not vim.api.nvim_win_is_valid(win) then
-- 		vim.api.nvim_open_win(buf, true, {
-- 			split = "right",
-- 			win = -1,
-- 			style = "minimal",
-- 		})
-- 	end
-- end, { nargs = 0 })
--
-- ---@param msg jet.jupyter.msg
-- M.listener = function(msg) end

return M
