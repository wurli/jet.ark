local backend = require("jet.ark.comm.variables-backend")

---@class ark.var : jet.ark.comm.variables_backend.variable
---@field expanded boolean
---@field children? table<string, ark.var>

---@class ark.flat_var : ark.var
---@field path string[]
---@field indent integer
---@field display_name_w integer
---@field display_value_w integer
---@field display_type_w integer

---@class ark.Kernel.Vars
---@field ns integer
---@field buf integer
---@field vars table<string, ark.var>
---@field vars_flat ark.flat_var[]
---@field version integer
---@field length integer
---@field kernel ark.Kernel
---@field comm_id string
local Vars = {}
Vars.__index = Vars ---@private

---@param kernel ark.Kernel
Vars.new = function(kernel)
	assert(kernel.session_id)

	local out = setmetatable({
		buf = vim.api.nvim_create_buf(false, true),
		ns = vim.api.nvim_create_namespace("ark." .. kernel.session_id),
		kernel = kernel,
		vars = {},
		vars_flat = {},
		version = 0,
		length = 0,
		comm_id = nil,
	}, Vars)

	out.comm_id = out:start_comm()
	out:set_keymaps()

	vim.api.nvim_create_autocmd("WinResized", {
		group = vim.api.nvim_create_augroup("ark." .. kernel.session_id, { clear = true }),
		callback = function()
			local win = out:win()
			if win then
				local resized = vim.v.event.windows --[[@as integer[] ]]
				for _, resized_win in ipairs(resized) do
					if win == resized_win then
						out:redraw()
					end
				end
			end
		end,
	})

	return out
end

function Vars:set_keymaps()
	vim.keymap.set("n", "q", "<cmd>:q<cr>", { buffer = self.buf, silent = true })
	vim.keymap.set("n", "<enter>", function()
		local line = vim.fn.line(".")
		local var_flat = self.vars_flat[line]
		if not var_flat then
			return
		end
		local var = self:get_var(var_flat.path)

		if var.expanded then
			var.expanded = false
			self:redraw()
		elseif var.children then
			var.expanded = true
			self:redraw()
		elseif var.has_children then
			var.expanded = true
			self:inspect(var_flat.path)
		end
	end, { buffer = self.buf })
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

---@param path string[]
function Vars:get_var(path)
	local var ---@type ark.var
	local children = self.vars ---@type table<string, ark.var> | nil
	for _, key in ipairs(path) do
		assert(children, "Failed to expand variable")
		var = children[key]
		assert(var, "Failed to expand variable")
		children = var.children
	end
	return var
end

---@param path string[]
function Vars:inspect(path)
	assert(#path > 0)
	backend.inspect(self.kernel, self.comm_id, { path = path }, function(res)
		local var = self:get_var(path)
		var.children = process_vars(res.children)
		var.expanded = true
		self:redraw()
	end)
end

function Vars:open()
	self:list(function()
		if not self:win() then
			self:redraw()
			local win = vim.api.nvim_open_win(self.buf, true, {
				split = "right",
				win = -1,
				style = "minimal",
			})
			vim.wo[win].wrap = false
		end
	end)
end

function Vars:redraw()
	local lines, extmarks = self:render()
	vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
	vim.api.nvim_buf_clear_namespace(self.buf, self.ns, 0, -1)
	for line, marks in ipairs(extmarks) do
		for _, mark in ipairs(marks) do
			vim.api.nvim_buf_set_extmark(self.buf, self.ns, line - 1, mark[1], mark[2])
		end
	end
end

local icons = {
	caret_right = "",
	caret_down = "",
	ellipsis = "…",
}

---@alias ark.extmark_args [ integer, vim.api.keyset.set_extmark ]

---@return string[]
---@return ark.extmark_args[][]
function Vars:render()
	---@param vars table<string, ark.flat_var>
	---@param path string[]
	---@param level integer
	local function unpack_vars(vars, path, level)
		for _, var in pairs(vars) do
			local var_path = vim.list_extend(vim.deepcopy(path), { var.access_key })
			table.insert(self.vars_flat, {
				display_name = var.display_name,
				display_name_w = vim.fn.strwidth(var.display_name),
				display_value = var.display_value,
				display_value_w = vim.fn.strwidth(var.display_value),
				display_type = var.display_type,
				display_type_w = vim.fn.strwidth(var.display_type),
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
				path = var_path,
			})

			if var.expanded and var.children then
				unpack_vars(var.children, var_path, level + 1)
			end
		end
	end

	self.vars_flat = {}
	unpack_vars(self.vars, {}, 0)

	---@param f fun(v: ark.flat_var): integer
	local var_max = function(f) return math.max(0, unpack(vim.tbl_map(f, self.vars_flat))) end

	local name_max_width = var_max(function(v) return v.display_name_w + v.indent end)
	local type_max_width = var_max(function(v) return v.display_type_w end)

	local lines = {} ---@type string[]
	local marks = {} ---@type ark.extmark_args[][]

	local win = self:win()
	local win_width = win and vim.api.nvim_win_get_width(win) or math.floor(vim.o.columns / 2)

	for _, v in ipairs(self.vars_flat) do
		-- Indent
		local indent = string.rep(" ", v.indent)

		-- Expanded icon
		local caret = (not v.has_children) and " " or v.expanded and icons.caret_down or icons.caret_right

		-- Display name
		local name = v.display_name
		local name_pad = string.rep(" ", name_max_width - v.display_name_w)

		-- Display value
		local val = v.display_value

		-- Display type
		local type = v.display_type
		local type_pad = string.rep(" ", type_max_width - v.display_type_w)

		-- Final cols for name + type
		local name_col = indent .. caret .. " " .. name .. name_pad
		local type_col = type_pad .. type

		-- Value takes remaining space in the window
		local name_and_type_width = vim.fn.strwidth(name_col .. type_col) + 4
		local available_val_width = math.max(win_width - name_and_type_width, 10)

		local val_n_pad = available_val_width - v.display_value_w
		local val_pad = val_n_pad <= 0 and "" or string.rep(" ", val_n_pad)
		local val_trunc = val_n_pad >= 0 and val
			or vim.fn.strcharpart(val, 0, v.display_value_w + val_n_pad - 1) .. icons.ellipsis
		local val_col = val_trunc .. val_pad

		-- Combine all
		table.insert(lines, name_col .. "  " .. val_col .. "  " .. type_col)

		-- Indent highlight
		local caret_hl = { v.indent, { hl_group = "ArkVarsIndent", end_col = v.indent + 1 } } ---@type ark.extmark_args

		-- Var name highlight
		local name_start = v.indent + #caret + 1
		local name_end = name_start + #name
		local name_hl = { name_start, { hl_group = "ArkVarsName", end_col = name_end } }

		-- Var value highlight
		local val_start = #name_col + 2
		local val_end = val_start + #val_trunc
		local val_hl = { val_start, { hl_group = "ArkVarsValue", end_col = val_end } }

		-- Var type highlight
		local type_start = #(name_col .. "  " .. val_col .. "  " .. type_pad)
		local type_hl = { type_start, { hl_group = "ArkVarsType", end_col = type_start + #type } } ---@type ark.extmark_args

		table.insert(marks, { caret_hl, name_hl, val_hl, type_hl })
	end

	return lines, marks
end

return Vars
