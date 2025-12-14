local M = {}

local start_ark_lsp = function(id)
	local jet = require("jet.core.engine")
	local _, callback = jet.comm_open(id, "lsp", { ip_address = "127.0.0.1" })
	local function await_callback()
		while true do
			local result = callback()
			if result.status == "idle" then
				return
			end
			if not result.data then
				return vim.defer_fn(await_callback, 100)
			end
			local port = result.data.data.params.port
			vim.lsp.config.ark = {
				cmd = vim.lsp.rpc.connect("127.0.0.1", port),
				root_markers = { ".git", ".Rprofile", ".Rproj", "DESCRIPTION" },
				filetypes = { "r", "R" },
			}
			vim.lsp.enable("ark")
			return
		end
	end
	await_callback()
end

M.setup = function()
	local group = vim.api.nvim_create_augroup("Jet.Ark", { clear = true })
	vim.api.nvim_create_autocmd("User", {
		pattern = "JetKernelStarted",
		group = group,
		callback = function(e)
			local manager = require("jet.core.manager")
			local kernel = manager.running[e.data.kernel_id]

			if kernel.instance.spec.display_name ~= "Ark R Kernel" then
				return
			end

			manager.running[e.data.kernel_id]:execute({
				"options(cli.default_num_colors = 256L)",
				"options(cli.dynamic = TRUE)",
				"options(cli.hyperlink = TRUE)",
				"options(cli.hyperlink_run = TRUE)",
				"options(cli.hyperlink_help = TRUE)",
				"options(cli.hyperlink_vignette = TRUE)",
			})

			start_ark_lsp(e.data.kernel_id)
		end,
	})
end

return M
