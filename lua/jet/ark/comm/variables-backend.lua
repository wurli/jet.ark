-------------------------------------------------------------------------------
-- This file is auto-generated - do not edit by hand
--
--   Generator: scripts/gen_comm_lua.py
--   Source:    resources/positron-comms/variables-backend-openrpc.json
-------------------------------------------------------------------------------

local util = require("jet.ark.comm.util")

local M = {}

---A single variable in the runtime.
---@class jet.ark.comm.variables_backend.variable
---@field access_key string A key that uniquely identifies the variable within the runtime and can be used to access the variable in `inspect` requests
---@field display_name string The name of the variable, formatted for display
---@field display_value string A string representation of the variable's value, formatted for display and possibly truncated
---@field display_type string The variable's type, formatted for display
---@field type_info string Extended information about the variable's type
---@field size integer The size of the variable's value in bytes
---@field kind "boolean"|"bytes"|"class"|"collection"|"empty"|"function"|"map"|"number"|"other"|"string"|"table"|"lazy"|"connection" The kind of value the variable represents, such as 'string' or 'number'
---@field length integer The number of elements in the variable, if it is a collection
---@field has_children boolean Whether the variable has child variables
---@field has_viewer boolean True if there is a viewer available for this variable (i.e. the runtime can handle a 'view' request for this variable)
---@field is_truncated boolean True if the 'value' field is a truncated representation of the variable's value
---@field updated_time integer The time the variable was created or updated, in milliseconds since the epoch, or 0 if unknown.

---A view containing a list of variables in the session.
---@class jet.ark.comm.variables_backend.variable_list
---@field variables jet.ark.comm.variables_backend.variable[] A list of variables in the session.
---@field length integer The total number of variables in the session. This may be greater than the number of variables in the 'variables' array if the array is truncated.
---@field version? integer The version of the view (incremented with each update)

---@alias jet.ark.comm.variables_backend.list.Reply jet.ark.comm.variables_backend.variable_list

---@alias jet.ark.comm.variables_backend.clear.Reply any

---@alias jet.ark.comm.variables_backend.delete.Reply string[]

---An inspected variable.
---@class jet.ark.comm.variables_backend.inspected_variable
---@field children jet.ark.comm.variables_backend.variable[] The children of the inspected variable.
---@field length integer The total number of children. This may be greater than the number of children in the 'children' array if the array is truncated.

---@alias jet.ark.comm.variables_backend.inspect.Reply jet.ark.comm.variables_backend.inspected_variable

---An object formatted for copying to the clipboard.
---@class jet.ark.comm.variables_backend.formatted_variable
---@field content string The formatted content of the variable.

---@alias jet.ark.comm.variables_backend.clipboard_format.Reply jet.ark.comm.variables_backend.formatted_variable

---@alias jet.ark.comm.variables_backend.view.Reply string

---Result of the summarize operation
---@class jet.ark.comm.variables_backend.query_table_summary_result
---@field num_rows integer The total number of rows in the table.
---@field num_columns integer The total number of columns in the table.
---@field column_schemas string[] The column schemas in the table.
---@field column_profiles string[] The column profiles in the table.

---@alias jet.ark.comm.variables_backend.query_table_summary.Reply jet.ark.comm.variables_backend.query_table_summary_result

---List all variables
---
---Returns a list of all the variables in the current session.
---@param kernel jet.Kernel
---@param params {}
---@param callback? fun(res: jet.ark.comm.variables_backend.list.Reply)
M.list = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.variables", "list", params, "ListReply", callback)
end

---@class jet.ark.comm.variables_backend.clear.Params
---@field include_hidden_objects boolean Whether to clear hidden objects in addition to normal variables

---Clear all variables
---
---Clears (deletes) all variables in the current session.
---@param kernel jet.Kernel
---@param params jet.ark.comm.variables_backend.clear.Params
---@param callback? fun(res: jet.ark.comm.variables_backend.clear.Reply)
M.clear = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.variables", "clear", params, "ClearReply", callback)
end

---@class jet.ark.comm.variables_backend.delete.Params
---@field names string[] The names of the variables to delete.

---Deletes a set of named variables
---
---Deletes the named variables from the current session.
---@param kernel jet.Kernel
---@param params jet.ark.comm.variables_backend.delete.Params
---@param callback? fun(res: jet.ark.comm.variables_backend.delete.Reply)
M.delete = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.variables", "delete", params, "DeleteReply", callback)
end

---@class jet.ark.comm.variables_backend.inspect.Params
---@field path string[] The path to the variable to inspect, as an array of access keys.

---Inspect a variable
---
---Returns the children of a variable, as an array of variables.
---@param kernel jet.Kernel
---@param params jet.ark.comm.variables_backend.inspect.Params
---@param callback? fun(res: jet.ark.comm.variables_backend.inspect.Reply)
M.inspect = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.variables", "inspect", params, "InspectReply", callback)
end

---@class jet.ark.comm.variables_backend.clipboard_format.Params
---@field path string[] The path to the variable to format, as an array of access keys.
---@field format "text/html"|"text/plain" The requested format for the variable, as a MIME type

---Format for clipboard
---
---Requests a formatted representation of a variable for copying to the clipboard.
---@param kernel jet.Kernel
---@param params jet.ark.comm.variables_backend.clipboard_format.Params
---@param callback? fun(res: jet.ark.comm.variables_backend.clipboard_format.Reply)
M.clipboard_format = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.variables", "clipboard_format", params, "ClipboardFormatReply", callback)
end

---@class jet.ark.comm.variables_backend.view.Params
---@field path string[] The path to the variable to view, as an array of access keys.

---Request a viewer for a variable
---
---Request that the runtime open a data viewer to display the data in a variable.
---@param kernel jet.Kernel
---@param params jet.ark.comm.variables_backend.view.Params
---@param callback? fun(res: jet.ark.comm.variables_backend.view.Reply)
M.view = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.variables", "view", params, "ViewReply", callback)
end

---@class jet.ark.comm.variables_backend.query_table_summary.Params
---@field path string[] The path to the table to summarize, as an array of access keys.
---@field query_types string[] A list of query types.

---Query table summary
---
---Request a data summary for a table variable.
---@param kernel jet.Kernel
---@param params jet.ark.comm.variables_backend.query_table_summary.Params
---@param callback? fun(res: jet.ark.comm.variables_backend.query_table_summary.Reply)
M.query_table_summary = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.variables", "query_table_summary", params, "QueryTableSummaryReply", callback)
end

return M
