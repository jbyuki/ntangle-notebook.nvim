##ntangle-notebook
@local_defines+=
local function create_client(port, co)
  @create_tcp_connection
  @connect_client
  return client
end

@create_tcp_connection+=
local client = vim.loop.new_tcp()

@connect_client+=
client:connect("127.0.0.1", port, vim.schedule_wrap(function(err)
  @check_for_errors
  @reader_variables
  @create_read_function
  @create_write_function
  @start_coroutine_reader

  client:read_start(vim.schedule_wrap(function(err, chunk)
    @check_for_errors
    @if_coroutine_done_quit_client

    if chunk then
      @read_response
    end
  end))
end))

@check_for_errors+=
assert(not err, err)

@create_read_function+=
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

@reader_variables+=
local chunk_buffer = ""

@start_coroutine_reader+=
coroutine.resume(co, getdata, senddata)

@read_response+=
chunk_buffer = chunk_buffer .. chunk
coroutine.resume(co)

@create_write_function+=
local function senddata(bytes)
  client:write(bytes)
end

@if_coroutine_done_quit_client+=
if coroutine.status(co) == "dead" then
  @quit_client
  return
end

@quit_client+=
client:close()
