local M = {}

--@class jet.ark.comm.plot_backend.render.Params
--@field size? jet.ark.comm.plot_backend.plot_size The requested size of the plot. If not provided, the plot will be rendered at its intrinsic size.
--@field pixel_ratio number The pixel ratio of the display device
--@field format jet.ark.comm.plot_backend.plot_render_format The requested plot format

---@param win integer
---@param format? jet.ark.comm.plot_backend.plot_render_format
---@return jet.ark.comm.plot_backend.plot_render_settings
local win_to_render_settings = function(win, format)
	return {
		format = format or "png",
		pixel_ratio = 2,
		size = {
			height = math.floor(vim.api.nvim_win_get_height(win) * 1.8) * 20,
			width = vim.api.nvim_win_get_width(win) * 20,
		},
	}
end

---@param k jet.Kernel
---@param comm_id string
---@param data jet.ark.comm.plot_frontend.show.Params
M.comm_open_handler = function(k, comm_id, data)
	local pre_render_settings = data.pre_render and data.pre_render.settings and data.pre_render.settings or {}
	local params = win_to_render_settings(k:open_images(), pre_render_settings.format)
	---@diagnostic disable-next-line: param-type-mismatch
	require("jet.ark.comm.plot-backend").render(k, comm_id, params, function(res)
		local file = k:save_image(res.data, res.mime_type, comm_id .. "_0001")
		if file then
			k:open_images(vim.fs.basename(file))
		end
		return true
	end)
end

---Debounce a function: delays execution until `ms` milliseconds have passed
---since the last call. Rapid calls reset the timer.
---@generic T
---@param f T
---@param delay integer
---@return T debounced function
---@return fun() cancel
local debounce = function(delay, f)
	local timer = nil
	local cancel = function()
		if timer then
			timer:stop()
			timer:close()
			timer = nil
		end
	end
	local debounced = function(...)
		local args = { ... }
		cancel()
		timer = assert(vim.uv.new_timer(), "Failed to create timer")
		timer:start(
			delay,
			0,
			vim.schedule_wrap(function()
				cancel()
				f(unpack(args))
			end)
		)
	end
	return debounced, cancel
end

---@param k jet.Kernel
local update_plot_size = debounce(200, function(k)
	if k.img and k.img.img_file then
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

		if comm_id then
			require("jet.ark.comm.ui-backend").did_change_plots_render_settings(k, comm_id, {
				settings = win_to_render_settings(win),
			})
			require("jet.ark.comm.plot-backend").render(
				k,
				comm_id,
				---@diagnostic disable-next-line: param-type-mismatch
				win_to_render_settings(win),
				function(res)
					vim.fs.rm(k:image_dir() .. "/" .. k.img.img_file, { force = true })
					local file = k:save_image(res.data, res.mime_type, timestamp .. "_" .. comm_id .. "_" .. iteration)
					if file then
						k:open_images(vim.fs.basename(file))
					end
					return true
				end
			)
		end
	end
end)

M.setup = function()
	vim.api.nvim_create_autocmd("WinResized", {
		group = vim.api.nvim_create_augroup("jet.ark.plot-resized", { clear = true }),
		callback = function()
			for _, win in ipairs(vim.v.event.windows or {}) do
				local buf = vim.api.nvim_win_get_buf(win)
				-- Snacks sets `vim.bo.filetype = image`
				if vim.b[buf].jet and (vim.bo[buf].filetype == "jetimg" or vim.bo[buf].filetype == "image") then
					local session = vim.b[buf].jet.session_id
					local k = session and require("jet.core.manager").kernels[session]
					if k then
						update_plot_size(k)
					end
				end
			end
		end,
	})
end

return M
