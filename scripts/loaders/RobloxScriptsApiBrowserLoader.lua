-- Remote loader for the repository's executor-ready application.
-- Resolves main to an immutable commit before loading, avoiding executor/raw CDN caches.

local HttpService = game:GetService("HttpService")
local REPOSITORY = "0craxy0/RobloxScriptzConnector"
local PATH = "scripts/apps/RobloxScriptsApiBrowser.lua"
local refUrl = string.format("https://api.github.com/repos/%s/git/ref/heads/main?ts=%s", REPOSITORY, tostring(os.time()))

local ref = HttpService:JSONDecode(game:HttpGet(refUrl))
local commitSha = ref and ref.object and ref.object.sha
assert(type(commitSha) == "string" and #commitSha > 0, "Unable to resolve the latest GitHub commit")

local url = string.format("https://raw.githubusercontent.com/%s/%s/%s", REPOSITORY, commitSha, PATH)

loadstring(game:HttpGet(url))()
