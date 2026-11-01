-- RobloxScripts.com API Browser
-- Executor context required: game:HttpGet, loadstring and (optionally) setclipboard.

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local API_BASE = "https://robloxscripts.com/api/v1/scripts"
local MAX_RESULTS = 50

local function getGuiParent()
	if gethui then
		return gethui()
	end
	return game:GetService("CoreGui")
end

local function make(className, properties)
	local object = Instance.new(className)
	for property, value in pairs(properties or {}) do
		object[property] = value
	end
	return object
end

local oldGui = getGuiParent():FindFirstChild("RobloxScriptsApiBrowser")
if oldGui then
	oldGui:Destroy()
end

local gui = make("ScreenGui", {
	Name = "RobloxScriptsApiBrowser",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = getGuiParent(),
})

local window = make("Frame", {
	Name = "Window",
	Size = UDim2.fromOffset(720, 505),
	Position = UDim2.new(0.5, -360, 0.5, -252),
	BackgroundColor3 = Color3.fromRGB(21, 29, 47),
	BackgroundTransparency = 0.16,
	BorderSizePixel = 0,
	Parent = gui,
})
make("UICorner", { CornerRadius = UDim.new(0, 10), Parent = window })
make("UIStroke", {
	Color = Color3.fromRGB(140, 186, 255),
	Transparency = 0.42,
	Thickness = 1,
	Parent = window,
})
make("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(49, 72, 111)),
		ColorSequenceKeypoint.new(0.48, Color3.fromRGB(21, 29, 47)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(37, 28, 65)),
	}),
	Rotation = 35,
	Parent = window,
})

local titleBar = make("Frame", {
	Name = "TitleBar",
	Size = UDim2.new(1, -52, 0, 42),
	Position = UDim2.fromOffset(0, 0),
	BackgroundTransparency = 1,
	Active = true,
	Parent = window,
})

local title = make("TextLabel", {
	Size = UDim2.new(1, -48, 0, 42),
	Position = UDim2.fromOffset(16, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "RobloxScripts API Browser",
	TextColor3 = Color3.fromRGB(240, 242, 255),
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = titleBar,
})

local closeButton = make("TextButton", {
	Size = UDim2.fromOffset(34, 34),
	Position = UDim2.new(1, -40, 0, 4),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "×",
	TextColor3 = Color3.fromRGB(190, 195, 210),
	TextSize = 24,
	Parent = window,
})

local function closeGui()
	gui:Destroy()
end

closeButton.MouseButton1Click:Connect(closeGui)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
		closeGui()
	end
end)

local function createInput(placeholder, position, width, defaultText)
	local input = make("TextBox", {
		Size = UDim2.fromOffset(width, 34),
		Position = position,
		BackgroundColor3 = Color3.fromRGB(43, 57, 82),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderText = placeholder,
		PlaceholderColor3 = Color3.fromRGB(135, 140, 160),
		Text = defaultText or "",
		TextColor3 = Color3.fromRGB(238, 240, 250),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = window,
	})
	make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = input })
	make("UIStroke", { Color = Color3.fromRGB(134, 174, 239), Transparency = 0.7, Parent = input })
	make("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent = input,
	})
	return input
end

local queryInput = createInput("Search scripts (e.g. blox fruits)", UDim2.fromOffset(16, 48), 320)
local gameInput = createInput("Game name or PlaceId", UDim2.fromOffset(344, 48), 190)
local limitInput = createInput("Limit", UDim2.fromOffset(542, 48), 62, "10")

local sortModes = { "newest", "oldest", "most-liked", "most-viewed", "trending", "title-asc", "title-desc" }
local sortIndex = 1
local sortButton = make("TextButton", {
	Size = UDim2.fromOffset(96, 34),
	Position = UDim2.fromOffset(612, 48),
	BackgroundColor3 = Color3.fromRGB(43, 57, 82),
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
	Font = Enum.Font.Gotham,
	Text = "Sort: newest",
	TextColor3 = Color3.fromRGB(238, 240, 250),
	TextSize = 12,
	Parent = window,
})
make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = sortButton })
make("UIStroke", { Color = Color3.fromRGB(134, 174, 239), Transparency = 0.7, Parent = sortButton })
sortButton.MouseButton1Click:Connect(function()
	sortIndex = (sortIndex % #sortModes) + 1
	sortButton.Text = "Sort: " .. sortModes[sortIndex]
end)

local searchButton = make("TextButton", {
	Size = UDim2.fromOffset(120, 34),
	Position = UDim2.fromOffset(16, 92),
	BackgroundColor3 = Color3.fromRGB(74, 118, 255),
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Text = "Search",
	TextColor3 = Color3.new(1, 1, 1),
	TextSize = 14,
	Parent = window,
})
make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = searchButton })
make("UIStroke", { Color = Color3.fromRGB(175, 205, 255), Transparency = 0.48, Parent = searchButton })

local status = make("TextLabel", {
	Size = UDim2.new(1, -160, 0, 34),
	Position = UDim2.fromOffset(148, 92),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Ready — enter a query and press Search.",
	TextColor3 = Color3.fromRGB(165, 171, 190),
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = window,
})

