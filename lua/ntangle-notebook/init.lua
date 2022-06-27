-- Generated using ntangle.nvim
local M = {}
local bit = require"bit"

local property_value

local bytestr2tbl

local create_frame
local num2bytes

local create_message

local read_frame

local bytes2num

function property_value(property, value)
  return string.char(property:len()) .. property .. num2bytes(value:len(), 4) .. value
end

function bytestr2tbl(bytes)
  local tab = {}
  for i=1,bytes:len() do
    table.insert(tab, ("0x%X"):format(bytes:sub(i,i):byte()))
  end
  return "{" .. table.concat(tab, ",") .. "}"
end

function create_frame(data, is_command, has_more)
  local flag = 0
  local len = data:len()
  if len >= 256 then
    flag = flag + 0x2
  end

  if is_command then
    flag = flag + 0x4
  end

  if has_more then
    flag = flag + 0x1
  end

  if len < 256 then
    size = string.char(len)
  else
    size = num2bytes(len, 8)
  end

  return string.char(flag) .. size .. data
end

function num2bytes(num, len)
  size  = ""
  for i=1,len do
    size = string.char(bit.band(num, 0xFF)) .. size
    num = bit.rshift(num, 8)
  end
  return size
end
function create_message(msg)
  return create_frame("", false, true) .. create_frame(msg, false, false)
end
function read_frame(getdata)
  local frame = {}
  frame.content = ""
  while true do
    local flag = getdata(1):byte()
    frame.is_command = bit.band(flag, 0x4) == 0x4

    local is_long = bit.band(flag, 0x2) == 0x2
    local has_more = bit.band(flag, 0x1) == 0x1

    local size = 0
    if not is_long then
      size = getdata(1):byte()
    else
      size = bytes2num(getdata(8))
    end

    frame.content = frame.content .. getdata(size)

    if not has_more then
      break
    end
  end

  return frame
end

function bytes2num(bytes)
  local num = 0
  for i=1,bytes:len() do
    num = bit.lshift(num, 8)
    num = num + bytes:sub(i,i):byte()
  end
end

local function create_client(port, co)
  local client = vim.loop.new_tcp()

  client:connect("127.0.0.1", port, vim.schedule_wrap(function(err)
    assert(not err, err)

    local chunk_buffer = ""

    local function getdata(amount)
      if amount then
        while string.len(chunk_buffer) < amount do
          coroutine.yield()
        end
      else
        while not chunk_buffer:find("\0") do
          coroutine.yield()
        end
        amount = chunk_buffer:find("\0")
      end

    	local retrieved = string.sub(chunk_buffer, 1, amount)
    	chunk_buffer = string.sub(chunk_buffer, amount+1)
    	return retrieved
    end

    local function senddata(bytes)
      client:write(bytes)
    end

    coroutine.resume(co, getdata, senddata)


    client:read_start(vim.schedule_wrap(function(err, chunk)
      assert(not err, err)

      if coroutine.status(co) == "dead" then
        client:close()
        return
      end


      if chunk then
        chunk_buffer = chunk_buffer .. chunk
        coroutine.resume(co)

      end
    end))
  end))

  return client
end

function M.connect(port_shell)
  local co = coroutine.create(function(getdata, senddata)
    local greeting = string.char(0xFF) .. ("\0"):rep(8) .. string.char(0x7F)
    senddata(greeting)

    getdata(11)

    local rest_greeting = string.char(0x03) .. string.char(0x01) .. "NULL" .. ("\0"):rep(16+1+31)
    senddata(rest_greeting)

    getdata(64-11)

    local data = string.char(0x5) .. "READY" 
    data = data .. property_value("Socket-Type", "REQ")
    data = data .. property_value("Identity", "")
    senddata(create_frame(data, true))

    local ready = read_frame(getdata)

    senddata(create_message("I'm sending a message from Neovim!!!!!!"))

    local response = read_frame(getdata)
    print("response")
    print(vim.inspect(response))
  end)

  create_client(port_shell, co)

end

function M.version()
  return "0.0.1"
end

return M
