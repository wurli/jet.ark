local help = require("jet.ark.ark_kernel.help")
local plot = require("jet.ark.ark_kernel.plot")

local Kernel = require("jet.core.kernel")

---@class ark.Kernel : jet.Kernel
---@field plot_sizes table<string, jet.ark.comm.plot_backend.plot_size>
---@field ark_lsp_name string?
local ArkKernel = setmetatable({}, { __index = Kernel })
ArkKernel.__index = ArkKernel ---@private

---Modifies `kernel` in place
---@param kernel jet.Kernel
ArkKernel.from_kernel = function(kernel)
	local out = setmetatable(kernel, ArkKernel)
	out.subclass = "ark"
	out.metadata = {}
	out.filetype = "r"
	out.priority = 200
	out.plot_sizes = {}
	-- known_comms = comms opened by the backend; we have to handle the open request
	out.known_comms["positron.plot"] = plot.handle_plot_comm_open
	out.hooks.on_kernel_close.stop_ark_lsp = function()
		out:stop_ark_lsp()
	end
	out.hooks.on_lua_client_start.start_comms = function()
		help.start_help_comm(out)
	end
	return out
end

function ArkKernel:stop_ark_lsp()
	if self.ark_lsp_name then
		vim.lsp.enable(self.ark_lsp_name, false)
		vim.lsp.config[self.ark_lsp_name] = {}
	end
end

function ArkKernel:resize_curr_plot()
	plot.resize_curr_plot_debounced(self)
end

---@param topic string?
function ArkKernel:request_help(topic)
	help.request_help(self, topic)
end

return ArkKernel
