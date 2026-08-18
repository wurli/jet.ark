local M = {}

---@param callback fun(k: jet.Kernel)
M.get_ark_kernel = function(callback)
	---@param status jet.kernel.status | jet.kernel.status[]
	local get_ark_kernels = function(status, cb)
		local spec_path = require("jet.ark.config").data.kernelspec_path
		require("jet.core.api").list_kernels({ spec_path = spec_path, status = status }, {}, cb)
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

return M
