-------------------------------------------------------------------------------
-- This file is auto-generated - do not edit by hand
--
--   Generator: scripts/gen_comm_lua.py
--   Source:    resources/positron-comms/ui-backend-openrpc.json
-------------------------------------------------------------------------------

local util = require("jet.ark.comm.util")

local M = {}

---@alias jet.ark.comm.ui_backend.call_method.Reply any

---The results of evaluating the statement
---@class jet.ark.comm.ui_backend.eval_result
---@field result any The result value
---@field output string The output, if any, emitted during evaluation

---@alias jet.ark.comm.ui_backend.evaluate_code.Reply jet.ark.comm.ui_backend.eval_result

---@class jet.ark.comm.ui_backend.did_change_plots_render_settings.Params
---@field settings jet.ark.comm.plot_backend.plot_render_settings Plot rendering settings.

---Notification that the settings to render a plot (i.e. the plot size) have changed.
---
---Typically fired when the plot component has been resized by the user. This notification is useful to produce accurate pre-renderings of plots.
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.ui_backend.did_change_plots_render_settings.Params
M.did_change_plots_render_settings = function(kernel, comm_id, params)
	return util.rpc_request(kernel, comm_id, "did_change_plots_render_settings", params)
end

---@class jet.ark.comm.ui_backend.frontend_ready.Params
---@field start_type string The type of session start: 'new' for new sessions, 'restart' for restarted sessions, 'reconnect' for reconnected sessions

---Notification that the frontend is ready
---
---This notification is sent by the frontend after the UI comm has been established. The backend uses this signal to run session initialization hooks that may need to communicate with the frontend via RPCs (e.g. rstudioapi calls).
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.ui_backend.frontend_ready.Params
M.frontend_ready = function(kernel, comm_id, params)
	return util.rpc_request(kernel, comm_id, "frontend_ready", params)
end

---@class jet.ark.comm.ui_backend.call_method.Params
---@field method string The method to call inside the interpreter
---@field params any[] The parameters for `method`

---Run a method in the interpreter and return the result to the frontend
---
---Unlike other RPC methods, `call_method` calls into methods implemented in the interpreter and returns the result back to the frontend using an implementation-defined serialization scheme.
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.ui_backend.call_method.Params
---@param callback? fun(res: jet.ark.comm.ui_backend.call_method.Reply): boolean
M.call_method = function(kernel, comm_id, params, callback)
	return util.rpc_request(kernel, comm_id, "call_method", params, "CallMethodReply", callback)
end

---@class jet.ark.comm.ui_backend.evaluate_code.Params
---@field code string The code string to evaluate

---Evaluate a statement in the interpreter
---
---Execute a code fragment silently and return a JSON-serialized result.
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.ui_backend.evaluate_code.Params
---@param callback? fun(res: jet.ark.comm.ui_backend.evaluate_code.Reply): boolean
M.evaluate_code = function(kernel, comm_id, params, callback)
	return util.rpc_request(kernel, comm_id, "evaluate_code", params, "EvaluateCodeReply", callback)
end

return M
