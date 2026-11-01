-- Common copy/run actions for RobloxScripts API response objects.

local ScriptActions = {}

function ScriptActions.copy(scriptData)
	if not scriptData or not scriptData.script then
		return false, "No runnable loader was supplied."
	end
	if not setclipboard then
		return false, "This executor does not expose setclipboard."
	end
	setclipboard(scriptData.script)
	return true
end

function ScriptActions.run(scriptData)
	if not scriptData or not scriptData.script then
		return false, "No runnable loader was supplied."
	end
	local ok, err = pcall(function()
		loadstring(scriptData.script)()
	end)
	return ok, err
end

return ScriptActions
