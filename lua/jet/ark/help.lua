local M = {}

local win = -99
local buf = -99

---@param msg jet.jupyter.msg
M.listener = function(msg)
	local data = msg.content.data

	if data.method == "ShowHelpTopicReply" and data.result == false then
		vim.notify("[jet.ark] Failed to get help topic", vim.log.levels.ERROR)
		return
	end

	local url = data and data.method == "show_help" and data.params and data.params.content or nil
	if not (url and type(url) == "string") then
		return
	end

	vim.system({
		"pandoc",
		url,
		"-f",
		"html",
		"-t",
		"markdown-simple_tables-multiline_tables-pipe_tables-native_divs-fenced_divs-raw_html-smart+grid_tables",
		"--columns=100",
	}, {}, function(res)
		if not res.signal == 0 then
			vim.notify(
				"[jet.ark] Failed to convert help page to markdown: " .. (res.stderr or "unknown error"),
				vim.log.levels.ERROR
			)
			return
		end
		vim.schedule(function()
			if not res.stdout or res.stdout == "" then
				vim.notify("[jet.ark] Help page is empty", vim.log.levels.WARN)
				return
			end

			if not vim.api.nvim_buf_is_valid(buf) then
				buf = vim.api.nvim_create_buf(false, true)
				vim.bo[buf].filetype = "markdown"
				vim.keymap.set("n", "q", "<cmd>:q<cr>", { buffer = buf, silent = true })
			end

			vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(res.stdout, "\n"))

			if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
				vim.api.nvim_set_current_win(win)
			else
				win = vim.api.nvim_open_win(buf, true, {
					relative = "editor",
					width = math.floor(vim.o.columns * 0.8),
					height = math.floor(vim.o.lines * 0.8),
					row = math.floor(vim.o.lines * 0.1),
					col = math.floor(vim.o.columns * 0.1),
					style = "minimal",
				})
			end
		end)
	end)
end

return M
