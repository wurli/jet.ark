local M = {}

---@param kernel ark.Kernel
M.start_ark_lsp = function(kernel)
	---@param k ark.Kernel
	kernel:start_lua_client(function(k)
		---@diagnostic disable-next-line: unnecessary-if
		-- Prevents starting multiple LSPs on the same kernel
		if k.open_comms.lsp or k.ark_lsp_starting then
			return
		end

		local ip = "127.0.0.1"
		k.ark_lsp_starting = true

		k:comm_open("lsp", { ip_address = ip }, {
			listener = function(msg)
				local port = msg.content.data and msg.content.data.params and msg.content.data.params.port
				k.metadata.ark_lsp = "ark_" .. k.session_id

				vim.lsp.config(k.metadata.ark_lsp, {
					cmd = vim.lsp.rpc.connect(ip, port),
					root_markers = { ".git", ".Rprofile", ".Rproj", "DESCRIPTION" },
					filetypes = { "r" },
					root_dir = ".",
				})

				vim.lsp.enable(k.metadata.ark_lsp)

				k.ark_lsp_starting = false
			end,
		})
	end)
end

return M
