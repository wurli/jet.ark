local config = require("jet.ark.config")
local comm = require("jet.ark.comm")

local M = {}

---@param opts? jet.ark.config
M.setup = function(opts)
	config.set(opts or {})

	local jet_cfg = require("jet.config").options
	if jet_cfg.default_kernels.r then
		vim.notify("[jet.ark] Overriding default R kernel path")
	end
	jet_cfg.default_kernels.r = config.data.kernelspec_path

	require("jet.ark.kernelspec").install()
	require("jet.ark.lsp").setup()

	local augroup = vim.api.nvim_create_augroup("jet.ark", { clear = true })

	vim.api.nvim_create_autocmd("User", {
		pattern = "JetKernelStarted",
		group = augroup,
		callback = function(e)
			print("here")

			local data = e.data --[[@as jet.autocmd.data.JetKernelStarted]]
			if data.kernelspec_path ~= config.data.kernelspec_path then
				return
			end

			local kernel = require("jet.core.manager").kernels[data.session_id]
			if not kernel then
				return
			end

			kernel:comm_open("positron.ui", {}, {
				listener = function(msg)
					vim.print(msg)
				end,
			})
		end,
	})
	vim.api.nvim_create_autocmd("WinResized", {
		group = augroup,
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
						if comm_id then
							kernel:comm_send(
								comm_id,
								comm.call_method("setConsoleWidth", { vim.api.nvim_win_get_width(win) })
							)
						end
					end
				end
			end
		end,
	})
end

return M
