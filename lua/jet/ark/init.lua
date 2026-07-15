local config = require("jet.ark.config")
local comm = require("jet.ark.comm")
local lsp = require("jet.ark.lsp")

local M = {}

---@param opts? jet.ark.config
M.setup = function(opts)
	config.set(opts or {})
	require("jet.ark.kernelspec").install()

	----------------------------
	--    Ark Kernel Setup    --
	----------------------------

	-- Register ark.jet's special kernelspec as the one to use
	local jet_cfg = require("jet.config").options
	if jet_cfg.default_kernels.r then
		vim.notify("[jet.ark] Overriding default R kernel path")
	end
	jet_cfg.default_kernels.r = config.data.kernelspec_path

	-- Register a method for getting the current 'expression' for R files
	require("jet.core.send.get_code").filetype.r = require("jet.ark.get_code")

	-- Let jet know that Ark is for the 'r' filetype
	---@param k jet.kernel
	table.insert(jet_cfg.hooks.on_kernel_init, function(k)
		if k.spec_path == config.data.kernelspec_path then
			k.filetype = "r"
		end
	end)

	----------------------------
	--    Ark UI features     --
	----------------------------

	---@param k jet.kernel
	table.insert(jet_cfg.hooks.on_lua_client_start, function(k)
		-- We don't need to open a listener on the UI comm since right now only
		-- `working_directory` and `prompt_state` come through
		if k.filetype == "r" and k.spec.display_name:lower():find("ark") then
			k:comm_open("positron.ui", {})
		end
	end)

	vim.api.nvim_create_autocmd("WinResized", {
		group = vim.api.nvim_create_augroup("jet.ark", { clear = true }),
		callback = function()
			local resised_wins = vim.v.event.windows --[[ @as number[] ]]

			for _, win in ipairs(resised_wins) do
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.b[buf].jet then
					local session_id = vim.b[buf].jet.session_id --[[ @as string ]]
					if not session_id then
						return
					end

					local kernel = require("jet.core.manager").kernels[session_id]
					if not kernel then
						return
					end

					if kernel.spec_path == config.data.kernelspec_path then
						local comm_id = kernel.comms["positron.ui"]
						---@diagnostic disable-next-line: unnecessary-if
						if comm_id then
							kernel:comm_send(
								comm_id,
								-- Subtract 2 to account for indent added by external clients
								comm.call_method("setConsoleWidth", { vim.api.nvim_win_get_width(win) - 2 })
							)
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
	---@param k jet.kernel
	table.insert(jet_cfg.hooks.on_kernel_close, function(k)
		if k.filetype == "r" and k.spec.display_name:lower():find("ark") then
			-- Since the LSP has been stopped we wipe the config, since this
			-- records the IP and port the prev LSP was running on.
			vim.lsp.config.ark = {}
			if vim.bo.filetype == "r" then
				lsp.start_ark_lsp()
			end
		end
	end)
end

return M
