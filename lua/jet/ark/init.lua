local config = require("jet.ark.config")
local lsp = require("jet.ark.lsp")

local M = {}

---@param opts? Partial<jet.ark.config>
M.setup = function(opts)
	assert(
		require("jet").did_setup(),
		'jet.nvim has not done setup; run `require("jet").setup({})` before loading jet.ark'
	)

	config.set(opts or {})
	require("jet.ark.kernelspec").install()
	require("jet.ark.plot").setup()

	----------------------------
	--    Ark Kernel Setup    --
	----------------------------

	-- Register ark.jet's special kernelspec as the one to use
	local jet_cfg = require("jet.core.config").options

	-- Register a method for getting the current 'expression' for R files
	require("jet").filetype.r = require("jet.ark.get_code")

	-- Let jet know that Ark is for the 'r' filetype
	---@param k jet.Kernel
	table.insert(jet_cfg.hooks.on_kernel_init, function(k)
		if k.spec_path == config.data.kernelspec_path then
			require("jet.ark.ark_kernel").from_kernel(k)
			-- k.filetype = "r"
			-- k.priority = 200
			-- k.known_comms["positron.plot"] = require("jet.ark.plot").comm_open_handler
		end
	end)

	----------------------------
	--    Ark UI features     --
	----------------------------

	---@param k jet.Kernel
	jet_cfg.hooks.on_lua_client_start.start_comms = function(k)
		-- We don't need to open a listener on the UI comm since right now only
		-- `working_directory` and `prompt_state` come through
		if k.filetype == "r" and k.spec.display_name:lower():find("ark") then
			-- This tells Ark to listen for ui comm messages, e.g. like
			-- setConsoleWidth below.
			local ui_comm_id = k:comm_open("positron.ui")

			require("jet.ark.comm.ui-backend").frontend_ready(k, ui_comm_id, { start_type = "new" })
			require("jet.ark.comm.ui-backend").did_change_plots_render_settings(k, ui_comm_id, {
				settings = {
					format = "png",
					pixel_ratio = 4,
					size = {
						height = 400 * 3,
						width = 640 * 3,
					},
				},
			})
			k:comm_open("positron.help", {}, { listener = require("jet.ark.help").listener })
			k:comm_open("positron.variables", {}, { listener = require("jet.ark.variables").listener })
			lsp.start_ark_lsp(k)
		end
	end

	jet_cfg.hooks.on_kernel_close.stop_ark_lsp = function(k)
		k.metadata = k.metadata or {}
		if k.metadata.ark_lsp then
			vim.lsp.enable(k.metadata.ark_lsp, false)
			vim.lsp.config[k.metadata.ark_lsp] = {}
		end
	end

	require("jet.ark.variables").setup()
	require("jet.ark.help").setup()

	vim.api.nvim_create_autocmd("WinResized", {
		group = vim.api.nvim_create_augroup("jet.ark", { clear = true }),
		callback = function()
			local resized_wins = vim.v.event.windows --[[@as integer[] ]]

			for _, win in ipairs(resized_wins) do
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.b[buf].jet then
					local session_id = vim.b[buf].jet.session_id --[[@as string]]
					if not session_id then
						return
					end

					local kernel = require("jet.core.manager").kernels[session_id]
					if not kernel then
						return
					end

					if kernel.spec_path == config.data.kernelspec_path then
						for comm_id, comm in pairs(kernel.open_comms) do
							if comm.name == "positron.ui" then
								require("jet.ark.comm.ui-backend").call_method(kernel, comm_id, {
									method = "setConsoleWidth",
									params = { vim.api.nvim_win_get_width(win) - 2 },
								})
							end
						end
					end
				end
			end
		end,
	})

	----------------------------
	--       Ark LSP          --
	----------------------------

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
			lsp.start_ark_lsp()
		end,
	})

	-- For convenience, if we close Ark _and_ we're in an R file, start the LSP
	-- up again (this happens on BufEnter, but BufEnter isn't triggered if
	-- we're in an R file when the kernel is closed)
	---@param k jet.Kernel
	table.insert(jet_cfg.hooks.on_kernel_close, function(k)
		if k.filetype == "r" and k.spec.display_name:lower():find("ark") then
			-- Since the LSP has been stopped we wipe the config, since this
			-- records the IP and port the prev LSP was running on.
			vim.lsp.config("ark", {})
			if vim.bo.filetype == "r" then
				lsp.start_ark_lsp()
			end
		end
	end)
end

return M
