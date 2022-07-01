##ntangle-notebook
@if_no_info_provided_find_existing_kernel+=
if not port_shell or not key then
  if vim.g.ntangle_notebook_runtime_dir then
    @find_latest_kernel_json_file
    @open_kernel_json_file
    @get_shell_port_and_key
  end
end

@find_latest_kernel_json_file+=
local files = vim.fn.glob(vim.g.ntangle_notebook_runtime_dir .. "/*")
files = vim.split(files, "\n")
local dates = {}

for _, file in ipairs(files) do
  handle = vim.loop.fs_open(file, "r", 444)
  if handle then
    stat = vim.loop.fs_fstat(handle)
    table.insert(dates, stat.mtime.sec)
  else
    table.insert(dates, 0)
  end
end

local last = 1
local last_modified = dates[1]
local last_file = files[1]
for i, file in ipairs(files) do
  if last_modified < dates[i] then
    last_modified = dates[i]
    last_file = file
  end
end

@open_kernel_json_file+=
assert(last_file)
local lines = {}
for line in io.lines(last_file) do
  table.insert(lines, line)
end

local decoded = vim.json.decode(table.concat(lines, "\n"))

@get_shell_port_and_key+=
port_shell = tonumber(decoded["shell_port"])
key = decoded["key"]
