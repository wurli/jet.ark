local M = {}

M.setup = function()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "r",
		group = vim.api.nvim_create_augroup("jet.ark.lsp", { clear = true }),
		once = true,
		callback = function()
			require("jet.core.api").repl({
				filetype = "r",
				hidden = true,
				---@param kernel jet.kernel
				callback = function(kernel)
					local ip = "127.0.0.1"

					kernel:comm_open("lsp", { ip_address = ip }, {
						listener = function(res)
							--TODO: sesms we're getting duplicate messages?
							-- vim.print(res)

							local port = res.data
								and res.data.data
								and res.data.data.params
								and res.data.data.params.port

							vim.lsp.config.ark = {
								cmd = vim.lsp.rpc.connect(ip, port),
								root_markers = { ".git", ".Rprofile", ".Rproj", "DESCRIPTION" },
								filetypes = { "r", "R" },
								root_dir = ".",
							}

							vim.lsp.enable("ark")
						end,
					})
				end,
			})
		end,
	})
end

return M

-- local start_ark_lsp = function(id)
-- 	local jet = require("jet.core.engine")
-- 	local _, callback = jet.comm_open(id, "lsp", { ip_address = "127.0.0.1" })
-- 	local function await_callback()
-- 		local timeout = 3000
-- 		local start_time = os.time()
-- 		while true do
-- 			if os.difftime(start_time, os.time()) > timeout then
-- 				print("Ark LSP connection request timed out")
-- 				return
-- 			end
-- 			local result = callback()
-- 			if not result then
-- 				return
-- 			end
-- 			if not result.data then
-- 				return vim.defer_fn(await_callback, 100)
-- 			end
--
-- 			vim.lsp.config.ark = {
-- 				cmd = vim.lsp.rpc.connect("127.0.0.1", result.data.data.params.port),
-- 				root_markers = { ".git", ".Rprofile", ".Rproj", "DESCRIPTION" },
-- 				filetypes = { "r", "R" },
-- 				root_dir = ".",
-- 			}
-- 			vim.lsp.enable("ark")
-- 			return
-- 		end
-- 	end
-- 	await_callback()
-- end
