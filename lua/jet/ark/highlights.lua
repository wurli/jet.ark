local M = {}

---@type table<string, vim.api.keyset.highlight>
M.colours = {
	ArkVarsIndent = { link = "ComplHint" },
	ArkVarsName = { link = "Special" },
	ArkVarsValue = { link = "Normal" },
	ArkVarsType = { link = "ComplHint" },
}

M.set_highlights = function()
	for group, hl in pairs(M.colours) do
		hl.default = true
		vim.api.nvim_set_hl(0, group, hl)
	end
end

M.did_setup = false

M.setup = function()
	---@diagnostic disable-next-line: unnecessary-if
	if M.did_setup then
		return
	end

	M.did_setup = true

	M.set_highlights()

	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = M.set_highlights,
	})
end

return M
