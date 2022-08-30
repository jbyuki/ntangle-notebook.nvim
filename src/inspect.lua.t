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
print(vim.inspect(response))

