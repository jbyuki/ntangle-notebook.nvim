##ntangle-notebook
@defines+=
function M.send_ntangle_v2()
	@get_code_content_at_current_section_v2
  M.send_code(ntangle_code)
end

@get_code_content_at_current_section_v2+=
local found, ntangle_inc = pcall(require, "ntangle-inc")
assert(found)

local buf = vim.api.nvim_get_current_buf()
local row, col = unpack(vim.api.nvim_win_get_cursor(0))

local lnum = row-1
@get_hl_elem_at_lnum
if hl_elem and hl_elem.part then
	hl_elem = hl_elem.part
end
@get_lines_at_hl_elem

local ntangle_code = table.concat(lines, "\n")

@get_hl_elem_at_lnum+=
local hl_elem = ntangle_inc.Tto_hl_elem(buf, lnum)

@get_lines_at_hl_elem+=
local lines = {}
if hl_elem then
	local Tangle = require"vim.tangle"
	local ll = Tangle.get_ll_from_buf(buf)
	assert(ll)
	local hl = Tangle.get_hl_from_ll(ll)
	assert(hl)

	lines = hl:getlines_all(hl_elem, lines)
end

@defines+=
function M.send_ntangle_visual_v2()
	vim.api.nvim_echo({{"Sending.", "Normal"}}, false, {})
  @get_code_content_at_current_section_visual_v2
  M.send_code(ntangle_code)
end

@get_code_content_at_current_section_visual_v2+=
local _,slnum,_,_ = unpack(vim.fn.getpos("'<"))
local _,elnum,_,_ = unpack(vim.fn.getpos("'>"))
local buf = vim.api.nvim_get_current_buf()

local found, ntangle_inc = pcall(require, "ntangle-inc")
assert(found)

local all_lines = {}
for lnum=slnum-1,elnum-1 do
	@get_hl_elem_at_lnum
	@get_lines_at_hl_elem
	@append_lines_to_all_lines
end

local ntangle_code = table.concat(all_lines, "\n")

@append_lines_to_all_lines+=
for _, line in ipairs(lines) do
	table.insert(all_lines, line)
end

