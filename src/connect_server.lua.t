##ntangle-notebook
@defines+=
function M.connect(port_shell, key)
  @if_no_info_provided_find_existing_kernel
  @send_code_coroutine_test
  @connect_to_shell
end

@send_code_coroutine_test+=
client_co = coroutine.create(function(getdata, senddata)
  @send_greeting
  @receive_greeting
  @send_remaining_greeting
  @receive_remaining_greeting
  @send_ready
  @receive_ready
  @generate_uuid_for_session
  while true do
    coroutine.yield()
    @wait_for_kernel_idle
    if request == "send_code" then
      @send_code
      @read_code_execute_replay
    @handle_other_requests
    end
  end
end)

@declare+=
local client_co

@receive_greeting+=
getdata(11)

@connect_to_shell+=
create_client(port_shell, client_co)

@send_greeting+=
local greeting = string.char(0xFF) .. ("\0"):rep(8) .. string.char(0x7F)
senddata(greeting)

@send_remaining_greeting+=
local rest_greeting = string.char(0x03) .. string.char(0x01) .. "NULL" .. ("\0"):rep(16+1+31)
senddata(rest_greeting)

@receive_remaining_greeting+=
getdata(64-11)

@send_ready+=
local data = string.char(0x5) .. "READY" 
data = data .. property_value("Socket-Type", "DEALER")
data = data .. property_value("Identity", "")
senddata(create_frame(data, true))

@declare+=
local property_value

@local_defines+=
function property_value(property, value)
  return string.char(property:len()) .. property .. num2bytes(value:len(), 4) .. value
end

@declare+=
local bytestr2tbl

@local_defines+=
function bytestr2tbl(bytes)
  local tab = {}
  for i=1,bytes:len() do
    table.insert(tab, ("0x%X"):format(bytes:sub(i,i):byte()))
  end
  return "{" .. table.concat(tab, ",") .. "}"
end

@receive_ready+=
local ready = read_frame(getdata)
vim.api.nvim_echo({{"Ready.", "Normal"}}, false, {})

@read_code_execute_replay+=
local response = read_frame(getdata)
vim.api.nvim_echo({{"Done.", "Normal"}}, false, {})
