local M = {}

local remove_one_trailing_space = function(lnum)
	local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
	if line and line:sub(-1) == " " then
		vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { line:sub(1, -2) })
	end
end

local maybe_trim_line = function(lnum)
	vim.schedule(function()
		vim.api.nvim_create_autocmd({ "TextChangedI", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("jet.ark.trim_line", { clear = true }),
			once = true,
			callback = function()
				if vim.fn.line(".") == lnum + 1 or vim.fn.mode() ~= "i" then
					remove_one_trailing_space(lnum)
				end
			end,
		})
	end)
end

M.pipe = function()
	local cnum, lnum = vim.fn.col("."), vim.fn.line(".")
	local prev_char = vim.api.nvim_get_current_line():sub(cnum - 1, cnum - 1)
	local lead = prev_char == " " and "" or " "
	vim.api.nvim_put({ lead .. "|> " }, "c", false, true)
	maybe_trim_line(lnum)
end

M.assign = function()
	local cnum, lnum = vim.fn.col("."), vim.fn.line(".")
	local prev_char = vim.api.nvim_get_current_line():sub(cnum - 1, cnum - 1)
	local lead = prev_char == " " and "" or " "
	vim.api.nvim_put({ lead .. "<- " }, "c", false, true)
	maybe_trim_line(lnum)
end

return M
