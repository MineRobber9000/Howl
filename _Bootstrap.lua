--- Core script used to bootstrap the howl process
-- when running in a non-compiled howl environment
-- @script Bootstrap

local howlDirectory = fs.getDir(shell.getRunningProgram())

local fileLoader = loadfile
local env = setmetatable({}, {__index = getfenv()})
local function loadLocal(path)
	local file = fileLoader(fs.combine(howlDirectory, path))
	assert(file, "Cannot load file at " .. fs.combine(howlDirectory, path))
	return setfenv(file, env)
end

local function doFunction(f)
	local e=setmetatable({}, {__index = env})
	setfenv(f,e)
	local r=f()
	if r ~= nil then return r end
	return e
end

local function doFile(path)
	return doFunction(loadLocal(path))
end

local args = {...}
xpcall(setfenv(function()
	Mediator = doFile("core/Mediator.lua")
	ArgParse = doFile("core/ArgParse.lua")
	Utils = doFile("core/Utils.lua")
	Dump = doFile("core/Dump.lua")
	HowlFile = doFile("core/HowlFileLoader.lua")
	Depends = doFile("depends/Depends.lua")

	Context = doFile("tasks/Context.lua")
	Task = doFile("tasks/Task.lua")
	Runner = doFile("tasks/Runner.lua")
	doFile("tasks/Extensions.lua")

	doFile("depends/Combiner.lua")
	doFile("depends/Bootstrap.lua")

	TokenList = doFile("lexer/TokenList.lua")
	Constants = doFile("lexer/Constants.lua")
	Scope = doFile("lexer/Scope.lua")
	Parse = doFile("lexer/Parse.lua")
	Rebuild = doFile("lexer/Rebuild.lua")
	doFile("lexer/Tasks.lua")

	Files = doFile("files/Files.lua")
	doFile("files/Compilr.lua")

	loadLocal("Howl.lua")(unpack(args))
end, env), function(err)
	printError(err)
	for i = 3, 15 do
		local s, msg = pcall(error, "", i)
		if msg:match("_Bootstrap.lua") then break end
		print("\t", msg)
	end
end)