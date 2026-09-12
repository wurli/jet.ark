local backend = require("jet.ark.comm.variables-backend")

---@class ark.var : jet.ark.comm.variables_backend.variable
---@field expanded boolean
---@field children? table<string, ark.var>
---@field indent integer

---@class ark.Kernel.Vars
---@field buf integer
---@field vars table<string, ark.var>
---@field vars_flat ark.var[]
---@field version integer
---@field length integer
---@field kernel ark.Kernel
---@field comm_id string
local Vars = {}
Vars.__index = Vars ---@private

---@param kernel ark.Kernel
Vars.new = function(kernel)
	local out = setmetatable({
		buf = vim.api.nvim_create_buf(false, true),
		kernel = kernel,
		vars = {},
		vars_flat = {},
		version = 0,
		length = 0,
		comm_id = nil,
	}, Vars)

	vim.keymap.set("n", "q", "<cmd>:q<cr>", { buffer = out.buf, silent = true })

	out.comm_id = out:start_comm()

	return out
end

---Take vars from the backend's array representation to jet.ark's nested dict
---structure
---@param vars jet.ark.comm.variables_backend.variable[]
---@return table<string, ark.var>
local process_vars = function(vars)
	local out = {}
	for _, var in ipairs(vars) do
		out[var.access_key] = var
		out[var.access_key].expanded = false
	end
	return out
end

function Vars:start_comm()
	return self.kernel:comm_open("positron.variables", {}, {
		listener = function(msg)
			local data = msg.content.data
			local method = data.method --[[@as "refresh" | "update"]]

			if method == "refresh" then
				local params = data.params --[[@as jet.ark.comm.variables_frontend.refresh.Params]]
				self.length = params.length
				self.version = params.version
				self.vars = process_vars(params.variables)
				self:render()
			elseif method == "update" then
				local params = data.params --[[@as jet.ark.comm.variables_frontend.update.Params]]
				-- vim.print({ update = params })
			end
		end,
	})
end

---@return integer?
function Vars:win()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == self.buf then
			return win
		end
	end
end

---@param cb? fun()
function Vars:list(cb)
	backend.list(self.kernel, self.comm_id, function(res)
		self.vars = process_vars(res.variables)
		self.length = res.length
		self.version = res.version
		if cb then
			cb()
		end
	end)
end

function Vars:inspect(path)
	backend.inspect(self.kernel, self.comm_id, { path = path }, function(res)
		-- res.length
		-- res.children
	end)
end

function Vars:open()
	self:list(function()
		vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, self:render())
		if not self:win() then
			local win = vim.api.nvim_open_win(self.buf, true, {
				split = "right",
				win = -1,
				style = "minimal",
			})
			vim.wo[win].wrap = false
		end
	end)
end

local icons = {
	caret_right = "",
	caret_down = "",
}

---@return string[]
function Vars:render()
	---@class ark.flat_var : ark.var

	---@param vars table<string, ark.var>
	---@param level integer
	local function unpack_vars(vars, level)
		for _, var in pairs(vars) do
			table.insert(self.vars_flat, {
				display_name = var.display_name,
				display_value = var.display_value,
				display_type = var.display_type,
				type_info = var.type_info,
				size = var.size,
				kind = var.kind,
				length = var.length,
				has_children = var.has_children,
				has_viewer = var.has_viewer,
				is_truncated = var.is_truncated,
				updated_time = var.updated_time,
				expanded = var.expanded,
				indent = level * 2,
			})

			if var.children then
				unpack_vars(var.children, level + 1)
			end
		end
	end

	self.vars_flat = {}
	unpack_vars(self.vars, 0)

	---@param f fun(v: ark.flat_var): integer
	local var_max = function(f) return math.max(0, unpack(vim.tbl_map(f, self.vars_flat))) end

	local name_max_width = var_max(function(v) return #v.display_name end)
	local value_max_width = var_max(function(v) return #v.display_value end)
	local type_max_width = var_max(function(v) return #v.display_type end)
	local indent_max_width = var_max(function(v) return v.indent end)

	local out = {} ---@type string[]

	for _, v in ipairs(self.vars_flat) do
		-- Indent
		local indent = string.rep(" ", v.indent)
		local indent_pad = string.rep(" ", indent_max_width - v.indent)

		-- Expanded icon
		local caret = (not v.has_children) and " " or v.expanded and icons.caret_down or icons.caret_right

		-- Display name
		local name = v.display_name
		local name_pad = string.rep(" ", name_max_width - #name)

		-- Display value
		local val = v.display_value
		local val_pad = string.rep(" ", value_max_width - #val)

		-- Display type
		local type = v.display_type
		local type_pad = string.rep(" ", type_max_width - #type)

		-- Combine all
		local name_col = indent .. caret .. " " .. name .. name_pad .. indent_pad
		local val_col = val .. val_pad
		local type_col = type_pad .. type

		table.insert(out, name_col .. " " .. val_col .. " " .. type_col)
	end

	return out
end

return Vars
