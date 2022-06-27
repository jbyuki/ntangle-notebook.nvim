##ntangle-notebook
@declare+=
local create_frame
@local_defines+=
function create_frame(data, is_command, has_more)
  @create_flag_byte
  @create_size_bytes
  return string.char(flag) .. size .. data
end

@create_flag_byte+=
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

@requires+=
local bit = require"bit"

@create_size_bytes+=
if len < 256 then
  size = string.char(len)
else
  size = num2bytes(len, 8)
end

@declare+=
local num2bytes

@local_defines+=
function num2bytes(num, len)
  size  = ""
  for i=1,len do
    size = string.char(bit.band(num, 0xFF)) .. size
    num = bit.rshift(num, 8)
  end
  return size
end
