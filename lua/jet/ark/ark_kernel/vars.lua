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
---@field vars_flat (ark.flat_var | string)[]
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

	vim.bo[out.buf].filetype = "arkvariables"
	vim.bo[out.buf].modifiable = false
	vim.bo[out.buf].buftype = "nofile"
	vim.api.nvim_buf_set_name(out.buf, kernel:friendly_name() .. " - Variables")

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

---@param path string[]
function Vars:collapse(path)
	local var = self:get_var(path)
	if var.expanded then
		var.expanded = false
		self:redraw()
	end
end

---@param path string[]
function Vars:expand(path)
	local var = self:get_var(path)
	if var.expanded then
		return
	end
	var.expanded = true
	if var.children then
		self:redraw()
	elseif var.has_children then
		self:inspect(path)
	end
end

---@param a any[]
---@param b any[]
---@return boolean
local list_eq = function(a, b)
	if #a ~= #b then
		return false
	end
	for i = 1, #a do
		if a[i] ~= b[i] then
			return false
		end
	end
	return true
end

function Vars:set_keymaps()
	vim.keymap.set("n", "q", "<cmd>:q<cr>", { buffer = self.buf, silent = true })

	vim.keymap.set("n", "<enter>", function()
		local var = self.vars_flat[vim.fn.line(".")]
		if var and var.path then
			if var.expanded then
				self:collapse(var.path)
			else
				self:expand(var.path)
			end
		end
	end, { buffer = self.buf })

	vim.keymap.set("n", "<leader>y", function()
		local var_flat = self.vars_flat[vim.fn.line(".")]
		if var_flat and var_flat.path then
			self:clipboard_format(var_flat.path, "text/plain", function(text) vim.fn.setreg(vim.v.register, text) end)
		end
	end, { buffer = self.buf })

	vim.keymap.set({ "n", "x" }, "]]", function()
		for i = vim.fn.line(".") + 1, #self.vars_flat do
			local var = self.vars_flat[i]
			if type(var) == "table" and var.indent == 0 then
				vim.api.nvim_win_set_cursor(0, { i, 0 })
				return
			end
		end
	end, { buffer = self.buf })

	vim.keymap.set({ "n", "x" }, "[[", function()
		for i = vim.fn.line(".") - 1, 1, -1 do
			local var = self.vars_flat[i]
			if type(var) == "table" and var.indent == 0 then
				vim.api.nvim_win_set_cursor(0, { i, 0 })
				return
			end
		end
	end, { buffer = self.buf })

	vim.keymap.set("n", ">", function()
		local var = self.vars_flat[vim.fn.line(".")]
		if var and var.path then
			self:expand(var.path)
		end
	end, { buffer = self.buf, remap = true })

	vim.keymap.set("n", "<", function()
		local var = self.vars_flat[vim.fn.line(".")]
		if type(var) ~= "table" then
			return
		end
		if #var.path == 1 then
			self:collapse(var.path)
		elseif #var.path > 1 then
			local parent_path = {}
			for i = 1, #var.path - 1 do
				table.insert(parent_path, var.path[i])
			end

			self:collapse(parent_path)

			for line, line_var in ipairs(self.vars_flat) do
				if type(line_var) == "table" and list_eq(line_var.path, parent_path) then
					vim.api.nvim_win_set_cursor(0, { line, 0 })
					return
				end
			end
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
				self:redraw()
			elseif method == "update" then
				local params = data.params --[[@as jet.ark.comm.variables_frontend.update.Params]]
				self.version = params.version
				for _, key in ipairs(params.removed) do
					self.vars[key] = nil
				end
				for key, var in pairs(process_vars(params.assigned)) do
					self.vars[key] = var
				end
				self:redraw()
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

---@param path string[]
---@param format? "text/plain" | "text/html"
---@param cb fun(text: string)
function Vars:clipboard_format(path, format, cb)
	assert(#path > 0)
	format = format or "text/plain"

	backend.clipboard_format(self.kernel, self.comm_id, { path = path, format = format }, function(res)
		cb(res.content)
		return true
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
	vim.bo[self.buf].modifiable = true
	vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
	vim.bo[self.buf].modifiable = false
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
	---See https://github.com/posit-dev/positron/blob/main/src/vs/workbench/services/positronVariables/common/positronVariablesInstance.ts#L723
	---@param kind jet.ark.comm.variables_backend.variable["kind"]
	local category = function(kind)
		return kind == "table" and "DATA"
			or kind == "function" and "FUNCTIONS"
			or kind == "class" and "CLASSES"
			or "VALUES"
	end

	-- Bucket variables by category first to ensure proper sorting later on
	local categories = {
		DATA = {}, ---@type table<string, ark.var>
		FUNCTIONS = {}, ---@type table<string, ark.var>
		CLASSES = {}, ---@type table<string, ark.var>
		VALUES = {}, ---@type table<string, ark.var>
	}
	for key, var in pairs(self.vars) do
		categories[category(var.kind)][key] = var
	end

	---@param vars table<string, ark.flat_var>
	---@param path string[]
	---@param level integer
	local function unpack_vars(vars, path, level)
		local vars_sorted = {} ---@type ark.var[]
		for _, v in pairs(vars) do
			table.insert(vars_sorted, v)
		end
		table.sort(vars_sorted, function(a, b) return a.access_key < b.access_key end)

		for _, var in ipairs(vars_sorted) do
			local var_path = vim.list_extend(vim.deepcopy(path), { var.access_key })
			table.insert(self.vars_flat, {
				access_key = var.access_key,
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

	-- Unpacking each category in order ensures proper sorting
	self.vars_flat = {}
	for _, c in ipairs({ "DATA", "FUNCTIONS", "CLASSES", "VALUES" }) do
		if vim.tbl_count(categories[c]) > 0 then
			table.insert(self.vars_flat, c)
			unpack_vars(categories[c], {}, 0)
			table.insert(self.vars_flat, "")
		end
	end

	---@param f fun(v: ark.flat_var): integer
	local var_max = function(f)
		local widths = vim.tbl_map(function(var) return type(var) == "table" and f(var) or 0 end, self.vars_flat)
		return math.max(0, unpack(widths))
	end

	local name_max_width = var_max(function(v) return v.display_name_w + v.indent end)
	local type_max_width = var_max(function(v) return v.display_type_w end)

	local lines = {} ---@type string[]
	local marks = {} ---@type ark.extmark_args[][]

	local win = self:win()
	local win_width = win and vim.api.nvim_win_get_width(win) or math.floor(vim.o.columns / 2)

	for _, v in ipairs(self.vars_flat) do
		if type(v) == "string" then
			table.insert(lines, v)
			table.insert(marks, { { 0, { hl_group = "ArkVarsCategory", end_col = #v } } })
		else
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
			local name_hl = { name_start, { hl_group = "ArkVarsName", end_col = name_end } } ---@type ark.extmark_args

			-- Var value highlight
			local val_start = #name_col + 2
			local val_end = val_start + #val_trunc
			local val_hl = { val_start, { hl_group = "ArkVarsValue", end_col = val_end } } ---@type ark.extmark_args

			-- Var type highlight
			local type_start = #(name_col .. "  " .. val_col .. "  " .. type_pad)
			local type_hl = { type_start, { hl_group = "ArkVarsType", end_col = type_start + #type } } ---@type ark.extmark_args

			table.insert(marks, { caret_hl, name_hl, val_hl, type_hl })
		end
	end

	return lines, marks
end

return Vars
