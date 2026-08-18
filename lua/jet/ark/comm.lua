local M = {}

local rpc_message = function(method, params)
	return {
		jsonrpc = "2.0",
		-- The id field makes this a JSON-RPC message according to Ark:
		-- https://github.com/posit-dev/positron/issues/7448
		id = vim.fn.rand(),
		method = method,
		params = params,
	}
end

---@param method string
---@param params any
M.call_method = function(method, params)
	return rpc_message("call_method", {
		method = method,
		params = params,
	})
end

M.show_help_topic = function() end

return M
