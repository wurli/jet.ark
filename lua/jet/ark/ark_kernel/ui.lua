local ui_backend = require("jet.ark.comm.ui-backend")

local M = {}

---@param k ark.Kernel
M.start_comm = function(k)
	-- This tells Ark to listen for ui comm messages, e.g. like
	-- setConsoleWidth below.
	local ui_comm_id = k:comm_open("positron.ui")

	ui_backend.frontend_ready(k, ui_comm_id, { start_type = "new" })

	ui_backend.did_change_plots_render_settings(k, ui_comm_id, {
		settings = {
			format = "png",
			pixel_ratio = 4,
			size = {
				height = 400 * 3,
				width = 640 * 3,
			},
		},
	})
end

---@param k ark.Kernel
---@param width integer
M.set_console_width = function(k, width)
	local comm_id = k:get_comm("positron.ui")
	if comm_id then
		require("jet.ark.comm.ui-backend").call_method(k, comm_id, {
			method = "setConsoleWidth",
			params = { width - 2 },
		})
	end
end

return M