local results = make("ScrollingFrame", {
	Size = UDim2.new(1, -32, 1, -142),
	Position = UDim2.fromOffset(16, 132),
	BackgroundColor3 = Color3.fromRGB(33, 44, 67),
	BackgroundTransparency = 0.28,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 6,
	Parent = window,
})
make("UICorner", { CornerRadius = UDim.new(0, 7), Parent = results })
make("UIStroke", { Color = Color3.fromRGB(132, 170, 235), Transparency = 0.72, Parent = results })
local listLayout = make("UIListLayout", { Padding = UDim.new(0, 6), Parent = results })
make("UIPadding", {
	PaddingTop = UDim.new(0, 8),
	PaddingBottom = UDim.new(0, 8),
	PaddingLeft = UDim.new(0, 8),
	PaddingRight = UDim.new(0, 8),
	Parent = results,
})

local function clearResults()
	for _, child in ipairs(results:GetChildren()) do
		if child:IsA("Frame") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end
end

local function showResult(scriptData)
	local row = make("Frame", {
		Size = UDim2.new(1, 0, 0, 75),
		BackgroundColor3 = Color3.fromRGB(57, 73, 105),
		BackgroundTransparency = 0.34,
		BorderSizePixel = 0,
		Parent = results,
	})
	make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = row })
	make("UIStroke", { Color = Color3.fromRGB(145, 183, 246), Transparency = 0.8, Parent = row })

	local access = scriptData.accessType or "unknown"
	local author = scriptData.author and scriptData.author.username or "unknown"
	local games = scriptData.games and table.concat(scriptData.games, ", ") or (scriptData.game and scriptData.game.name) or "Universal"
	make("TextLabel", {
		Size = UDim2.new(1, -170, 0, 26),
		Position = UDim2.fromOffset(10, 6),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = scriptData.title or "Untitled script",
		TextColor3 = Color3.fromRGB(242, 244, 255),
		TextSize = 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
	make("TextLabel", {
		Size = UDim2.new(1, -170, 0, 24),
		Position = UDim2.fromOffset(10, 36),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = string.format("%s · %s · %s views · %s", author, access, tostring(scriptData.views or 0), games),
		TextColor3 = Color3.fromRGB(166, 173, 195),
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local function actionButton(text, x, color)
		local button = make("TextButton", {
			Size = UDim2.fromOffset(65, 30),
			Position = UDim2.new(1, x, 0.5, -15),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Text = text,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 12,
			Parent = row,
		})
		make("UICorner", { CornerRadius = UDim.new(0, 5), Parent = button })
		return button
	end

	actionButton("Copy", -142, Color3.fromRGB(78, 88, 113)).MouseButton1Click:Connect(function()
		if setclipboard and scriptData.script then
			setclipboard(scriptData.script)
			status.Text = "Copied loader for: " .. (scriptData.title or "script")
		else
			status.Text = "Clipboard support is unavailable in this executor."
		end
	end)

	actionButton("Run", -70, Color3.fromRGB(63, 157, 101)).MouseButton1Click:Connect(function()
		if not scriptData.script then
			status.Text = "This result has no runnable loader."
			return
		end
		status.Text = "Running: " .. (scriptData.title or "script")
		local ok, err = pcall(function()
			loadstring(scriptData.script)()
		end)
		if not ok then
			status.Text = "Execution failed: " .. tostring(err)
		end
	end)
end

local function performSearch()
	local limit = math.clamp(tonumber(limitInput.Text) or 10, 1, MAX_RESULTS)
	limitInput.Text = tostring(limit)

	local parameters = {
		"limit=" .. tostring(limit),
		"sort=" .. HttpService:UrlEncode(sortModes[sortIndex]),
	}
	if queryInput.Text ~= "" then
		table.insert(parameters, "q=" .. HttpService:UrlEncode(queryInput.Text))
	end
	if gameInput.Text ~= "" then
		if gameInput.Text:match("^%d+$") then
			table.insert(parameters, "placeId=" .. HttpService:UrlEncode(gameInput.Text))
		else
			table.insert(parameters, "game=" .. HttpService:UrlEncode(gameInput.Text))
		end
	end

	clearResults()
	status.Text = "Searching…"
	searchButton.Active = false
	searchButton.Text = "Loading…"

	local ok, response = pcall(function()
		return HttpService:JSONDecode(game:HttpGet(API_BASE .. "?" .. table.concat(parameters, "&")))
	end)

	searchButton.Active = true
	searchButton.Text = "Search"
	if not ok then
		status.Text = "Request failed: " .. tostring(response)
		return
	end
	if response.error then
		status.Text = "API error: " .. tostring(response.error)
		return
	end

	local data = response.data or {}
	for _, scriptData in ipairs(data) do
		showResult(scriptData)
	end
	status.Text = string.format("Showing %d result(s) of %s.", #data, tostring(response.pagination and response.pagination.total or #data))
	if #data == 0 then
		make("TextLabel", {
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = "No scripts matched your filters.",
			TextColor3 = Color3.fromRGB(170, 176, 195),
			TextSize = 14,
			Parent = results,
		})
	end
end

searchButton.MouseButton1Click:Connect(performSearch)
queryInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		performSearch()
	end
end)
