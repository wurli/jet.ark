local M = {}

---@return string[]
M.get_expr = function()
	print("get_expr")
	local cur_line = vim.fn.line(".")
	local txt = vim.fn.getline(cur_line)
	local col = txt:find("%S")

	local node = vim.treesitter.get_node({
		bufnr = 0,
		pos = { cur_line - 1, col - 1 },
		ignore_injections = true,
	})
	print("here1")

	if node and node:type() == "program" then
		print("going to child")
		node = node:child(0)
	end
	print("here2")

	local i = 0
	while node do
		i = i + 1
		print("iter " .. i)
		local parent = node:parent()
		if parent and (parent:type() == "program" or parent:type() == "braced_expression") then
			break
		end
		node = parent
	end

	local lines = {}
	if node then
		local start_row, _, end_row, _ = node:range()
		for i = start_row, end_row do
			table.insert(lines, vim.fn.getline(i + 1))
		end
		cur_line = end_row
	end

	return lines
end

return M
