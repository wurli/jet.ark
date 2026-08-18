-------------------------------------------------------------------------------
-- This file is auto-generated - do not edit by hand
--
--   Generator: scripts/gen_comm_lua.py
--   Source:    resources/positron-comms/data_explorer-frontend-openrpc.json
-------------------------------------------------------------------------------

local util = require("jet.ark.comm.util")

local M = {}

---Request to sync after a schema change
---
---Notify the data explorer to do a state sync after a schema change.
---@param kernel jet.Kernel
---@param params {}
M.schema_update = function(kernel, params)
	return util.rpc_request(kernel, "positron.data_explorer", "schema_update", params)
end

---Clear cache and request fresh data
---
---Triggered when there is any data change detected, clearing cache data and triggering a refresh/redraw.
---@param kernel jet.Kernel
---@param params {}
M.data_update = function(kernel, params)
	return util.rpc_request(kernel, "positron.data_explorer", "data_update", params)
end

---@class jet.ark.comm.data_explorer_frontend.return_column_profiles.Params
---@field callback_id string Async callback unique identifier
---@field profiles jet.ark.comm.data_explorer_backend.column_profile_result[] Array of individual column profile results
---@field error_message? string Optional error message if something failed to compute

---Return async result of get_column_profiles request
---@param kernel jet.Kernel
---@param params jet.ark.comm.data_explorer_frontend.return_column_profiles.Params
M.return_column_profiles = function(kernel, params)
	return util.rpc_request(kernel, "positron.data_explorer", "return_column_profiles", params)
end

return M
