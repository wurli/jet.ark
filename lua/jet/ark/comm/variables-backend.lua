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

---An inspected variable.
---@class jet.ark.comm.variables_backend.inspected_variable
---@field children jet.ark.comm.variables_backend.variable[] The children of the inspected variable.
---@field length integer The total number of children. This may be greater than the number of children in the 'children' array if the array is truncated.

---An object formatted for copying to the clipboard.
---@class jet.ark.comm.variables_backend.formatted_variable
---@field content string The formatted content of the variable.

---Result of the summarize operation
---@class jet.ark.comm.variables_backend.query_table_summary_result
---@field num_rows integer The total number of rows in the table.
---@field num_columns integer The total number of columns in the table.
---@field column_schemas string[] The column schemas in the table.
---@field column_profiles string[] The column profiles in the table.

---List all variables
---
---Returns a list of all the variables in the current session.
---@param params {}
M.list = function(params)
	return util.rpc_message("list", params)
end

---@class jet.ark.comm.variables_backend.clear.Params
---@field include_hidden_objects boolean Whether to clear hidden objects in addition to normal variables

---Clear all variables
---
---Clears (deletes) all variables in the current session.
---@param params jet.ark.comm.variables_backend.clear.Params
M.clear = function(params)
	return util.rpc_message("clear", params)
end

---@class jet.ark.comm.variables_backend.delete.Params
---@field names string[] The names of the variables to delete.

---Deletes a set of named variables
---
---Deletes the named variables from the current session.
---@param params jet.ark.comm.variables_backend.delete.Params
M.delete = function(params)
	return util.rpc_message("delete", params)
end

---@class jet.ark.comm.variables_backend.inspect.Params
---@field path string[] The path to the variable to inspect, as an array of access keys.

---Inspect a variable
---
---Returns the children of a variable, as an array of variables.
---@param params jet.ark.comm.variables_backend.inspect.Params
M.inspect = function(params)
	return util.rpc_message("inspect", params)
end

---@class jet.ark.comm.variables_backend.clipboard_format.Params
---@field path string[] The path to the variable to format, as an array of access keys.
---@field format "text/html"|"text/plain" The requested format for the variable, as a MIME type

---Format for clipboard
---
---Requests a formatted representation of a variable for copying to the clipboard.
---@param params jet.ark.comm.variables_backend.clipboard_format.Params
M.clipboard_format = function(params)
	return util.rpc_message("clipboard_format", params)
end

---@class jet.ark.comm.variables_backend.view.Params
---@field path string[] The path to the variable to view, as an array of access keys.

---Request a viewer for a variable
---
---Request that the runtime open a data viewer to display the data in a variable.
---@param params jet.ark.comm.variables_backend.view.Params
M.view = function(params)
	return util.rpc_message("view", params)
end

---@class jet.ark.comm.variables_backend.query_table_summary.Params
---@field path string[] The path to the table to summarize, as an array of access keys.
---@field query_types string[] A list of query types.

---Query table summary
---
---Request a data summary for a table variable.
---@param params jet.ark.comm.variables_backend.query_table_summary.Params
M.query_table_summary = function(params)
	return util.rpc_message("query_table_summary", params)
end

return M
