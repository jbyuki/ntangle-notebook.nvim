##ntangle-notebook
@wait_for_kernel_idle+=
while true do
  @send_status_request
  @receive_status_request
  @break_if_status_complete
  vim.api.nvim_echo({{"Kernel Busy.", "ErrorMsg"}}, false, {})
end

@send_status_request+=
local data = create_frame("<IDS|MSG>", false, true)

@serialize_header_status_request
@serialize_parent_header
@serialize_metadata
@serialize_content_without_code
@compute_hmac_key

@create_frames
senddata(data)

@serialize_header_status_request+=
@generate_uuid_for_message
local header = vim.json.encode({
  msg_id = msg_uuid,
  session = session_uuid,
  username = "username",
  date = os.date("!%Y-%m-%dT%TZ"), -- iso 8601
  msg_type = 'is_complete_request',
  version = '5.3'
})

@receive_status_request+=
local response = read_frame(getdata)
local decoded = vim.json.decode(response.content[6])

@break_if_status_complete+=
if decoded.status == "complete" then
  break
end

@serialize_content_without_code+=
content = vim.json.encode({
  code = "",
  silent = false,
  store_history = true,
  user_expressions = {},
  allow_stdin = false,
  stop_on_error = false
})

