-------------------------------------------------------------------------------
-- This file is auto-generated - do not edit by hand
--
--   Generator: scripts/gen_comm_lua.py
--   Source:    resources/positron-comms/variables-frontend-openrpc.json
-------------------------------------------------------------------------------

local util = require("jet.ark.comm.util")

local M = {}

---@class jet.ark.comm.variables_frontend.update.Params
---@field assigned jet.ark.comm.variables_backend.variable[] An array of variables that have been newly assigned.
---@field unevaluated jet.ark.comm.variables_backend.variable[] An array of variables that were not evaluated for value updates.
---@field removed string[] An array of variable names that have been removed.
---@field version integer The version of the view (incremented with each update), or 0 if the backend doesn't track versions.

---Update variables
---
---Updates the variables in the current session.
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.variables_frontend.update.Params
M.update = function(kernel, comm_id, params) return util.rpc_request(kernel, comm_id, "update", params) end

---@class jet.ark.comm.variables_frontend.refresh.Params
---@field variables jet.ark.comm.variables_backend.variable[] An array listing all the variables in the current session.
---@field length integer The number of variables in the current session.
---@field version integer The version of the view (incremented with each update), or 0 if the backend doesn't track versions.

---Refresh variables
---
---Replace all variables in the current session with the variables from the backend.
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.variables_frontend.refresh.Params
M.refresh = function(kernel, comm_id, params) return util.rpc_request(kernel, comm_id, "refresh", params) end

return M
