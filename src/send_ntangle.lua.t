##ntangle-notebook
@defines+=
function M.send_ntangle()
  @get_code_content_at_current_section
  M.send_code(ntangle_code)
end

@get_code_content_at_current_section+=
local code = require"ntangle".get_code_at_cursor()
local ntangle_code = table.concat(code, "\n")
