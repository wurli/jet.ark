local M = {}

---@param callback fun(k: jet.Kernel)
M.get_ark_kernel = function(callback)
	---@param status jet.kernel.status | jet.kernel.status[]
	local get_ark_kernels = function(status, cb)
		local spec_path = require("jet.ark.config").data.kernelspec_path
		require("jet.core.manager").list({ spec_path = spec_path, status = status }, cb)
	end

	get_ark_kernels({ "connected", "connecting" }, function(connected)
		if connected[1] then
			return connected[1]:start_lua_client(callback)
		end
		get_ark_kernels("inactive", function(inactive)
			if inactive[1] then
				return inactive[1]:start_lua_client(callback)
			end
			error("No Ark kernel found. Please start an Ark kernel first")
		end)
	end)
end

M.project_file = function(path)
	local debug = assert(debug.getinfo(1), "Failed to get debug info")
	local out = vim.fn.simplify(debug.source:match("@?(.*/)") .. "../../../" .. path)
	assert(vim.uv.fs_stat(out), "Project file not found at: " .. out)
	return out
end

return M
