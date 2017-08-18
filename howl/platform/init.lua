--- The native loader for platforms
-- @module howl.platform

if fs and term then
	return require "howl.platform.cc"
else
	local ok,err = pcall(function() return require("component").redstone end)
	if not ok then
		return require "howl.platform.native"
	else
		return require "howl.platform.oc"
	end
end
