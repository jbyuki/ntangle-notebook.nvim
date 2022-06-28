##ntangle-notebook
@declare+=
local sha256

@local_defines+=
function sha256(bytes)
  bytes = vim.deepcopy(bytes)
	@compute_2_word_length_of_bytes
  @shift_all_bytes_and_prepend_one
	@add_padding_for_multiple_of_64_bytes
	@init_initial_states_for_H
	@compute_message_digest
	@transform_digest_into_bytes
	return digest
end

@requires+=
local bit = require("bit")

@compute_2_word_length_of_bytes+=
local len = {}
local bytes_len = #bytes*8

for i=1,8 do
	table.insert(len, bit.band(bytes_len, 0xFF))
	bytes_len = bit.rshift(bytes_len, 8)
end

@shift_all_bytes_and_prepend_one+=
table.insert(bytes, 0x80)

@add_padding_for_multiple_of_64_bytes+=
local remain = (64 - (#bytes % 64)) % 64
for i=64-remain+1,64 do
  local byte = 0
  if 64-i < 8 then
    byte = bit.bor(byte, len[64-i+1])
  end
  table.insert(bytes, byte)
end


@init_initial_states_for_H+=
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

@compute_message_digest+=
local W = {}
for i = 1,#bytes,64 do
	@split_M_into_W
	@fill_remaing_W
	@init_ABCDE_with_H
	@compute_new_ABCDE
	@compute_new_H
end

@declare+=

@local_defines+=
function from8to32(b1, b2, b3, b4)
	return bit.lshift(b1, 24) + bit.lshift(b2, 16)
		+ bit.lshift(b3, 8) + bit.lshift(b4, 0)
end

@split_M_into_W+=
for j=0,15 do
  W[j] = from8to32(
    bytes[i+4*j+0], bytes[i+4*j+1], 
    bytes[i+4*j+2], bytes[i+4*j+3])
end

@fill_remaing_W+=
for t=16,63 do
  W[t] = SSIG1(W[t-2]) + W[t-7] + SSIG0(W[t-15]) + W[t-16]
end

@declare+=
local SSIG1, SSIG0

@local_defines+=
function SSIG1(x)
  return bit.bxor(bit.bxor(bit.ror(x, 17), bit.ror(x, 19)), bit.rshift(x, 10))
end

function SSIG0(x)
  return bit.bxor(bit.bxor(bit.ror(x, 7), bit.ror(x, 18)), bit.rshift(x, 3))
end

@init_ABCDE_with_H+=
local a, b, c, d, e, f, g, h = unpack(H)

@declare+=
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

@compute_new_ABCDE+=
for t=0,63 do
  local T1 = bit.band(h + BSIG1(e) + CH(e,f,g) + K[t+1] + W[t], 0xFFFFFFFF)

  local T2 = bit.band(BSIG0(a) + MAJ(a,b,c), 0xFFFFFFFF)
  h = g   g = f  f = e   e = bit.band(d + T1, 0xFFFFFFFF)
  d = c   c = b  b = a   a = bit.band(T1 + T2, 0xFFFFFFFF)
end

@declare+=
local BSIG0, BSIG1
local CH, MAJ

@local_defines+=
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

@compute_new_H+=
H[1] = H[1]+a
H[2] = H[2]+b
H[3] = H[3]+c
H[4] = H[4]+d
H[5] = H[5]+e
H[6] = H[6]+f
H[7] = H[7]+g
H[8] = H[8]+h

@transform_digest_into_bytes+=
local digest = {}
for i=1,8 do
	table.insert(digest, bit.band(bit.rshift(H[i], 24), 0xFF))
	table.insert(digest, bit.band(bit.rshift(H[i], 16), 0xFF))
	table.insert(digest, bit.band(bit.rshift(H[i],  8), 0xFF))
	table.insert(digest, bit.band(bit.rshift(H[i],  0), 0xFF))
end
