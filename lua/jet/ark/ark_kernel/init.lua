local help = require("jet.ark.ark_kernel.help")
local plot = require("jet.ark.ark_kernel.plot")
local ui = require("jet.ark.ark_kernel.ui")
local lsp = require("jet.ark.ark_kernel.lsp")

local Kernel = require("jet.core.kernel")

---@class ark.Kernel : jet.Kernel
---@field plot_sizes table<string, jet.ark.comm.plot_backend.plot_size>
---@field ark_lsp_name string?
---@field ark_lsp_starting boolean
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
	out.ark_lsp_starting = false
	-- known_comms = comms opened by the backend; we have to handle the open request
	out.known_comms["positron.plot"] = plot.handle_plot_comm_open
	out.hooks.on_kernel_close.stop_ark_lsp = function()
		out:stop_ark_lsp()
		-- For convenience, if we close Ark _and_ we're in an R file, start the
		-- LSP up again (this happens on BufEnter, but BufEnter isn't triggered
		-- if we're in an R file when the kernel is closed)
		if vim.bo.filetype == "r" then
			require("jet.ark.utils").get_ark_kernel(function(new_kernel) new_kernel:start_ark_lsp() end)
		end
	end
	out.hooks.on_lua_client_start.start_comms = function()
		help.start_comm(out)
		ui.start_comm(out)
		lsp.start_ark_lsp(out)
	end
	return out
end

function ArkKernel:start_ark_lsp() lsp.start_ark_lsp(self) end

function ArkKernel:stop_ark_lsp()
	if self.ark_lsp_name then
		vim.lsp.enable(self.ark_lsp_name, false)
		vim.lsp.config[self.ark_lsp_name] = {}
	end
end

function ArkKernel:resize_curr_plot() plot.resize_curr_plot_debounced(self) end

---@param topic string?
function ArkKernel:request_help(topic) help.request_help(self, topic) end

---@param width integer
function ArkKernel:set_console_width(width) ui.set_console_width(self, width) end

return ArkKernel
