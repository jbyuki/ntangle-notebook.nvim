-- Generated using ntangle.nvim
local M = {}
local bit = require("bit")

math.randomseed(os.time())

local msg_counter = 1

local code_content
local client_co

local property_value

local bytestr2tbl

local create_frame
local num2bytes

local create_message

-- local hmac

local xor_all

local str2tbl

local read_frame

local bytes2num

local generate_uuid

-- local sha256


local SSIG1, SSIG0

local K = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
}

local BSIG0, BSIG1
local CH, MAJ

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
function M.hmac(key, msg)
  -- https://datatracker.ietf.org/doc/html/rfc2104
  -- https://en.wikipedia.org/wiki/HMAC
  local B = 64 -- Block size for SHA-256

  key = str2tbl(key)
  msg = str2tbl(msg)


  if #key > B then
    key_padded = M.sha256(key)
  else
    key_padded = vim.deepcopy(key)

    for i=1,B-#key do
      table.insert(key_padded, 0)
    end
  end

  local ipad = {}
  for i=1,B do
    table.insert(ipad, 0x36)
  end

  local opad = {}
  for i=1,B do
    table.insert(opad, 0x5c)
  end

  local xored = xor_all(key_padded, ipad)
  vim.list_extend(xored, msg)
  local rhs = M.sha256(xored)
  local lhs = xor_all(key_padded, opad)
  vim.list_extend(lhs, rhs)
  local result = M.sha256(lhs)

  local hexstr = ""
  for i=1,#result do
    hexstr = hexstr .. string.format("%02x", result[i])
  end
  return hexstr

end

