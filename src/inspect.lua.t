##ntangle-notebook
@defines+=
function M.inspect(python_code, pos)
  assert(client_co)
  code_content = python_code
  request = "inspect"
  cursor_pos = pos
  coroutine.resume(client_co)
end

@variables+=
local cursor_pos

@handle_other_requests+=
elseif request == "inspect" then
  @inspect_code
  @read_inspect_replay
  if found then
    @open_scratch_buffer_inspect
    @remove_ansi_escape_codes
    @enable_nabla_in_buffer
    @set_cursor_top
    @set_filetype_help
  else
    @print_not_found_message
  end

@inspect_code+=
local data = create_frame("<IDS|MSG>", false, true)

@serialize_header_inspect
@serialize_parent_header
@serialize_metadata
@serialize_content_inspect
@compute_hmac_key

@create_frames
senddata(data)

@serialize_header_inspect+=
@generate_uuid_for_message
local header = vim.json.encode({
  msg_id = msg_uuid,
  session = session_uuid,
  username = "username",
  date = os.date("!%Y-%m-%dT%TZ"), -- iso 8601
  msg_type = 'inspect_request',
  version = '5.3'
})

@serialize_content_inspect+=
content = vim.json.encode({
  code = code_content,
  cursor_pos = cursor_pos,
  detail_level = 0
})

@read_inspect_replay+=
local response = read_frame(getdata)
local content = response["content"]
local data = vim.json.decode(content[6])
local found = data["found"]

@open_scratch_buffer_inspect+=
local docstring = data["data"]["text/plain"]
local lines = vim.split(docstring, "\n")

vim.cmd [[to sp]]
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buf)

vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
vim.api.nvim_buf_set_option(buf, "ft", "terminal") -- requires nvim-terminal.lua
vim.api.nvim_set_option_value("concealcursor", "nc", { scope = "local"})

@print_not_found_message+=
vim.api.nvim_echo({{"Not found.", "ErrorMsg"}}, false, {})


@remove_ansi_escape_codes+=
vim.cmd [[%s/\e\[[0-9;]*m//g]]

@enable_nabla_in_buffer+=
require"nabla".enable_virt({
  start_delim="\\f",
  end_delim="\\f"
})

@set_cursor_top+=
vim.api.nvim_win_set_cursor(0, {1, 0})

@set_filetype_help+=
vim.cmd [[set ft=help]]
