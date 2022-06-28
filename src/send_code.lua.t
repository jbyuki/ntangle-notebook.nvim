##ntangle-notebook
@send_code+=
local data = create_frame("<IDS|MSG>", false, true)
local key = "46706628-6bc05fa65b9866aa5392800b"

@serialize_header
@serialize_parent_header
@serialize_metadata
@serialize_content
@compute_hmac_key

@create_frames
senddata(data)

@serialize_header+=
@generate_uuid_for_message
local header = vim.json.encode({
  msg_id = msg_uuid,
  session = session_uuid,
  username = "username",
  date = os.date("!%Y-%m-%dT%TZ"), -- iso 8601
  msg_type = 'execute_request',
  version = '5.3'
})

@declare+=
local generate_uuid

@local_defines+=
function generate_uuid()
  -- Generate a UUID version 4 (all random)
  -- Taken straight from https://gist.github.com/jrus/3197011
  -- Thank you jrus
  local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return string.gsub(template, '[xy]', function (c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
end

@generate_random_seed+=
math.randomseed(os.time())

@generate_uuid_for_session+=
session_uuid = generate_uuid()

@variables+=
local msg_counter = 1

@generate_uuid_for_message+=
-- Looking at the existing front-end implementations
-- the msg id is just the session_uuid with a suffix
-- i'm just append a counter for simplicity
msg_uuid = session_uuid .. tostring(msg_counter)

@serialize_parent_header+=
parent_header = "{}"

@serialize_metadata+=
metadata = "{}"

@serialize_content+=
content = vim.json.encode({
  code = "a = 1234",
  silent = false,
  store_history = true,
  user_expressions = {},
  allow_stdin = false,
  stop_on_error = true
})

@compute_hmac_key+=
local hmac = hmac(key, header .. parent_header .. metadata .. content)

@create_frames+=
data = data .. create_frame(hmac, false, true)
data = data .. create_frame(header, false, true)
data = data .. create_frame(parent_header, false, true)
data = data .. create_frame(metadata, false, true)
data = data .. create_frame(content, false, false)
