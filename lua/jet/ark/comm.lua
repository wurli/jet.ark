local M = {}

---@param method string
---@param params any
M.call_method = function(method, params)
	return {
		jsonrpc = "2.0",
		-- The id field makes this a JSON-RPC message according to Ark:
		-- https://github.com/posit-dev/positron/issues/7448
		id = vim.fn.rand(),
		method = "call_method",
		params = {
			method = method,
			params = params,
		},
	}
end

return M
