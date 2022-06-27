##ntangle-notebook
@declare+=
local read_frame

@local_defines+=
function read_frame(getdata)
  local frame = {}
  frame.content = ""
  while true do
    local flag = getdata(1):byte()
    frame.is_command = bit.band(flag, 0x4) == 0x4

    local is_long = bit.band(flag, 0x2) == 0x2
    local has_more = bit.band(flag, 0x1) == 0x1

    @read_frame_size
    @read_frame_content

    if not has_more then
      break
    end
  end

  return frame
end

@read_frame_size+=
local size = 0
if not is_long then
  size = getdata(1):byte()
else
  size = bytes2num(getdata(8))
end

@declare+=
local bytes2num

@local_defines+=
function bytes2num(bytes)
  local num = 0
  for i=1,bytes:len() do
    num = bit.lshift(num, 8)
    num = num + bytes:sub(i,i):byte()
  end
end

@read_frame_content+=
frame.content = frame.content .. getdata(size)
