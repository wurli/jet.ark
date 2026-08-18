-------------------------------------------------------------------------------
-- This file is auto-generated - do not edit by hand
--
--   Generator: scripts/gen_comm_lua.py
--   Source:    resources/positron-comms/plot-backend-openrpc.json
-------------------------------------------------------------------------------

local util = require("jet.ark.comm.util")

local M = {}

---The unit of measurement of a plot's dimensions
---@alias jet.ark.comm.plot_backend.plot_unit "pixels"|"inches"

---The size of a plot
---@class jet.ark.comm.plot_backend.plot_size
---@field height integer The plot's height, in pixels
---@field width integer The plot's width, in pixels

---The origin (source) of a plot
---@class jet.ark.comm.plot_backend.plot_origin
---@field uri string The URI of the document containing the code that produced the plot, if available
---@field range? jet.ark.comm.plot_backend.plot_range The range within the document at uri that produced the plot, if available

---The range of a plot within a document
---@class jet.ark.comm.plot_backend.plot_range
---@field start_line integer The line number on which the plot starts (0-indexed)
---@field start_character integer The character number on which the plot starts (0-indexed)
---@field end_line integer The line number on which the plot ends (0-indexed)
---@field end_character integer The character number on which the plot ends (0-indexed)

---The requested plot format
---@alias jet.ark.comm.plot_backend.plot_render_format "png"|"jpeg"|"svg"|"pdf"|"tiff"

---The settings used to render the plot
---@class jet.ark.comm.plot_backend.plot_render_settings
---@field size jet.ark.comm.plot_backend.plot_size Plot size to render the plot to
---@field pixel_ratio number The pixel ratio of the display device
---@field format jet.ark.comm.plot_backend.plot_render_format Format in which to render the plot

---The intrinsic size of a plot, if known
---@class jet.ark.comm.plot_backend.intrinsic_size
---@field width number The width of the plot
---@field height number The height of the plot
---@field unit jet.ark.comm.plot_backend.plot_unit The unit of measurement of the plot's dimensions
---@field source string The source of the intrinsic size e.g. 'Matplotlib'

---The plot's metadata
---@class jet.ark.comm.plot_backend.plot_metadata
---@field name string A unique, human-readable name for the plot
---@field kind string The kind of plot e.g. 'Matplotlib', 'ggplot2', etc.
---@field execution_id string The ID of the code fragment that produced the plot
---@field code string The code fragment that produced the plot
---@field origin? jet.ark.comm.plot_backend.plot_origin The origin of the plot, if known

---A rendered plot
---@class jet.ark.comm.plot_backend.plot_result
---@field data string The plot data, as a base64-encoded string
---@field mime_type string The MIME type of the plot data
---@field settings? jet.ark.comm.plot_backend.plot_render_settings The settings used to render the plot

---Get the intrinsic size of a plot, if known.
---
---The intrinsic size of a plot is the size at which a plot would be if no size constraints were applied by Positron.
---@param params {}
M.get_intrinsic_size = function(params)
	return util.rpc_message("get_intrinsic_size", params)
end

---Get metadata for the plot
---@param params {}
M.get_metadata = function(params)
	return util.rpc_message("get_metadata", params)
end

---@class jet.ark.comm.plot_backend.render.Params
---@field size? jet.ark.comm.plot_backend.plot_size The requested size of the plot. If not provided, the plot will be rendered at its intrinsic size.
---@field pixel_ratio number The pixel ratio of the display device
---@field format jet.ark.comm.plot_backend.plot_render_format The requested plot format

---Render a plot
---
---Requests a plot to be rendered. The plot data is returned in a base64-encoded string.
---@param params jet.ark.comm.plot_backend.render.Params
M.render = function(params)
	return util.rpc_message("render", params)
end

return M
