##ntangle-notebook
@declare+=
local hmac

@local_defines+=
  function hmac(key, msg)
  -- https://datatracker.ietf.org/doc/html/rfc2104
  -- https://en.wikipedia.org/wiki/HMAC
  local B = 64 -- Block size for SHA-256

  @convert_key_to_byte_string

  @compute_padded_key
  @computer_inner_padded
  @computer_outer_padded
  @compute_result

end

@compute_padded_key+=
if key:len() > B then
  key_padded = vim.fn.sha256(key)
else
  key_padded = key

  for i=1,B-key:len() do
    key_padded = key_padded .. "0"
  end
end

@computer_inner_padded+=
local ipad = ("36"):rep(B)

@computer_outer_padded+=
local opad = ("5c"):rep(B)

@declare+=
local xor_str

@local_defines+=
function xor_str(a, b)
  assert(a:len() == b:len())

  local result = ""
  for i=1,a:len() do
    local ai = tonumber(a:sub(i,i), 16)
    local bi = tonumber(b:sub(i,i), 16)

    local ri = bit.bxor(ai,bi)
    result = string.format("%x", ri) .. result 
  end
  return result
end

@compute_result+=
local rhs = vim.fn.sha256(xor_str(key_padded, ipad) .. msg)
local lhs = xor_str(key_padded, opad)
return vim.fn.sha256(lhs .. rhs)
