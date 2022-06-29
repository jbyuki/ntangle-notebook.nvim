##ntangle-notebook
@defines+=
function M.send_ntangle()
  @get_code_content_at_current_section
  M.send_code(ntangle_code)
end

@get_code_content_at_current_section+=
local code = require"ntangle".get_code_at_cursor()
local ntangle_code = table.concat(code, "\n")

@defines+=
function M.send_ntangle_visual()
  @get_code_content_at_current_section_visual
  M.send_code(ntangle_code)
end

@get_code_content_at_current_section_visual+=
local code = require"ntangle".get_code_at_vrange()
local ntangle_code = table.concat(code, "\n")
