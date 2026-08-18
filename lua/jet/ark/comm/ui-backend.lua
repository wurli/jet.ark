-------------------------------------------------------------------------------
-- This file is auto-generated - do not edit by hand
--
--   Generator: scripts/gen_comm_lua.py
--   Source:    resources/positron-comms/ui-backend-openrpc.json
-------------------------------------------------------------------------------

local util = require("jet.ark.comm.util")

local M = {}

---The results of evaluating the statement
---@class jet.ark.comm.ui_backend.eval_result
---@field result any The result value
---@field output string The output, if any, emitted during evaluation

---@class jet.ark.comm.ui_backend.did_change_plots_render_settings.Params
---@field settings jet.ark.comm.plot_backend.plot_render_settings Plot rendering settings.

---Notification that the settings to render a plot (i.e. the plot size) have changed.
---
---Typically fired when the plot component has been resized by the user. This notification is useful to produce accurate pre-renderings of plots.
---@param params jet.ark.comm.ui_backend.did_change_plots_render_settings.Params
M.did_change_plots_render_settings = function(params)
	return util.rpc_message("did_change_plots_render_settings", params)
end

---@class jet.ark.comm.ui_backend.frontend_ready.Params
---@field start_type string The type of session start: 'new' for new sessions, 'restart' for restarted sessions, 'reconnect' for reconnected sessions

---Notification that the frontend is ready
---
---This notification is sent by the frontend after the UI comm has been established. The backend uses this signal to run session initialization hooks that may need to communicate with the frontend via RPCs (e.g. rstudioapi calls).
---@param params jet.ark.comm.ui_backend.frontend_ready.Params
M.frontend_ready = function(params)
	return util.rpc_message("frontend_ready", params)
end

---@class jet.ark.comm.ui_backend.call_method.Params
---@field method string The method to call inside the interpreter
---@field params any[] The parameters for `method`

---Run a method in the interpreter and return the result to the frontend
---
---Unlike other RPC methods, `call_method` calls into methods implemented in the interpreter and returns the result back to the frontend using an implementation-defined serialization scheme.
---@param params jet.ark.comm.ui_backend.call_method.Params
M.call_method = function(params)
	return util.rpc_message("call_method", params)
end

---@class jet.ark.comm.ui_backend.evaluate_code.Params
---@field code string The code string to evaluate

---Evaluate a statement in the interpreter
---
---Execute a code fragment silently and return a JSON-serialized result.
---@param params jet.ark.comm.ui_backend.evaluate_code.Params
M.evaluate_code = function(params)
	return util.rpc_message("evaluate_code", params)
end

return M
