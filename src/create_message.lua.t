##ntangle-notebook
@declare+=
local create_message

@local_defines+=
function create_message(msg)
  return create_frame("", false, true) .. create_frame(msg, false, false)
end
