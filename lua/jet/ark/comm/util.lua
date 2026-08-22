local M = {}

---@param kernel jet.Kernel
---@param comm string
---@param method string
---@param params? table
---@param reply_method? string
---@param callback? fun(res: any)
M.rpc_request = function(kernel, comm, method, params, reply_method, callback)
	local msg_id = kernel:comm_send(comm, {
		jsonrpc = "2.0",
		-- The id field makes this a JSON-RPC message according to Ark:
		-- https://github.com/posit-dev/positron/issues/7448
		id = vim.fn.rand(),
		method = method,
		params = params,
	})

	if callback then
		kernel.on_message_received[msg_id] = function(_, m)
			if
				-- m.parent_header
				-- and m.parent_header == msg_id
				m.content
				and m.content.data
				and m.content.data.method == reply_method
			then
				if callback(m.content.data.result) then
					kernel.on_message_received[msg_id] = nil
				end
			end
		end
	end
end

return M
