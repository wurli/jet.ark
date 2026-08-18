-------------------------------------------------------------------------------
-- This file is auto-generated - do not edit by hand
--
--   Generator: scripts/gen_comm_lua.py
--   Source:    resources/positron-comms/connections-backend-openrpc.json
-------------------------------------------------------------------------------

local util = require("jet.ark.comm.util")

local M = {}

---@class jet.ark.comm.connections_backend.object_schema
---@field name string Name of the underlying object
---@field kind string The object type (table, catalog, schema)
---@field has_children? boolean Indicates if the object has children that can be listed. This property is optional and when omitted, it is assumed that the object may have children unless its kind is 'field'.

---@class jet.ark.comm.connections_backend.field_schema
---@field name string Name of the field
---@field dtype string The field data type

---@class jet.ark.comm.connections_backend.metadata_schema
---@field name string Connection name
---@field language_id string Language ID for the connections. Essentially just R or python
---@field host? string Connection host
---@field type? string Connection type
---@field code? string Code used to re-create the connection

---@alias jet.ark.comm.connections_backend.list_objects.Reply jet.ark.comm.connections_backend.object_schema[]

---@alias jet.ark.comm.connections_backend.list_fields.Reply jet.ark.comm.connections_backend.field_schema[]

---@alias jet.ark.comm.connections_backend.contains_data.Reply boolean

---@alias jet.ark.comm.connections_backend.get_icon.Reply string

---@alias jet.ark.comm.connections_backend.preview_object.Reply nil

---@alias jet.ark.comm.connections_backend.get_metadata.Reply jet.ark.comm.connections_backend.metadata_schema

---@class jet.ark.comm.connections_backend.list_objects.Params
---@field path jet.ark.comm.connections_backend.object_schema[] The path to object that we want to list children.

---List objects within a data source
---
---List objects within a data source, such as schemas, catalogs, tables and views.
---@param kernel jet.Kernel
---@param params jet.ark.comm.connections_backend.list_objects.Params
---@param callback? fun(res: jet.ark.comm.connections_backend.list_objects.Reply)
M.list_objects = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.connections", "list_objects", params, "ListObjectsReply", callback)
end

---@class jet.ark.comm.connections_backend.list_fields.Params
---@field path jet.ark.comm.connections_backend.object_schema[] The path to object that we want to list fields.

---List fields of an object
---
---List fields of an object, such as columns of a table or view.
---@param kernel jet.Kernel
---@param params jet.ark.comm.connections_backend.list_fields.Params
---@param callback? fun(res: jet.ark.comm.connections_backend.list_fields.Reply)
M.list_fields = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.connections", "list_fields", params, "ListFieldsReply", callback)
end

---@class jet.ark.comm.connections_backend.contains_data.Params
---@field path jet.ark.comm.connections_backend.object_schema[] The path to object that we want to check if it contains data.

---Check if an object contains data
---
---Check if an object contains data, such as a table or view.
---@param kernel jet.Kernel
---@param params jet.ark.comm.connections_backend.contains_data.Params
---@param callback? fun(res: jet.ark.comm.connections_backend.contains_data.Reply)
M.contains_data = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.connections", "contains_data", params, "ContainsDataReply", callback)
end

---@class jet.ark.comm.connections_backend.get_icon.Params
---@field path jet.ark.comm.connections_backend.object_schema[] The path to object that we want to get the icon.

---Get icon of an object
---
---Get icon of an object, such as a table or view.
---@param kernel jet.Kernel
---@param params jet.ark.comm.connections_backend.get_icon.Params
---@param callback? fun(res: jet.ark.comm.connections_backend.get_icon.Reply)
M.get_icon = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.connections", "get_icon", params, "GetIconReply", callback)
end

---@class jet.ark.comm.connections_backend.preview_object.Params
---@field path jet.ark.comm.connections_backend.object_schema[] The path to object that we want to preview.

---Preview object data
---
---Preview object data, such as a table or view.
---@param kernel jet.Kernel
---@param params jet.ark.comm.connections_backend.preview_object.Params
---@param callback? fun(res: jet.ark.comm.connections_backend.preview_object.Reply)
M.preview_object = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.connections", "preview_object", params, "PreviewObjectReply", callback)
end

---@class jet.ark.comm.connections_backend.get_metadata.Params
---@field comm_id string The comm_id of the client we want to retrieve metdata for.

---Gets metadata from the connections
---
---A connection has tied metadata such as an icon, the host, etc.
---@param kernel jet.Kernel
---@param params jet.ark.comm.connections_backend.get_metadata.Params
---@param callback? fun(res: jet.ark.comm.connections_backend.get_metadata.Reply)
M.get_metadata = function(kernel, params, callback)
	return util.rpc_request(kernel, "positron.connections", "get_metadata", params, "GetMetadataReply", callback)
end

return M
