##ntangle-notebook
@if_no_info_provided_find_existing_kernel+=
if not port_shell or not key then
  if vim.g.ntangle_notebook_runtime_dir then
    @find_latest_kernel_json_file
		return
  end
end

@find_latest_kernel_json_file+=
local files = vim.fn.glob(vim.g.ntangle_notebook_runtime_dir .. "/*")
files = vim.split(files, "\n")
local dates = {}

dates = {}
indices = {}
valid_files = {}

for i, file in ipairs(files) do
  handle = vim.loop.fs_open(file, "r", 444)
  if handle and vim.fn.fnamemodify(file, ":e") == "json" then
		if vim.startswith( vim.fn.fnamemodify(file, ":t:r"), "kernel" ) then
			stat = vim.loop.fs_fstat(handle)
			table.insert(dates, stat.mtime.sec)
			table.insert(valid_files, file)
			table.insert(indices, #valid_files)
		end
  end
end

@sort_by_dates

assert(vim.tbl_count(indices) > 0)

local selected_file
if #indices > 1 then
	selected_file = vim.ui.select(indices, {
			prompt = "Select kernel: ",
			format_item = function(idx)
				local mdate = os.date("%d.%m.%Y %X", dates[idx])
				local filename = vim.fn.fnamemodify(valid_files[idx], ":t:r")
				return ("%s | %s"):format(mdate, filename)
			end
		}, 
		function(choice)
			if choice then
				local selected_file = valid_files[choice]

				@open_kernel_json_file
				@get_shell_port_and_key

				@send_code_coroutine_test
				@connect_to_shell
			end
		end)
elseif #indices == 1 then
	local selected_file = valid_files[indices[1]]

	@open_kernel_json_file
	@get_shell_port_and_key

	@send_code_coroutine_test
	@connect_to_shell
else
	print("No running kernel.")
end

@sort_by_dates+=
table.sort(indices, function(a,b) 
	return dates[a] > dates[b]
end)

@open_kernel_json_file+=
local lines = {}
for line in io.lines(selected_file) do
  table.insert(lines, line)
end

local decoded = vim.json.decode(table.concat(lines, "\n"))

@get_shell_port_and_key+=
port_shell = tonumber(decoded["shell_port"])
key = decoded["key"]
