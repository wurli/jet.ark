local M = {}

local win = -99
local buf = -99

local variables_buf = function()
	if vim.api.nvim_buf_is_valid(buf) then
		return buf
	else
		buf = vim.api.nvim_create_buf(false, true)
		vim.keymap.set("n", "q", "<cmd>:q<cr>", { buffer = buf, silent = true })
		return buf
	end
end

---@param vars jet.ark.comm.variables_backend.variable[] A list of variables in the session.
---@return string[]
local render_variables = function(vars)
	vim.print(vars)
	---@param var jet.ark.comm.variables_backend.variable
	return vim.tbl_map(function(var) return string.format("%s (%s)", var.display_name, var.display_type) end, vars)
end

M.setup = function()
	vim.api.nvim_create_user_command("ArkVariables", function(_args)
		require("jet.ark.utils").get_ark_comm("positron.variables", function(k, id)
			require("jet.ark.comm.variables-backend").list(
				k,
				id,
				function(res) vim.api.nvim_buf_set_lines(buf, 0, -1, false, render_variables(res.variables)) end
			)

			if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
				vim.api.nvim_open_win(variables_buf(), true, {
					split = "right",
					win = -1,
					style = "minimal",
				})
			end
		end)
	end, { nargs = 0 })
end

---@param msg jupyter.Msg
M.listener = function(msg)
	local data = msg.content.data
	local method = data.method --[[@as "refresh" | "update"]]

	if method == "refresh" then
		local params = data.params --[[@as jet.ark.comm.variables_frontend.refresh.Params]]
		render_variables(params.variables)
	elseif method == "update" then
		local params = data.params --[[@as jet.ark.comm.variables_frontend.update.Params]]
		vim.print({ update = params })
	end
end

return M
