-- Bootstrap for headless mini.test runs. Used both as `-u` for the test
-- runner itself and as `-u` for the child neovim each test spawns (see
-- MiniTest.new_child_neovim). The `cwd` is the repo root in both cases.

vim.cmd([[let &rtp.=','.getcwd()]])

vim.env.JUPYTER_PATH = vim.fn.getcwd() .. "/test-kernels"

-- mini.test setup runs only in the headless runner (no UIs attached).
-- Child instances get a UI and skip this block — they just need the
-- plugin on rtp.
if #vim.api.nvim_list_uis() == 0 then
	vim.opt.runtimepath:prepend("deps/mini.nvim")
	local local_jet_nvim = vim.fs.normalize("~/Repos/jet.nvim")
	local jet_install = vim.uv.fs_stat(local_jet_nvim) and local_jet_nvim or "deps/jet.nvim"
	vim.opt.runtimepath:prepend(jet_install)

	---------------------------------------------------------------------------
	--          Set up mini.test
	---------------------------------------------------------------------------
	require("mini.test").setup({
		collect = {
			find_files = function()
				return vim.fn.globpath("tests", "test_*.lua", true, true)
			end,
		},
		execute = {
			reporter = require("mini.test").gen_reporter.stdout({ quit_on_finish = true }),
		},
	})

	-- Look for jet bin and lib based on the jet binary in PATH - if found, use it.
	local lib_path, bin_path
	if vim.fn.exepath("jet") ~= "" then
		bin_path = vim.fn.exepath("jet")
	end
	if bin_path then
		local bin_dir = vim.fs.dirname(bin_path)
		for entry, type in vim.fs.dir(bin_dir) do
			if type == "file" and entry == "libjet_lua.dylib" then
				lib_path = bin_dir .. "/" .. entry
				break
			end
		end
	end

	---------------------------------------------------------------------------
	--          Set up jet.nvim
	---------------------------------------------------------------------------
	require("jet").setup({
		binary_path = lib_path and bin_path,
		library_path = bin_path and lib_path,
		ui = { stream_lines = 50 },
	})

	local dl = require("jet.core.utils.download")

	local has_jet = function()
		local paths = dl.get_jet_paths()
		return paths.bin and paths.lib
	end

	if not has_jet() then
		dl.download_jet("latest")
		assert(vim.wait(30000, has_jet), "Could not download Jet CLI/lib")
		vim.uv.sleep(500) -- Seems to avoid some flakes in CI?
	end

	local paths = dl.get_jet_paths()

	vim.print({
		jet_nvim_installation = jet_install,
		jet_paths = paths,
		jet_bin = dl.check_bin_version(),
		jet_lib = dl.check_lib_version(),
	})
	print("")

	_G.JET_LIB_PATH = paths.lib
	_G.JET_BIN_PATH = paths.bin

	---------------------------------------------------------------------------
	--          Set up jet.ark
	---------------------------------------------------------------------------
	require("jet.ark").setup({
		ark_binary_path = "test-kernels/ark/ark",
	})
end
