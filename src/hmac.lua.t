##ntangle-notebook
@declare+=
-- local hmac

@local_defines+=
  function M.hmac(key, msg)
  -- https://datatracker.ietf.org/doc/html/rfc2104
  -- https://en.wikipedia.org/wiki/HMAC
  local B = 64 -- Block size for SHA-256

  @convert_key_to_byte_array

  @compute_padded_key
  @computer_inner_padded
  @computer_outer_padded
  @compute_result

end

@compute_padded_key+=
if #key > B then
  key_padded = sha256(key)
else
  key_padded = vim.deepcopy(key)

  for i=1,B-#key do
    table.insert(key_padded, 0)
  end
end

@computer_inner_padded+=
local ipad = {}
for i=1,B do
  table.insert(ipad, 0x36)
end

@computer_outer_padded+=
local opad = {}
for i=1,B do
  table.insert(opad, 0x5c)
end

@declare+=
local xor_all

@local_defines+=
function xor_all(a, b)
  assert(#a == #b)

  local result = {}
  for i=1,#a do
    table.insert(result, bit.bxor(a[i],b[i]))
  end
  return result
end

@compute_result+=
local xored = xor_all(key_padded, ipad)
vim.list_extend(xored, msg)
local rhs = sha256(xored)
local lhs = xor_all(key_padded, opad)
vim.list_extend(lhs, rhs)
return sha256(lhs)

@declare+=
local str2tbl

@local_defines+=
function str2tbl(str)
  local tbl = {}
  for i=1,#str do
    table.insert(tbl, str:sub(i,i):byte())
  end
  return tbl
end

@convert_key_to_byte_array+=
key = str2tbl(key)
msg = str2tbl(msg)
