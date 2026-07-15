local M = {}

---@param pos jet.send.Pos
---@return jet.send.Range?
M.get_expr = function(pos)
	local txt = vim.api.nvim_buf_get_lines(0, pos.row, pos.row + 1, false)[1]

	-- The given position isn't in the buf
	if not txt then
		return
	end

	-- The given position is in a blank line
	local col = txt:find("%S")

	if not col then
		return
	end

	local node = vim.treesitter.get_node({
		bufnr = 0,
		pos = { pos.row, pos.col },
		-- Important, e.g. for getting expressions in markdown code blocks
		ignore_injections = false,
	})

	if node and node:type() == "program" then
		node = node:child(0)
	end

	local max_iterations = 100
	local curr_iteration = 0

	while node do
		curr_iteration = curr_iteration + 1
		if curr_iteration > max_iterations then
			vim.notify(
				table.concat({
					"[Ark] Warning: Maximum iterations reached while traversing the AST.",
					"Breaking out of possible infinite loop.",
				}, "\n"),
				vim.log.levels.WARN
			)
			break
		end
		local parent = node:parent()
		if parent and (parent:type() == "program" or parent:type() == "braced_expression") then
			break
		end
		node = parent
	end

	if not node then
		return
	end

	local start_row, start_col, end_row, end_col = node:range(false)

	return {
		buf = vim.api.nvim_get_current_buf(),
		start_row = start_row,
		start_col = start_col,
		end_row = end_row,
		end_col = end_col,
	}
end

return M
