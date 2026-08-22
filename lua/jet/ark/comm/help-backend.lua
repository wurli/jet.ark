-------------------------------------------------------------------------------
-- This file is auto-generated - do not edit by hand
--
--   Generator: scripts/gen_comm_lua.py
--   Source:    resources/positron-comms/help-backend-openrpc.json
-------------------------------------------------------------------------------

local util = require("jet.ark.comm.util")

local M = {}

---@alias jet.ark.comm.help_backend.show_help_topic.Reply boolean

---@class jet.ark.comm.help_backend.show_help_topic.Params
---@field topic string The help topic to show

---Look for and, if found, show a help topic.
---
---Requests that the help backend look for a help topic and, if found, show it. If the topic is found, it will be shown via a Show Help notification. If the topic is not found, no notification will be delivered.
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.help_backend.show_help_topic.Params
---@param callback? fun(res: jet.ark.comm.help_backend.show_help_topic.Reply): boolean
M.show_help_topic = function(kernel, comm_id, params, callback)
	return util.rpc_request(kernel, comm_id, "show_help_topic", params, "ShowHelpTopicReply", callback)
end

return M
