local Kernel = require("jet.core.kernel")

---@class ark.Kernel : jet.Kernel
local ArkKernel = setmetatable({}, { __index = Kernel })
ArkKernel.__index = ArkKernel ---@private

---Modifies `kernel` in place
---@param kernel jet.Kernel
ArkKernel.from_kernel = function(kernel)
	setmetatable(kernel, ArkKernel)

	kernel.metadata = {}
	kernel.filetype = "r"
	kernel.priority = 200
	kernel.known_comms["positron.plot"] = require("jet.ark.plot").comm_open_handler

	return kernel
end

return ArkKernel
