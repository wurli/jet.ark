local M = {}

---@param kernel? jet.kernel
M.start_ark_lsp = function(kernel)
	if not kernel then
		local spec = require("jet.ark.config").data.kernelspec_path
		local inactive = require("jet.core.api").list_kernels({ spec_path = spec, status = { "inactive" } })
		local connected = require("jet.core.api").list_kernels({ spec_path = spec, status = { "connected" } })
		kernel = connected[1] or inactive[1]
	end

	assert(kernel, "No Ark kernel found. Please start an Ark kernel first")

	kernel:start_lua_client(function(k)
		---@diagnostic disable-next-line: unnecessary-if
		-- Prevents starting multiple LSPs on the same kernel
		if k.comms.lsp then
			return
		end

		local ip = "127.0.0.1"

		k:comm_open("lsp", { ip_address = ip }, {
			listener = function(msg)
				local port = msg.content.data and msg.content.data.params and msg.content.data.params.port

				vim.lsp.config("ark", {
					cmd = vim.lsp.rpc.connect(ip, port),
					root_markers = { ".git", ".Rprofile", ".Rproj", "DESCRIPTION" },
					filetypes = { "r" },
					root_dir = ".",
				})

				vim.lsp.enable("ark")
			end,
		})
	end)
end

M.setup = function() end

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
