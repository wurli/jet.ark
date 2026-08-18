local util = require("jet.ark.comm.util")

local M = {}

---@param method string
---@param params any
M.call_method = function(method, params)
	return util.rpc_message("call_method", {
		method = method,
		params = params,
	})
end

return M
