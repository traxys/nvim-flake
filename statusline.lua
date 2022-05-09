local buffer_not_empty = function()
	if vim.fn.empty(vim.fn.expand("%:t")) ~= 1 then
		return true
	end
	return false
end

local mode_provider = function()
	local alias = { n = "NORMAL ", i = "INSERT ", c = "COMMAND ", V = "VISUAL ", ["^V"] = "VISUAL " }
	return alias[vim.fn.mode()]
end

local vcs = require("galaxyline.providers.vcs")

local is_file_diff = function()
	if vcs.diff_add() ~= nil or vcs.diff_modified() ~= nil or vcs.diff_remove() ~= nil then
		return ""
	end
end

local levels = {
	errors = vim.diagnostic.severity.ERROR,
  	warnings = vim.diagnostic.severity.WARN,
  	info = vim.diagnostic.severity.INFO,
 	hints = vim.diagnostic.severity.HINT,
}

local diagnostics = function()
	local result = {}
  	for k, level in pairs(levels) do
    	result[k] = #vim.diagnostic.get(vim.fn.bufnr(), { severity = level })
  	end

  	return result
end

-- LSP Helpers

local lsp_diag_error = function()
    local buf_diagnostics = diagnostics()

    if buf_diagnostics.errors and buf_diagnostics.errors > 0 then
        return buf_diagnostics.errors .. " "
    end
end
local lsp_diag_warn = function()
    local buf_diagnostics = diagnostics()

    if buf_diagnostics.warnings and buf_diagnostics.warnings > 0 then
        return buf_diagnostics.warnings .. " "
    end
end
local lsp_diag_info = function()
    local buf_diagnostics = diagnostics()

    if buf_diagnostics.info and buf_diagnostics.info > 0 then
        return buf_diagnostics.info .. " "
    end
end
local has_lsp = function()
    return #vim.lsp.buf_get_clients() > 0
end

local has_curent_func = function()
    if not has_lsp() then
        return false
    end
    local current_function = vim.b.lsp_current_function
    return current_function and current_function ~= ""
end
local lsp_current_func = function()
    local current_function = vim.b.lsp_current_function
    if current_function and current_function ~= "" then
        return "(" .. current_function .. ") "
    end
end