function xor_all(a, b)
  assert(#a == #b)

  local result = {}
  for i=1,#a do
    table.insert(result, bit.bxor(a[i],b[i]))
  end
  return result
end

function str2tbl(str)
  local tbl = {}
  for i=1,#str do
    table.insert(tbl, str:sub(i,i):byte())
  end
  return tbl
end

function read_frame(getdata)
  local frame = {}
  frame.content = {}
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

    table.insert(frame.content, getdata(size))

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

function M.sha256(bytes)
  local bytes = vim.deepcopy(bytes)
	local len = {}
	local bytes_len = #bytes*8

	for i=1,8 do
		table.insert(len, bit.band(bytes_len, 0xFF))
		bytes_len = bit.rshift(bytes_len, 8)
	end

  table.insert(bytes, 0x80)

	local remain = (64 - ((#bytes+8) % 64)) % 64
	for i=64-remain+1,64 do
	  table.insert(bytes, 0)
	end

	for i=1,8 do
	  table.insert(bytes, len[8-i+1])
	end


	local H = {
	  0x6A09E667,
	  0xBB67AE85,
	  0x3C6EF372,
	  0xA54FF53A,
	  0x510E527F,
	  0x9B05688C,
	  0x1F83D9AB,
	  0x5BE0CD19
	}

	local W = {}
	for i = 1,#bytes,64 do
		for j=0,15 do
		  W[j] = from8to32(
		    bytes[i+4*j+0], bytes[i+4*j+1], 
		    bytes[i+4*j+2], bytes[i+4*j+3])
		end

		for t=16,63 do
		  W[t] = SSIG1(W[t-2]) + W[t-7] + SSIG0(W[t-15]) + W[t-16]
		end

		local a, b, c, d, e, f, g, h = unpack(H)

		for t=0,63 do
		  local T1 = bit.band(h + BSIG1(e) + CH(e,f,g) + K[t+1] + W[t], 0xFFFFFFFF)

		  local T2 = bit.band(BSIG0(a) + MAJ(a,b,c), 0xFFFFFFFF)
		  h = g   g = f  f = e   e = bit.band(d + T1, 0xFFFFFFFF)
		  d = c   c = b  b = a   a = bit.band(T1 + T2, 0xFFFFFFFF)
		end

		H[1] = H[1]+a
		H[2] = H[2]+b
		H[3] = H[3]+c
		H[4] = H[4]+d
		H[5] = H[5]+e
		H[6] = H[6]+f
		H[7] = H[7]+g
		H[8] = H[8]+h

	end

	local digest = {}
	for i=1,8 do
		table.insert(digest, bit.band(bit.rshift(H[i], 24), 0xFF))
		table.insert(digest, bit.band(bit.rshift(H[i], 16), 0xFF))
		table.insert(digest, bit.band(bit.rshift(H[i],  8), 0xFF))
		table.insert(digest, bit.band(bit.rshift(H[i],  0), 0xFF))
	end
	return digest
end

function from8to32(b1, b2, b3, b4)
	return bit.lshift(b1, 24) + bit.lshift(b2, 16)
		+ bit.lshift(b3, 8) + bit.lshift(b4, 0)
end

function SSIG1(x)
  return bit.bxor(bit.bxor(bit.ror(x, 17), bit.ror(x, 19)), bit.rshift(x, 10))
end

function SSIG0(x)
  return bit.bxor(bit.bxor(bit.ror(x, 7), bit.ror(x, 18)), bit.rshift(x, 3))
end

function BSIG0(x)
  return bit.bxor(bit.bxor(bit.ror(x, 2), bit.ror(x, 13)), bit.ror(x, 22))
end

function BSIG1(x)
  return bit.bxor(bit.bxor(bit.ror(x, 6), bit.ror(x, 11)), bit.ror(x, 25))
end

function CH(x, y, z)
  return bit.bxor(bit.band(x, y), bit.band(bit.bnot(x), z))
end

function MAJ(x, y, z)
  return bit.bxor(bit.bxor(bit.band(x, y), bit.band(x, z)), bit.band(y, z))
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

function M.connect(port_shell, key)
  client_co = coroutine.create(function(getdata, senddata)
    local greeting = string.char(0xFF) .. ("\0"):rep(8) .. string.char(0x7F)
    senddata(greeting)

    getdata(11)

    local rest_greeting = string.char(0x03) .. string.char(0x01) .. "NULL" .. ("\0"):rep(16+1+31)
    senddata(rest_greeting)

    getdata(64-11)

    local data = string.char(0x5) .. "READY" 
    data = data .. property_value("Socket-Type", "DEALER")
    data = data .. property_value("Identity", "")
    senddata(create_frame(data, true))

    local ready = read_frame(getdata)
    print("Ready.")

    session_uuid = generate_uuid()

    while true do
      coroutine.yield()
      while true do
        local data = create_frame("<IDS|MSG>", false, true)

        -- Looking at the existing front-end implementations
        -- the msg id is just the session_uuid with a suffix
        -- i'm just append a counter for simplicity
        msg_uuid = session_uuid .. tostring(msg_counter)

        local header = vim.json.encode({
          msg_id = msg_uuid,
          session = session_uuid,
          username = "username",
          date = os.date("!%Y-%m-%dT%TZ"), -- iso 8601
          msg_type = 'is_complete_request',
          version = '5.3'
        })

        parent_header = "{}"

        metadata = "{}"

        content = vim.json.encode({
          code = code_content,
          silent = false,
          store_history = true,
          user_expressions = {},
          allow_stdin = false,
          stop_on_error = false
        })

        local hmac_code = M.hmac(key, header .. parent_header .. metadata .. content)


        data = data .. create_frame(hmac_code, false, true)
        data = data .. create_frame(header, false, true)
        data = data .. create_frame(parent_header, false, true)
        data = data .. create_frame(metadata, false, true)
        data = data .. create_frame(content, false, false)

        senddata(data)

        local response = read_frame(getdata)
        local decoded = vim.json.decode(response.content[6])

        if decoded.status == "complete" then
          break
        end
        print("Kernel busy.")
      end

      local data = create_frame("<IDS|MSG>", false, true)

      -- Looking at the existing front-end implementations
      -- the msg id is just the session_uuid with a suffix
      -- i'm just append a counter for simplicity
      msg_uuid = session_uuid .. tostring(msg_counter)

      local header = vim.json.encode({
        msg_id = msg_uuid,
        session = session_uuid,
        username = "username",
        date = os.date("!%Y-%m-%dT%TZ"), -- iso 8601
        msg_type = 'execute_request',
        version = '5.3'
      })

      parent_header = "{}"

      metadata = "{}"

      content = vim.json.encode({
        code = code_content,
        silent = false,
        store_history = true,
        user_expressions = {},
        allow_stdin = false,
        stop_on_error = false
      })

      local hmac_code = M.hmac(key, header .. parent_header .. metadata .. content)


      data = data .. create_frame(hmac_code, false, true)
      data = data .. create_frame(header, false, true)
      data = data .. create_frame(parent_header, false, true)
      data = data .. create_frame(metadata, false, true)
      data = data .. create_frame(content, false, false)

      senddata(data)

      local response = read_frame(getdata)
      print("Done.")
    end
  end)

  create_client(port_shell, client_co)

end

function M.send_code(python_code)
  assert(client_co)
  code_content = python_code
  coroutine.resume(client_co)
end

function M.send_ntangle()
  local code = require"ntangle".get_code_at_cursor()
  local ntangle_code = table.concat(code, "\n")
  M.send_code(ntangle_code)
end

function M.version()
  return "0.0.1"
end

return M
