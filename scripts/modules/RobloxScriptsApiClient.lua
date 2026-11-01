-- Reusable client for https://robloxscripts.com/api/v1/scripts.
-- Intended for executor environments that expose game:HttpGet.

local HttpService = game:GetService("HttpService")

local ApiClient = {}
ApiClient.BASE_URL = "https://robloxscripts.com/api/v1/scripts"
ApiClient.MAX_LIMIT = 50

local function addParameter(parts, key, value)
	if value ~= nil and tostring(value) ~= "" then
		table.insert(parts, key .. "=" .. HttpService:UrlEncode(tostring(value)))
	end
end

function ApiClient.search(filters)
	filters = filters or {}
	local limit = math.clamp(tonumber(filters.limit) or 10, 1, ApiClient.MAX_LIMIT)
	local parts = { "limit=" .. limit }

	addParameter(parts, "q", filters.query)
	addParameter(parts, "game", filters.game)
	addParameter(parts, "placeId", filters.placeId)
	addParameter(parts, "author", filters.author)
	addParameter(parts, "access", filters.access)
	addParameter(parts, "sort", filters.sort or "newest")

	local ok, body = pcall(function()
		return game:HttpGet(ApiClient.BASE_URL .. "?" .. table.concat(parts, "&"))
	end)
	if not ok then
		return nil, "HTTP request failed: " .. tostring(body)
	end

	local decoded, response = pcall(HttpService.JSONDecode, HttpService, body)
	if not decoded then
		return nil, "Invalid JSON response: " .. tostring(response)
	end
	if response.error then
		return nil, "API error: " .. tostring(response.error)
	end
	return response
end

return ApiClient
