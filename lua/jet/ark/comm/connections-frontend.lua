-------------------------------------------------------------------------------
-- This file is auto-generated - do not edit by hand
--
--   Generator: scripts/gen_comm_lua.py
--   Source:    resources/positron-comms/connections-frontend-openrpc.json
-------------------------------------------------------------------------------

local util = require("jet.ark.comm.util")

local M = {}

---Request to focus the Connections pane
---@param params {}
M.focus = function(params)
	return util.rpc_message("focus", params)
end

---Request the UI to refresh the connection information
---@param params {}
M.update = function(params)
	return util.rpc_message("update", params)
end

return M
