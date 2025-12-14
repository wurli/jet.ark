local M = {}

-- --- Get the full expression the cursor is currently o--- Check if line is a comment
-- ---@param line string
-- ---@return boolean
-- local is_comment = function(line)
-- 	return line:find("^%s*#") ~= nil
-- end

-- --- Check if a line is blank
-- ---@param line string
-- ---@return boolean
-- local is_blank = function(line)
-- 	return line:find("^%s*$") ~= nil
-- end

-- --- Check if a line is blank or a comment
-- ---@param line string
-- ---@return boolean
-- local is_insignificant = function(line)
-- 	return is_comment(line) or is_blank(line)
-- end

M.selection = function()
	return vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
end

-- local last_line = vim.api.nvim_buf_line_count(0)
-- local send_insignificant_lines = false
-- -- Find the first non-blank row/column after the cursor
-- while is_insignificant(txt) do
-- 	if is_comment(txt) then
-- 		send_insignificant_lines = true
-- 	end
-- 	if send_insignificant_lines then
-- 		table.insert(lines, txt)
-- 	end
-- 	if cur_line == last_line then
-- 		return lines
-- 	end
-- 	cur_line = cur_line + 1
-- 	txt = vim.fn.getline(cur_line)
-- end

---@return string[]
M.get_curr_expr = function()
	local cur_line = vim.fn.line(".")
	local txt = vim.fn.getline(cur_line)
	local col = txt:find("%S")

	local node = vim.treesitter.get_node({
		bufnr = 0,
		pos = { cur_line - 1, col - 1 },
		-- Required for quarto/rmd/rnoweb; harmless for r.
		-- ignore_injections = false,
	})

	if node and node:type() == "program" then
		node = node:child(0)
	end

	while node do
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
