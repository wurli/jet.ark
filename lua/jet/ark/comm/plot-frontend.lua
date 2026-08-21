-------------------------------------------------------------------------------
-- This file is auto-generated - do not edit by hand
--
--   Generator: scripts/gen_comm_lua.py
--   Source:    resources/positron-comms/plot-frontend-openrpc.json
-------------------------------------------------------------------------------

local util = require("jet.ark.comm.util")

local M = {}

---@class jet.ark.comm.plot_frontend.update.Params
---@field pre_render? jet.ark.comm.plot_backend.plot_result Optional pre-rendering data for immediate display

---Notification that a plot has been updated on the backend.
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.plot_frontend.update.Params
M.update = function(kernel, comm_id, params)
	return util.rpc_request(kernel, comm_id, "update", params)
end

---@class jet.ark.comm.plot_frontend.show.Params
---@field pre_render? jet.ark.comm.plot_backend.plot_result Optional pre-rendering data for immediate display

---Show a plot.
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.plot_frontend.show.Params
M.show = function(kernel, comm_id, params)
	return util.rpc_request(kernel, comm_id, "show", params)
end

return M
