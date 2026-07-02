local config = require("jet.ark.config")

local M = {}

---@return jet.kernel.spec
M.generate = function()
	local argv = { config.options.ark_binary_path }

	local argv_config = config.options.ark_argv

	table.insert(argv, "--connection_file")
	table.insert(argv, "{connection_file}")

	if argv_config.default_cran_repo then
		table.insert(argv, "--default-cran-repo")
		table.insert(argv, argv_config.default_cran_repo)
	end

	if argv_config.default_ppm_repo then
		table.insert(argv, "--default-ppm-repo")
		table.insert(argv, argv_config.default_ppm_repo)
	end

	if argv_config.default_repos then
		table.insert(argv, "--default-repos")
		table.insert(argv, argv_config.default_repos)
	end

	if argv_config.log then
		table.insert(argv, "--log")
		table.insert(argv, vim.fn.expand(argv_config.log))
	end

	if argv_config.no_capture_streams then
		table.insert(argv, "--no-capture-streams")
	end

	if argv_config.startup_file then
		table.insert(argv, "--startup-file")
		table.insert(argv, vim.fn.expand(argv_config.startup_file))
	end

	-- See https://github.com/posit-dev/ark/issues/1311 for why this is needed
	-- and not configurable.
	table.insert(argv, "--session-mode")
	table.insert(argv, "notebook")

	if argv_config.r_args and #argv_config.r_args > 0 then
		table.insert(argv, "--")
		for _, arg in ipairs(argv_config.r_args) do
			table.insert(argv, arg)
		end
	end

	return {
		argv = argv,
		display_name = "Ark R Kernel",
		language = "R",
		interrupt_mode = "message",
		env = {
			RUST_LOG = "error",
		},
	}
end

M.install = function()
	require("jet.core.kernelspec").install(M.generate(), config.data.kernelspec_path)
end

return M
