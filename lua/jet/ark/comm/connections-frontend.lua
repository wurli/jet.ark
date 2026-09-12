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
---@param comm_id string
M.focus = function(kernel, comm_id) return util.rpc_request(kernel, comm_id, "focus", nil) end

---Request the UI to refresh the connection information
---@param kernel jet.Kernel
---@param comm_id string
M.update = function(kernel, comm_id) return util.rpc_request(kernel, comm_id, "update", nil) end

return M
