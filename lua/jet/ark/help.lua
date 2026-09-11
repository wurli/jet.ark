local M = {}

local help_win = -99
local last_topic

M.setup = function()
	vim.api.nvim_create_user_command("ArkHelp", function(args)
		local topic = args.fargs[1]
		if not topic then
			if vim.api.nvim_win_is_valid(help_win) then
				vim.api.nvim_set_current_win(help_win)
				return
			else
				topic = last_topic or "help"
			end
		end
		-- This is a 'fire and forget' request. We monitor the comm using
		-- M.listener() and display the result if/when we get a reply
		require("jet.ark.utils").get_ark_kernel(function(k)
			for id, comm in pairs(k.open_comms) do
				if comm.name == "positron.help" then
					require("jet.ark.comm.help-backend").show_help_topic(k, id, { topic = topic }, function(res)
						if res then
							last_topic = topic
						else
							vim.notify("[jet.ark] Help topic not found: " .. args.fargs[1], vim.log.levels.WARN)
						end
					end)
				end
			end
		end)
	end, { nargs = "?" })
end

local function show_r_help(url, buf)
	vim.bo[buf].buftype = "nofile"
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Generating markdown (pandoc)..." })

	vim.system({
		"pandoc",
		url,
		"-f",
		"html",
		"-t",
		"markdown-simple_tables-multiline_tables-pipe_tables-native_divs-fenced_divs-raw_html-smart+grid_tables",
		"--columns=100",
		"--lua-filter",
		require("jet.ark.utils").project_file("resources/prefix-relative-urls.lua"),
		"-M",
		"base-url=" .. vim.fs.dirname(url),
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

			vim.bo[buf].filetype = "markdown"
			vim.keymap.set("n", "q", "<cmd>:q<cr>", { buffer = buf, silent = true })
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(res.stdout, "\n"))

			vim.bo[buf].modifiable = false

			if vim.api.nvim_win_is_valid(help_win) then
				vim.api.nvim_set_current_win(help_win)
			else
				help_win = vim.api.nvim_open_win(buf, true, {
					relative = "editor",
					width = math.floor(vim.o.columns * 0.8),
					height = math.floor(vim.o.lines * 0.8),
					row = math.floor(vim.o.lines * 0.1),
					col = math.floor(vim.o.columns * 0.1),
					style = "minimal",
				})

				vim.api.nvim_create_autocmd("BufNew", {
					callback = function(e)
						if e.win == help_win and vim.startswith(e.file, "http") then
							show_r_help(e.file, e.buf)
							vim.bo[e.buf].buftype = "nofile"
						end
						if not vim.api.nvim_win_is_valid(help_win) then
							return true
						end
					end,
				})
			end
		end)
	end)
end

---@param msg jupyter.Msg
M.listener = function(msg)
	local data = msg.content.data

	local url = data and data.method == "show_help" and data.params and data.params.content or nil
	if not (url and type(url) == "string") then
		return
	end

	if vim.fn.executable("pandoc") ~= 1 then
		error("`pandoc` executable not found. Please make sure pandoc is installed and avaiable on the PATH.")
	end

	show_r_help(url, vim.api.nvim_create_buf(false, true))
end

return M
