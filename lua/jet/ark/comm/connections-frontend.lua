-------------------------------------------------------------------------------
-- This file is auto-generated - do not edit by hand
--
--   Generator: scripts/gen_comm_lua.py
--   Source:    resources/positron-comms/connections-frontend-openrpc.json
-------------------------------------------------------------------------------

local util = require("jet.ark.comm.util")

local M = {}

---Request to focus the Connections pane
---@param kernel jet.Kernel
M.focus = function(kernel)
	return util.rpc_request(kernel, "positron.connections", "focus", nil)
end

---Request the UI to refresh the connection information
---@param kernel jet.Kernel
M.update = function(kernel)
	return util.rpc_request(kernel, "positron.connections", "update", nil)
end

return M
