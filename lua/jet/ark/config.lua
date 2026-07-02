local M = {}

---@class jet.ark.config
M.defaults = {
	ark_binary_path = "ark",
	---Args passed to ark on startup - see `ark` help output for more info.
	ark_argv = {
		r_args = {}, ---@type string[]
		startup_file = nil, ---@type string?
		no_capture_streams = nil, ---@type boolean?
		default_repos = nil, ---@type "rstudio" | "posit-ppm" | "none"
		repos_conf = nil, ---@type string?
		default_ppm_repo = nil, ---@type string?
		default_cran_repo = nil, ---@type string?
		log = nil, ---@type string Defaults to `vim.fn.stdpath("cache") .. "/jet.ark/ark.log"`
	},
}

---@type jet.ark.config
M.options = {}

---@class jet.ark.data
M.data = {
	kernelspec_path = nil, ---@type string
}

M.load_data = function()
	M.data.kernelspec_path = require("jet.core.kernelspec").make_path("ark")
end

--TODO: default startup file makes some assumptions about the capabilities of
--the current terminal. We might be able to determine this dynamically and
--generate the file accordingly.
---@return string
local default_startup_file_path = function()
	local path = vim.fn.simplify(debug.getinfo(1).source:match("@?(.*/)") .. "../../../scripts/startup.R")
	assert(vim.uv.fs_stat(path), "Ark startup file not found at: " .. path)
	return path
end

local is_executable = function(path)
	return vim.fn.executable(vim.fn.expand(path)) == 1
end

---@param opts jet.ark.config
---@return jet.ark.config
local validate = function(opts)
	--- Validate ark binary exists
	opts.ark_binary_path = vim.fn.expand(opts.ark_binary_path)
	assert(is_executable(opts.ark_binary_path), "Ark binary not found at: " .. opts.ark_binary_path)

	--- Default startup file
	opts.ark_argv.startup_file = opts.ark_argv.startup_file or default_startup_file_path()

	--- Default log file (ark stderr goes here instead of leaking into repl)
	opts.ark_argv.log = opts.ark_argv.log or vim.fn.stdpath("cache") .. "/jet.ark/ark.log"

	return opts
end

---@param options? jet.ark.config
function M.set(options)
	local opts = vim.tbl_deep_extend("force", M.defaults, options or {})
	opts = validate(opts)
	M.options = opts
	M.load_data()
end

return M
