local config = require("jet.ark.config")
local utils = require("jet.ark.utils")

local M = {}

local setup_plot_auto_resize = function()
	vim.api.nvim_create_autocmd("WinResized", {
		group = vim.api.nvim_create_augroup("jet.ark.plot-resized", { clear = true }),
		callback = function()
			for _, win in ipairs(vim.v.event.windows or {}) do
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.b[buf].jet and vim.bo[buf].filetype == "jetimg" then
					local session_id = vim.b[buf].jet.session_id
					local k = session_id and require("jet.api").get_kernel_by_id(session_id) --[[@as ark.Kernel? ]]
					if k and k.subclass == "ark" then
						k:resize_curr_plot()
					end
				end
			end
		end,
	})
end

local setup_console_auto_resize = function()
	vim.api.nvim_create_autocmd("WinResized", {
		group = vim.api.nvim_create_augroup("jet.ark.console-resized", { clear = true }),
		callback = function()
			local resized_wins = vim.v.event.windows --[[@as integer[] ]]
			for _, win in ipairs(resized_wins) do
				local buf = vim.api.nvim_win_get_buf(win)
				local session_id = vim.b[buf].jet and vim.b[buf].jet.session_id --[[@as string]]
				local kernel = session_id and require("jet.api").get_kernel_by_id(session_id) --[[@as ark.Kernel?]]
				if kernel and kernel.subclass == "ark" then
					kernel:set_console_width(vim.api.nvim_win_get_width(win))
				end
			end
		end,
	})
end

local setup_help = function()
	vim.api.nvim_create_user_command("ArkHelp", function(args)
		local topic = args.fargs[1]

		if not topic then
			local help_win = require("jet.ark.ark_kernel.help").help_win
			if vim.api.nvim_win_is_valid(help_win) then
				vim.api.nvim_set_current_win(help_win)
				return
			end
		end

		require("jet.ark.utils").get_ark_kernel(function(k) k:request_help(topic) end)
	end, { nargs = "?" })
end

local setup_lsp = function()
	-- Start the LSP when an R file is entered. NB for most LSPs it's better to
	-- use `FileType` since you don't expect the LSP to stop. But Ark closes if
	-- we quit the REPL, so we will want to check if it needs restarting.
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "*.r",
		group = vim.api.nvim_create_augroup("jet.ark.lsp", { clear = true }),
		callback = function()
			if vim.lsp.get_clients({ name = "ark" })[1] then
				return
			end
			utils.get_ark_kernel(function(new_kernel) new_kernel:start_ark_lsp() end)
		end,
	})
end

local setup_vars = function()
	vim.api.nvim_create_user_command("ArkVariables", function(_args)
		require("jet.ark.utils").get_ark_kernel(function(k)
			if k.vars then
				k.vars:open()
			end
		end)
	end, { nargs = 0 })
end

---@param opts? Partial<jet.ark.config>
M.setup = function(opts)
	assert(
		require("jet").did_setup(),
		'jet.nvim has not done setup; run `require("jet").setup({})` before loading jet.ark'
	)

	config.set(opts or {})
	require("jet.ark.kernelspec").install()
	require("jet.ark.highlights").setup()

	setup_plot_auto_resize()
	setup_console_auto_resize()
	setup_help()
	setup_lsp()
	setup_vars()

	----------------------------
	--    Ark Kernel Setup    --
	----------------------------
	local jet = require("jet")

	-- Register a method for getting the current 'expression' for R files
	jet.filetype.r = require("jet.ark.get_code")

	-- Subclass all kernels with jet.ark's special kernelspec as ark.Kernel
	---@param k jet.Kernel
	table.insert(jet.hooks.on_kernel_init, function(k)
		if k.spec_path == config.data.kernelspec_path then
			-- Modifies the jet.Kernel object in place
			require("jet.ark.ark_kernel").from_kernel(k)
		end
	end)
end

return M
