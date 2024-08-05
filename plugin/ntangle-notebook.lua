vim.api.nvim_create_user_command("SendNTangleV2", function() require"ntangle-notebook".send_ntangle_visual_v2() end, { range = true })
