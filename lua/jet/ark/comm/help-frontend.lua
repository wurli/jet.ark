-------------------------------------------------------------------------------
-- This file is auto-generated - do not edit by hand
--
--   Generator: scripts/gen_comm_lua.py
--   Source:    resources/positron-comms/help-frontend-openrpc.json
-------------------------------------------------------------------------------

local util = require("jet.ark.comm.util")

local M = {}

---@class jet.ark.comm.help_frontend.show_help.Params
---@field content string The help content to show
---@field kind "html"|"markdown"|"url" The type of content to show
---@field focus boolean Whether to focus the Help pane when the content is displayed.

---Request to show help in the frontend
---@param kernel jet.Kernel
---@param comm_id string
---@param params jet.ark.comm.help_frontend.show_help.Params
M.show_help = function(kernel, comm_id, params) return util.rpc_request(kernel, comm_id, "show_help", params) end

return M
