-- Remote loader for the repository's executor-ready application.
-- Run this after publishing the repository publicly on GitHub.

local REPOSITORY = "0craxy0/RobloxScriptzConnector"
local BRANCH = "main"
local PATH = "scripts/apps/RobloxScriptsApiBrowser.lua"
local url = string.format("https://raw.githubusercontent.com/%s/%s/%s", REPOSITORY, BRANCH, PATH)

loadstring(game:HttpGet(url))()
