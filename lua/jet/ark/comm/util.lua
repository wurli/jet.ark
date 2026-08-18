local M = {}

M.rpc_message = function(method, params)
	return {
		jsonrpc = "2.0",
		-- The id field makes this a JSON-RPC message according to Ark:
		-- https://github.com/posit-dev/positron/issues/7448
		id = vim.fn.rand(),
		method = method,
		params = params,
	}
end

return M
