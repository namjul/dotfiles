-- ~/.config/yazi/init.lua
-- Requires `ya pkg install` after pulling package.toml (yazi-plugin/zoxide).
local ok, zoxide = pcall(require, "zoxide")
if ok then
	zoxide:setup({
		update_db = true,
	})
end
