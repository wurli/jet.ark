local M = {}

---@param win integer
---@param format? jet.ark.comm.plot_backend.plot_render_format
---@return jet.ark.comm.plot_backend.plot_render_settings
win_to_render_settings = function(win, format)
	return {
		format = format or "png",
		pixel_ratio = 2,
		size = {
			height = math.floor(vim.api.nvim_win_get_height(win) * 1.8) * 10,
			width = vim.api.nvim_win_get_width(win) * 10,
		},
	}
end

---@param k ark.Kernel
M.resize_curr_plot_debounced = require("jet.ark.utils").debounce(200, function(k)
	if not k.img or not k.img.img_file then
		return
	end

	local win = k.img:win()
	if not win then
		return
	end

	-- Currently Snacks doesn't refresh the displayed image when the
	-- underlying file changes, so instead of fighting just append a number
	-- to the filename and increment whenever the plot updates.
	local timestamp, comm_id, iteration =
		k.img.img_file:match("(%d%d%d%d%-%d%d%-%d%d_%d%d%-%d%d%-%d%d)_([^._]+)_(%d%d%d%d)%.[^.]+$")
	timestamp = timestamp or ""
	iteration = iteration and string.format("%04d", (tonumber(iteration) or 0) + 1) or ""

	if not comm_id then
		return
	end

	local new_settings = win_to_render_settings(win)

	-- Don't rerender plots if the size hasn't actually changed. This might
	-- happen, e.g. if the window was closed and reopened.
	if
		k.plot_sizes[comm_id]
		and new_settings.size.width == k.plot_sizes[comm_id].width
		and new_settings.size.height == k.plot_sizes[comm_id].height
	then
		return
	end

	-- require("jet.ark.comm.ui-backend").did_change_plots_render_settings(k, comm_id, {
	-- 	settings = new_settings,
	-- })
	---@diagnostic disable-next-line: param-type-mismatch
	require("jet.ark.comm.plot-backend").render(k, comm_id, new_settings, function(res)
		vim.fs.rm(k:img_dir() .. "/" .. k.img.img_file, { force = true })
		local file = k:img_save(res.data, res.mime_type, timestamp .. "_" .. comm_id .. "_" .. iteration)
		if file then
			k.plot_sizes = k.plot_sizes or {}
			k.plot_sizes[comm_id] = new_settings.size
			k:img_open(vim.fs.basename(file))
		end
		return true
	end)
end)

---@param k ark.Kernel
---@param comm_id string
---@param data jet.ark.comm.plot_frontend.show.Params
M.handle_plot_comm_open = function(k, comm_id, data)
	local pre_render_settings = data.pre_render and data.pre_render.settings and data.pre_render.settings or {}
	local params = win_to_render_settings(k:img_open(), pre_render_settings.format)
	---@diagnostic disable-next-line: param-type-mismatch
	require("jet.ark.comm.plot-backend").render(k, comm_id, params, function(res)
		local file = k:img_save(res.data, res.mime_type, comm_id .. "_0001")
		if file then
			-- We keep track of the current sizes of each plot to avoid unnecessary
			-- re-rendering in cases when the window hasn't changed size.
			k.plot_sizes[comm_id] = params.size
			k.hooks.on_image_display_pre.resize_curr_plot = function() k:resize_curr_plot() end
			k:img_open(vim.fs.basename(file))
		end
		return true
	end)
end

return M
