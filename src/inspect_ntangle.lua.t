##ntangle-notebook
@defines+=
function M.inspect_ntangle()
  @compute_cursor_offset
  @get_current_line
  M.inspect(line, pos)
end

@get_current_line+=

@compute_cursor_offset+=
local row, col = unpack(vim.api.nvim_win_get_cursor(0))
pos = col+1

@get_current_line+=
local line = vim.api.nvim_buf_get_lines(0, row-1, row, true)[1]

