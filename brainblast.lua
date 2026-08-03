
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- =============================================================================
-- WEB HOOK
-- =============================================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local ENDPOINT = "https://novahub-helper-production.up.railway.app" -- your bot's public URL (whatever /health responds on), no trailing slash
local API_KEY = "a3f9c21e8b47d0f6c9e2a1b4d8f0e6c3a9d2b7e4f1c8a0b6" -- must match HEARTBEAT_API_KEY in your bot's .env
local PING_INTERVAL = 30 -- seconds

local player = Players.LocalPlayer
local sessionId = tostring(player.UserId)

-- Delta exposes `request` globally; some builds also expose it as
-- `http_request` or under `syn.request`. This picks whichever exists.
local sendRequest = request or http_request or (syn and syn.request)



local function sendHeartbeat()
	if not sendRequest then
		warn("Nova Hub")
		return
	end
	local ok, response = pcall(function()
		return sendRequest({
			Url = ENDPOINT .. "/heartbeat",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["Authorization"] = "Bearer " .. API_KEY,
			},
			Body = HttpService:JSONEncode({ id = sessionId }),
		})
	end)
	
	if ok then
		
	else
		
	end
end

local function sendLeave()
	if not sendRequest then return end
	pcall(function()
		sendRequest({
			Url = ENDPOINT .. "/leave",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["Authorization"] = "Bearer " .. API_KEY,
			},
			Body = game:GetService("HttpService"):JSONEncode({ id = sessionId }),
		})
	end)
end

sendHeartbeat()

task.spawn(function()
	while task.wait(PING_INTERVAL) do
		sendHeartbeat()
	end
end)

Players.PlayerRemoving:Connect(function(p)
	if p == player then
		sendLeave()
	end
end)

-- =============================================================================
-- CONFIGURATION
-- =============================================================================
local Colors = {
    Background   = Color3.fromRGB(15, 16, 20),
    SidebarBg    = Color3.fromRGB(20, 21, 26),
    CardBg       = Color3.fromRGB(27, 29, 35),
    CardBgHover  = Color3.fromRGB(36, 38, 46),
    CardGlass    = Color3.fromRGB(46, 44, 58), -- glass-card background, used at low opacity
    Accent       = Color3.fromRGB(167, 85, 255),
    AccentDim    = Color3.fromRGB(120, 70, 200),
    AccentRed    = Color3.fromRGB(255, 85, 90),
    TextWhite    = Color3.fromRGB(245, 244, 250),
    TextMuted    = Color3.fromRGB(140, 136, 156),
    TextDim      = Color3.fromRGB(90, 87, 102),
    Separator    = Color3.fromRGB(36, 38, 46),
    TopBarBg     = Color3.fromRGB(18, 19, 24),
}

local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED  = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWEEN_SLOW = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local SPLASH_DURATION = 5 -- seconds, as requested

-- Smaller default size so it fits comfortably centered on ~360dpi mobile screens too
local DEFAULT_WIDTH = 540
local DEFAULT_HEIGHT = 340

-- =============================================================================
-- HEADER INFO (small, easy to update for dev/version tracking)
-- =============================================================================
local VERSION_TEXT = "v1.1.0" -- bump this on every release
local DISCORD_INVITE = "discord.gg/GZmXAVh6zb" -- shown as a copyable string in the header

local GAME_NAME
do
    local ok, info = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    GAME_NAME = (ok and info and info.Name) or game.Name or "Unknown Game"
end

-- =============================================================================
-- ROOT GUI
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NovaGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- =============================================================================
-- SPLASH SCREEN
-- =============================================================================
local Splash = Instance.new("Frame")
Splash.Name = "Splash"
Splash.AnchorPoint = Vector2.new(0.5, 0.5)
Splash.Position = UDim2.new(0.5, 0, 0.5, 0)
Splash.Size = UDim2.new(0, 260, 0, 180)
Splash.BackgroundColor3 = Colors.Background
Splash.BorderSizePixel = 0
Splash.ClipsDescendants = true
Splash.ZIndex = 1000
Splash.Parent = ScreenGui

local SplashCorner = Instance.new("UICorner", Splash)
SplashCorner.CornerRadius = UDim.new(0, 14)

local SplashStroke = Instance.new("UIStroke", Splash)
SplashStroke.Color = Colors.Accent
SplashStroke.Transparency = 0.75
SplashStroke.Thickness = 1

-- faint radial-ish glow behind the logo using a gradient-stroked ring
local GlowRing = Instance.new("Frame", Splash)
GlowRing.Name = "GlowRing"
GlowRing.AnchorPoint = Vector2.new(0.5, 0.5)
GlowRing.Position = UDim2.new(0.5, 0, 0.5, -44)
GlowRing.Size = UDim2.new(0, 56, 0, 56)
GlowRing.BackgroundTransparency = 1
GlowRing.ZIndex = 1001

local GlowRingCorner = Instance.new("UICorner", GlowRing)
GlowRingCorner.CornerRadius = UDim.new(1, 0)

local GlowStroke = Instance.new("UIStroke", GlowRing)
GlowStroke.Color = Colors.Accent
GlowStroke.Thickness = 2
GlowStroke.Transparency = 0.35

-- inner core dot
local CoreDot = Instance.new("Frame", GlowRing)
CoreDot.AnchorPoint = Vector2.new(0.5, 0.5)
CoreDot.Position = UDim2.new(0.5, 0, 0.5, 0)
CoreDot.Size = UDim2.new(0, 18, 0, 18)
CoreDot.BackgroundColor3 = Colors.Accent
CoreDot.ZIndex = 1002
Instance.new("UICorner", CoreDot).CornerRadius = UDim.new(1, 0)

-- orbiting particle that spins around the ring continuously
local Orbiter = Instance.new("Frame", GlowRing)
Orbiter.AnchorPoint = Vector2.new(0.5, 0.5)
Orbiter.Size = UDim2.new(0, 6, 0, 6)
Orbiter.Position = UDim2.new(0.5, 28, 0.5, 0)
Orbiter.BackgroundColor3 = Colors.TextWhite
Orbiter.ZIndex = 1003
Instance.new("UICorner", Orbiter).CornerRadius = UDim.new(1, 0)

-- Title text
local SplashTitle = Instance.new("TextLabel", Splash)
SplashTitle.AnchorPoint = Vector2.new(0.5, 0.5)
SplashTitle.Position = UDim2.new(0.5, 0, 0.5, -2)
SplashTitle.Size = UDim2.new(0, 220, 0, 26)
SplashTitle.BackgroundTransparency = 1
SplashTitle.Text = "NOVA HUB"
SplashTitle.Font = Enum.Font.GothamBold
SplashTitle.TextSize = 20
SplashTitle.TextColor3 = Colors.TextWhite
SplashTitle.TextTransparency = 1
SplashTitle.ZIndex = 1001

local SplashSubtitle = Instance.new("TextLabel", Splash)
SplashSubtitle.AnchorPoint = Vector2.new(0.5, 0.5)
SplashSubtitle.Position = UDim2.new(0.5, 0, 0.5, 20)
SplashSubtitle.Size = UDim2.new(0, 220, 0, 16)
SplashSubtitle.BackgroundTransparency = 1
SplashSubtitle.Text = "Initializing interface..."
SplashSubtitle.Font = Enum.Font.Gotham
SplashSubtitle.TextSize = 11
SplashSubtitle.TextColor3 = Colors.TextMuted
SplashSubtitle.TextTransparency = 1
SplashSubtitle.ZIndex = 1001

-- Progress bar track + fill
local BarTrack = Instance.new("Frame", Splash)
BarTrack.AnchorPoint = Vector2.new(0.5, 0.5)
BarTrack.Position = UDim2.new(0.5, 0, 0.5, 48)
BarTrack.Size = UDim2.new(0, 200, 0, 4)
BarTrack.BackgroundColor3 = Colors.Separator
BarTrack.BackgroundTransparency = 1
BarTrack.ZIndex = 1001
Instance.new("UICorner", BarTrack).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame", BarTrack)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Colors.Accent
BarFill.BackgroundTransparency = 1
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 1002
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)
local BarGradient = Instance.new("UIGradient", BarFill)
BarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.AccentDim),
    ColorSequenceKeypoint.new(1, Colors.Accent),
})

-- Percentage counter
local PercentLabel = Instance.new("TextLabel", Splash)
PercentLabel.AnchorPoint = Vector2.new(0.5, 0.5)
PercentLabel.Position = UDim2.new(0.5, 0, 0.5, 66)
PercentLabel.Size = UDim2.new(0, 200, 0, 16)
PercentLabel.BackgroundTransparency = 1
PercentLabel.Text = "0%"
PercentLabel.Font = Enum.Font.GothamMedium
PercentLabel.TextSize = 11
PercentLabel.TextColor3 = Colors.TextDim
PercentLabel.TextTransparency = 1
PercentLabel.ZIndex = 1001

-- Fade the splash elements in
TweenService:Create(GlowStroke, TWEEN_SLOW, {Transparency = 0.35}):Play()
TweenService:Create(CoreDot, TWEEN_SLOW, {BackgroundTransparency = 0}):Play()
CoreDot.BackgroundTransparency = 1
TweenService:Create(CoreDot, TWEEN_SLOW, {BackgroundTransparency = 0}):Play()
TweenService:Create(SplashTitle, TWEEN_SLOW, {TextTransparency = 0}):Play()
TweenService:Create(SplashSubtitle, TWEEN_SLOW, {TextTransparency = 0.2}):Play()
TweenService:Create(BarTrack, TWEEN_SLOW, {BackgroundTransparency = 0}):Play()
TweenService:Create(BarFill, TWEEN_SLOW, {BackgroundTransparency = 0}):Play()
TweenService:Create(PercentLabel, TWEEN_SLOW, {TextTransparency = 0.2}):Play()

-- Pulsing glow ring (loops for the whole splash duration)
local pulseTween = TweenService:Create(
    GlowRing,
    TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    {Size = UDim2.new(0, 66, 0, 66)}
)
pulseTween:Play()

local corePulse = TweenService:Create(
    CoreDot,
    TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    {Size = UDim2.new(0, 14, 0, 14)}
)
corePulse:Play()

-- Continuous orbit rotation around the ring's center for the whole splash duration
local orbitAngle = 0
local orbitRadius = 28
local orbitConn
orbitConn = RunService.RenderStepped:Connect(function(dt)
    orbitAngle = orbitAngle + dt * 260 -- degrees per second
    local rad = math.rad(orbitAngle)
    Orbiter.Position = UDim2.new(0.5, math.cos(rad) * orbitRadius, 0.5, math.sin(rad) * orbitRadius)
end)

-- Animate the progress bar filling over the full splash duration, with a live ticking percentage
local barFillTween = TweenService:Create(
    BarFill,
    TweenInfo.new(SPLASH_DURATION, Enum.EasingStyle.Linear),
    {Size = UDim2.new(1, 0, 1, 0)}
)
barFillTween:Play()

local startTime = tick()
local percentConn
percentConn = RunService.RenderStepped:Connect(function()
    local elapsed = tick() - startTime
    local pct = math.clamp(math.floor((elapsed / SPLASH_DURATION) * 100), 0, 100)
    PercentLabel.Text = pct .. "%"
end)

-- =============================================================================
-- MAIN WINDOW (built underneath the splash, revealed once splash finishes)
-- =============================================================================
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.45
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Size = UDim2.new(1, 60, 1, 60)
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.ZIndex = 0

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, DEFAULT_WIDTH, 0, DEFAULT_HEIGHT)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Colors.Background
Main.BackgroundTransparency = 1 -- starts invisible; fades in after splash (never resized, so nothing can get stuck clipped/hidden)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = false
Main.Parent = ScreenGui
Shadow.Parent = Main

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Colors.Accent
MainStroke.Transparency = 1
MainStroke.Thickness = 1

local EdgeGlow = Instance.new("Frame", Main)
EdgeGlow.Size = UDim2.new(1, 0, 0, 2)
EdgeGlow.BackgroundColor3 = Colors.Accent
EdgeGlow.BorderSizePixel = 0
EdgeGlow.ZIndex = 10
local EdgeGradient = Instance.new("UIGradient", EdgeGlow)
EdgeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors.Background),
    ColorSequenceKeypoint.new(0.5, Colors.Accent),
    ColorSequenceKeypoint.new(1, Colors.Background),
})

-- =============================================================================
-- TOP BAR
-- =============================================================================
local TopBar = Instance.new("Frame", Main)
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.Position = UDim2.new(0, 0, 0, 2)
TopBar.BackgroundColor3 = Colors.TopBarBg
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 5

local TopBarCorner = Instance.new("UICorner", TopBar)
TopBarCorner.CornerRadius = UDim.new(0, 14)
local TopBarMask = Instance.new("Frame", TopBar)
TopBarMask.Size = UDim2.new(1, 0, 0, 14)
TopBarMask.Position = UDim2.new(0, 0, 1, -14)
TopBarMask.BackgroundColor3 = Colors.TopBarBg
TopBarMask.BorderSizePixel = 0
TopBarMask.ZIndex = 5

local LogoDot = Instance.new("Frame", TopBar)
LogoDot.Size = UDim2.new(0, 8, 0, 8)
LogoDot.Position = UDim2.new(0, 14, 0.5, -4)
LogoDot.BackgroundColor3 = Colors.Accent
LogoDot.ZIndex = 6
Instance.new("UICorner", LogoDot).CornerRadius = UDim.new(1, 0)
local LogoGlow = Instance.new("UIStroke", LogoDot)
LogoGlow.Color = Colors.Accent
LogoGlow.Thickness = 3
LogoGlow.Transparency = 0.7

-- HeaderRow: "| NOVA HUB |  v1.1.0 • Game Name • [Copy Discord]", all vertically centered
-- and clipped so it never invades the minimize/close buttons on the right.
local HeaderRow = Instance.new("Frame", TopBar)
HeaderRow.Name = "HeaderRow"
HeaderRow.Position = UDim2.new(0, 30, 0, 0)
HeaderRow.Size = UDim2.new(1, -100, 1, 0)
HeaderRow.BackgroundTransparency = 1
HeaderRow.ClipsDescendants = true
HeaderRow.ZIndex = 6

local HeaderList = Instance.new("UIListLayout", HeaderRow)
HeaderList.FillDirection = Enum.FillDirection.Horizontal
HeaderList.VerticalAlignment = Enum.VerticalAlignment.Center
HeaderList.SortOrder = Enum.SortOrder.LayoutOrder
HeaderList.Padding = UDim.new(0, 6)

local function headerLabel(text, order, font, size, color, autoSize, fixedWidth)
    local lbl = Instance.new("TextLabel", HeaderRow)
    lbl.LayoutOrder = order
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = font
    lbl.TextSize = size
    lbl.TextColor3 = color
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.ZIndex = 6
    if autoSize then
        lbl.Size = UDim2.new(0, 0, 1, 0)
        lbl.AutomaticSize = Enum.AutomaticSize.X
    else
        lbl.Size = UDim2.new(0, fixedWidth or 80, 1, 0)
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
    end
    return lbl
end

-- Title, bracketed like "| NOVA HUB |" -- pipes muted, title bright and dominant

local HeaderTitle = headerLabel("NOVA HUB", 2, Enum.Font.GothamBold, 13, Colors.TextWhite, true)
headerLabel("| ", 3, Enum.Font.GothamBold, 13, Colors.TextDim, true)

-- Secondary info: small font, muted colors, so the title stays the focal point
headerLabel(VERSION_TEXT, 4, Enum.Font.Gotham, 10, Colors.TextDim, true)
headerLabel("•", 5, Enum.Font.Gotham, 10, Colors.TextDim, true) -- "•"
headerLabel(GAME_NAME, 6, Enum.Font.Gotham, 10, Colors.TextMuted, false, 100)
headerLabel("•", 7, Enum.Font.Gotham, 10, Colors.TextDim, true) -- "•"

local DiscordBtn = Instance.new("TextButton", HeaderRow)
DiscordBtn.Name = "DiscordCopyBtn"
DiscordBtn.LayoutOrder = 8
DiscordBtn.Size = UDim2.new(0, 90, 0, 18)
DiscordBtn.BackgroundColor3 = Colors.CardBg
DiscordBtn.BackgroundTransparency = 0.25
DiscordBtn.Text = "Copy Discord"
DiscordBtn.Font = Enum.Font.GothamMedium
DiscordBtn.TextSize = 10
DiscordBtn.TextColor3 = Colors.TextMuted
DiscordBtn.AutoButtonColor = false
DiscordBtn.ZIndex = 6
Instance.new("UICorner", DiscordBtn).CornerRadius = UDim.new(0, 5)
local DiscordStroke = Instance.new("UIStroke", DiscordBtn)
DiscordStroke.Color = Colors.Accent
DiscordStroke.Transparency = 0.7
DiscordStroke.Thickness = 1

DiscordBtn.MouseEnter:Connect(function()
    TweenService:Create(DiscordBtn, TWEEN_FAST, {BackgroundTransparency = 0, TextColor3 = Colors.TextWhite}):Play()
end)
DiscordBtn.MouseLeave:Connect(function()
    TweenService:Create(DiscordBtn, TWEEN_FAST, {BackgroundTransparency = 0.25, TextColor3 = Colors.TextMuted}):Play()
end)
DiscordBtn.MouseButton1Click:Connect(function()
    local ok = pcall(function()
        setclipboard(DISCORD_INVITE)
    end)
    local original = DiscordBtn.Text
    DiscordBtn.Text = ok and "Copied!" or "Unavailable"
    task.delay(1.2, function()
        DiscordBtn.Text = original
    end)
end)

local function makeTopBarButton(name, xOffset, glyph, glyphSize)
    local btn = Instance.new("TextButton", TopBar)
    btn.Name = name
    btn.Size = UDim2.new(0, 26, 0, 22)
    btn.Position = UDim2.new(1, xOffset, 0.5, -11)
    btn.BackgroundColor3 = Colors.CardBg
    btn.Text = glyph
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = glyphSize
    btn.TextColor3 = Colors.TextMuted
    btn.AutoButtonColor = false
    btn.ZIndex = 6
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    return btn
end

local MinimizeBtn = makeTopBarButton("MinimizeBtn", -62, "—", 14)
local CloseBtn = makeTopBarButton("CloseBtn", -32, "✕", 12)

local function applyHover(button, hoverColor, baseColor, hoverText, baseText)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TWEEN_FAST, {BackgroundColor3 = hoverColor, TextColor3 = hoverText or Colors.TextWhite}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TWEEN_FAST, {BackgroundColor3 = baseColor, TextColor3 = baseText or Colors.TextMuted}):Play()
    end)
end

applyHover(MinimizeBtn, Colors.CardBgHover, Colors.CardBg)
applyHover(CloseBtn, Colors.AccentRed, Colors.CardBg, Colors.TextWhite)

-- =============================================================================
-- SIDEBAR (vertical navigation)
-- =============================================================================
local Sidebar = Instance.new("Frame", Main)
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 96, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Colors.CardBg -- was SidebarBg, which is nearly identical to Background (both near-black) and made the panel invisible
Sidebar.BackgroundTransparency = 0
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3

-- IMPORTANT: parented to Main, NOT Sidebar. Sidebar has a UIListLayout which auto-stacks
-- every child frame it contains; a full-height divider living inside it would eat an entire
-- "slot" in that vertical stack and shove the Dashboard/Settings buttons off-screen below it.
local SidebarDivider = Instance.new("Frame", Main)
SidebarDivider.Size = UDim2.new(0, 1, 1, -40)
SidebarDivider.Position = UDim2.new(0, 96, 0, 40)
SidebarDivider.BackgroundColor3 = Colors.Accent
SidebarDivider.BackgroundTransparency = 0.6
SidebarDivider.BorderSizePixel = 0
SidebarDivider.ZIndex = 4

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.FillDirection = Enum.FillDirection.Vertical
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Padding = UDim.new(0, 4)

local SidebarPad = Instance.new("UIPadding", Sidebar)
SidebarPad.PaddingTop = UDim.new(0, 10)
SidebarPad.PaddingLeft = UDim.new(0, 8)
SidebarPad.PaddingRight = UDim.new(0, 8)

local tabButtons = {}
local tabIndicators = {}
local pages = {}
local currentTab = nil

local function createTabButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Colors.CardBg
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    -- left accent indicator; animates its height in/out (vertical bar, matches sidebar orientation)
    local indicator = Instance.new("Frame", btn)
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.Size = UDim2.new(0, 3, 0, 0)
    indicator.Position = UDim2.new(0, 0, 0.5, 0)
    indicator.BackgroundColor3 = Colors.Accent
    indicator.BorderSizePixel = 0
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextColor3 = Colors.TextMuted
    label.TextXAlignment = Enum.TextXAlignment.Left

    btn.MouseEnter:Connect(function()
        if currentTab ~= name then
            TweenService:Create(btn, TWEEN_FAST, {BackgroundTransparency = 0.3}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= name then
            TweenService:Create(btn, TWEEN_FAST, {BackgroundTransparency = 1}):Play()
        end
    end)

    tabButtons[name] = {button = btn, label = label}
    tabIndicators[name] = indicator
    return btn
end

-- =============================================================================
-- CONTENT AREA (sits to the right of the sidebar)
-- =============================================================================
local Content = Instance.new("Frame", Main)
Content.Name = "Content"
Content.Size = UDim2.new(1, -96, 1, -40)
Content.Position = UDim2.new(0, 96, 0, 40)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true

-- Margin used everywhere around/between page content so every gap in the UI
-- (outer edges AND the gap between the two columns) is the exact same size.
local PAGE_MARGIN = 10
local RIGHT_EXTRA_MARGIN = 12
local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Colors.Accent
    page.ScrollBarImageTransparency = 0.3
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Parent = Content

    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0, PAGE_MARGIN)
    pad.PaddingLeft = UDim.new(0, PAGE_MARGIN)
    pad.PaddingRight = UDim.new(0, PAGE_MARGIN + RIGHT_EXTRA_MARGIN)
    pad.PaddingBottom = UDim.new(0, PAGE_MARGIN)

    -- CENTER SEPARATOR: an invisible layout boundary only -- not meant to be seen.
    -- Sits exactly on the 50% line and defines the gap both columns are built around,
    -- so the two panels can never overlap, drift out of alignment, or touch while resizing.
    -- CENTER_GAP is PAGE_MARGIN plus a little extra, so the middle gap reads as
    -- slightly more generous than the outer left/right margins.
    local CENTER_GAP = PAGE_MARGIN + 12
    local separator = Instance.new("Frame", page)
    separator.Name = "CenterSeparator"
    separator.AnchorPoint = Vector2.new(0.5, 0)
    separator.Position = UDim2.new(0.5, 0, 0, 0)
    separator.Size = UDim2.new(0, CENTER_GAP, 1, 0)
    separator.BackgroundTransparency = 1 -- fully invisible; boundary only
    separator.BorderSizePixel = 0
    separator.Active = false
    separator.Selectable = false
    separator.ZIndex = 0

    -- LEFT COLUMN: stacks its own boxes independently of the right column
    local left = Instance.new("Frame", page)
    left.Name = "LeftColumn"
    left.Size = UDim2.new(0.5, -(CENTER_GAP / 2), 0, 0)
    left.Position = UDim2.new(0, 0, 0, 0)
    left.BackgroundTransparency = 1
    left.AutomaticSize = Enum.AutomaticSize.Y

    local leftList = Instance.new("UIListLayout", left)
    leftList.SortOrder = Enum.SortOrder.LayoutOrder
    leftList.Padding = UDim.new(0, 10)

    -- RIGHT COLUMN: separate stack, same width, sits beside the left column
    local right = Instance.new("Frame", page)
    right.Name = "RightColumn"
    right.Size = UDim2.new(0.5, -(CENTER_GAP / 2), 0, 0)
    right.Position = UDim2.new(0.5, (CENTER_GAP / 2), 0, 0)
    right.BackgroundTransparency = 1
    right.AutomaticSize = Enum.AutomaticSize.Y

    local rightList = Instance.new("UIListLayout", right)
    rightList.SortOrder = Enum.SortOrder.LayoutOrder
    rightList.Padding = UDim.new(0, 10)

    pages[name] = page
    return left, right
end

-- A "box" is a bordered card that groups one type of content together.
-- Stack several boxes (via LayoutOrder) inside the same column to get
-- "box 1 for content A, box 2 below it for content B", etc.
-- Pass the returned box into addButton/addToggle/addSectionLabel/addStatCard
-- as their "page" argument -- those helpers just parent into whatever frame you give them.
local function addBox(column, order)
    local box = Instance.new("Frame", column)
    box.Name = "Box"
    box.LayoutOrder = order
    box.BackgroundColor3 = Colors.CardGlass
    box.BackgroundTransparency = 0.80
    box.BorderSizePixel = 0
    box.Size = UDim2.new(1, 0, 0, 0)
    box.AutomaticSize = Enum.AutomaticSize.Y
    box.ZIndex = 2
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", box)
    stroke.Color = Colors.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.72
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local glowStroke = Instance.new("UIStroke", box)
    glowStroke.Color = Colors.Accent
    glowStroke.Thickness = 3
    glowStroke.Transparency = 0.9
    glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local boxPad = Instance.new("UIPadding", box)
    boxPad.PaddingTop = UDim.new(0, 12)
    boxPad.PaddingBottom = UDim.new(0, 12)
    boxPad.PaddingLeft = UDim.new(0, 12)
    boxPad.PaddingRight = UDim.new(0, 12)

    local boxList = Instance.new("UIListLayout", box)
    boxList.SortOrder = Enum.SortOrder.LayoutOrder
    boxList.Padding = UDim.new(0, 8)

    return box
end

local function switchTab(name)
    if currentTab == name then return end
    for tabName, page in pairs(pages) do
        page.Visible = (tabName == name)
    end
    for tabName, parts in pairs(tabButtons) do
        local active = tabName == name
        TweenService:Create(parts.button, TWEEN_FAST, {
            BackgroundTransparency = active and 0 or 1
        }):Play()
        TweenService:Create(parts.label, TWEEN_FAST, {
            TextColor3 = active and Colors.TextWhite or Colors.TextMuted
        }):Play()
        TweenService:Create(tabIndicators[tabName], TWEEN_MED, {
            Size = active and UDim2.new(0, 3, 0, 22) or UDim2.new(0, 3, 0, 0)
        }):Play()
    end
    currentTab = name
end

-- =============================================================================
-- REUSABLE UI ELEMENTS
-- =============================================================================
local function addButton(page, text, order, callback)
    local btn = Instance.new("TextButton", page)
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Colors.CardBg
    btn.Text = text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextColor3 = Colors.TextMuted
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local hoverLine = Instance.new("Frame", btn)
    hoverLine.Size = UDim2.new(0, 3, 0, 0)
    hoverLine.Position = UDim2.new(0, 0, 0.5, 0)
    hoverLine.AnchorPoint = Vector2.new(0, 0.5)
    hoverLine.BackgroundColor3 = Colors.Accent
    hoverLine.BorderSizePixel = 0
    Instance.new("UICorner", hoverLine).CornerRadius = UDim.new(1, 0)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = Colors.CardBgHover, TextColor3 = Colors.TextWhite}):Play()
        TweenService:Create(hoverLine, TWEEN_FAST, {Size = UDim2.new(0, 3, 0, 24)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = Colors.CardBg, TextColor3 = Colors.TextMuted}):Play()
        TweenService:Create(hoverLine, TWEEN_FAST, {Size = UDim2.new(0, 3, 0, 0)}):Play()
    end)
    if callback then
        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = Colors.AccentDim}):Play()
            task.delay(0.08, function()
                TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = Colors.CardBgHover}):Play()
            end)
            callback()
        end)
    end
    return btn
end

local function addToggle(page, text, order, default, callback)
    local holder = Instance.new("Frame", page)
    holder.LayoutOrder = order
    holder.Size = UDim2.new(1, 0, 0, 42)
    holder.BackgroundColor3 = Colors.CardBg
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)

    local hoverLine = Instance.new("Frame", holder)
    hoverLine.Size = UDim2.new(0, 3, 0, 0)
    hoverLine.Position = UDim2.new(0, 0, 0.5, 0)
    hoverLine.AnchorPoint = Vector2.new(0, 0.5)
    hoverLine.BackgroundColor3 = Colors.Accent
    hoverLine.BorderSizePixel = 0
    Instance.new("UICorner", hoverLine).CornerRadius = UDim.new(1, 0)

    local label = Instance.new("TextLabel", holder)
label.Size = UDim2.new(1, -70, 1, 0)
label.Position = UDim2.new(0, 14, 0, 0)
label.BackgroundTransparency = 1
label.Text = text
label.Font = Enum.Font.GothamMedium
label.TextSize = 14
label.TextColor3 = Colors.TextMuted
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextTruncate = Enum.TextTruncate.AtEnd -- FIX: keeps long labels from running into the switch when the toggle shrinks
label.ClipsDescendants = true -- FIX: hard-clip so text never paints over the switchBg/knob
    local switchBg = Instance.new("Frame", holder)
    switchBg.Size = UDim2.new(0, 42, 0, 22)
    switchBg.Position = UDim2.new(1, -56, 0.5, -11)
    switchBg.BackgroundColor3 = Colors.Separator
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", switchBg)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Colors.TextWhite
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default or false
    local clickArea = Instance.new("TextButton", holder)
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""

    local function render()
        TweenService:Create(switchBg, TWEEN_FAST, {
            BackgroundColor3 = state and Colors.Accent or Colors.Separator
        }):Play()
        TweenService:Create(knob, TWEEN_FAST, {
            Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        }):Play()
    end
    render()

    holder.MouseEnter:Connect(function()
        TweenService:Create(holder, TWEEN_FAST, {BackgroundColor3 = Colors.CardBgHover}):Play()
        TweenService:Create(hoverLine, TWEEN_FAST, {Size = UDim2.new(0, 3, 0, 24)}):Play()
        TweenService:Create(label, TWEEN_FAST, {TextColor3 = Colors.TextWhite}):Play()
    end)
    holder.MouseLeave:Connect(function()
        TweenService:Create(holder, TWEEN_FAST, {BackgroundColor3 = Colors.CardBg}):Play()
        TweenService:Create(hoverLine, TWEEN_FAST, {Size = UDim2.new(0, 3, 0, 0)}):Play()
        TweenService:Create(label, TWEEN_FAST, {TextColor3 = Colors.TextMuted}):Play()
    end)

    clickArea.MouseButton1Click:Connect(function()
        state = not state
        render()
        if callback then callback(state) end
    end)

    return holder
end

local function addSectionLabel(page, text, order)
    local lbl = Instance.new("TextLabel", page)
    lbl.LayoutOrder = order
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextColor3 = Colors.TextDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd -- FIX: cuts text off with "..." instead of overflowing past the box when narrow
    lbl.ClipsDescendants = true -- FIX: extra safety so any overflow is hard-clipped, never drawn over neighbors
    return lbl
end

local function addStatCard(page, title, value, order)
    local card = Instance.new("Frame", page)
    card.LayoutOrder = order
    card.Size = UDim2.new(1, 0, 0, 58)
    card.BackgroundColor3 = Colors.CardBg
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local topLine = Instance.new("Frame", card)
    topLine.Size = UDim2.new(0, 0, 0, 2)
    topLine.Position = UDim2.new(0, 0, 0, 0)
    topLine.BackgroundColor3 = Colors.Accent
    topLine.BorderSizePixel = 0
    Instance.new("UICorner", topLine).CornerRadius = UDim.new(1, 0)
    TweenService:Create(topLine, TWEEN_SLOW, {Size = UDim2.new(1, 0, 0, 2)}):Play()

    local titleLbl = Instance.new("TextLabel", card)
    titleLbl.Size = UDim2.new(1, -20, 0, 18)
    titleLbl.Position = UDim2.new(0, 14, 0, 12)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.Font = Enum.Font.Gotham
    titleLbl.TextSize = 11
    titleLbl.TextColor3 = Colors.TextDim
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local valueLbl = Instance.new("TextLabel", card)
    valueLbl.Size = UDim2.new(1, -20, 0, 22)
    valueLbl.Position = UDim2.new(0, 14, 0, 30)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Text = value
    valueLbl.Font = Enum.Font.GothamBold
    valueLbl.TextSize = 16
    valueLbl.TextColor3 = Colors.TextWhite
    valueLbl.TextXAlignment = Enum.TextXAlignment.Left

    return card
end

local function addDropdown(page, text, order, options, callback)
    local isExpanded = false
    local baseHeight = 42
    local expandedHeight = 150 -- Height when open
    
    local holder = Instance.new("Frame", page)
    holder.LayoutOrder = order
    holder.Size = UDim2.new(1, 0, 0, baseHeight)
    holder.BackgroundColor3 = Colors.CardBg
    holder.ClipsDescendants = true
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel", holder)
    title.Size = UDim2.new(1, -20, 0, 42)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = text
    title.Font = Enum.Font.GothamMedium
    title.TextSize = 14
    title.TextColor3 = Colors.TextMuted
    title.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton", holder)
    toggleBtn.Size = UDim2.new(0, 120, 0, 26)
    toggleBtn.Position = UDim2.new(1, -130, 0, 8)
    toggleBtn.BackgroundColor3 = Colors.Background
    toggleBtn.Text = "Select..."
    toggleBtn.Font = Enum.Font.Gotham
    toggleBtn.TextSize = 12
    toggleBtn.TextColor3 = Colors.TextWhite
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

    -- Scrolling container for options
    local listContainer = Instance.new("ScrollingFrame", holder)
    listContainer.Size = UDim2.new(1, -20, 0, 100)
    listContainer.Position = UDim2.new(0, 10, 0, 45)
    listContainer.BackgroundTransparency = 1
    listContainer.ScrollBarThickness = 4
    local listLayout = Instance.new("UIListLayout", listContainer)
    listLayout.Padding = UDim.new(0, 4)

    -- Populate options
    for _, option in ipairs(options) do
        local btn = Instance.new("TextButton", listContainer)
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Colors.Background
        btn.Text = option
        btn.TextColor3 = Colors.TextWhite
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            toggleBtn.Text = option
            callback(option)
            -- Collapse
            isExpanded = false
            TweenService:Create(holder, TWEEN_MED, {Size = UDim2.new(1, 0, 0, baseHeight)}):Play()
        end)
    end
    listContainer.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)

    -- Expand/Collapse logic
    toggleBtn.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        local targetSize = isExpanded and UDim2.new(1, 0, 0, expandedHeight) or UDim2.new(1, 0, 0, baseHeight)
        TweenService:Create(holder, TWEEN_MED, {Size = targetSize}):Play()
    end)
    
    return holder
end

-- =============================================================================
-- WALK SPEED SLIDER LOGIC
-- =============================================================================
local function addWalkSpeedSlider(page, order)
    local DEFAULT_SPEED = 16
    local MAX_SPEED = 100
    
    local sliderBg = Instance.new("Frame", page)
    sliderBg.Name = "SpeedSlider"
    sliderBg.LayoutOrder = order
    sliderBg.Size = UDim2.new(1, 0, 0, 50)
    sliderBg.BackgroundColor3 = Colors.CardBg
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", sliderBg)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 14, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = "Walk Speed: 16"
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextColor3 = Colors.TextWhite
    label.TextXAlignment = Enum.TextXAlignment.Left

    local bar = Instance.new("Frame", sliderBg)
    bar.Size = UDim2.new(1, -28, 0, 4)
    bar.Position = UDim2.new(0, 14, 0, 35)
    bar.BackgroundColor3 = Colors.Separator
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((DEFAULT_SPEED / MAX_SPEED), 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton", bar)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local function updateSpeed(input)
        local relativeX = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local newSpeed = math.floor(relativeX * MAX_SPEED)
        if newSpeed < 1 then newSpeed = 1 end
        
        fill.Size = UDim2.new(relativeX, 0, 1, 0)
        label.Text = "Walk Speed: " .. newSpeed
        
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = newSpeed
        end
    end

    btn.MouseButton1Down:Connect(function()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                updateSpeed({Position = UserInputService:GetMouseLocation()})
            else
                conn:Disconnect()
            end
        end)
    end)
end

local TeleportUtils = {}

-- Teleport to specific XYZ coordinates
function TeleportUtils.TeleportTo(x, y, z)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        -- CFrame.new(x, y, z)
        hrp.CFrame = CFrame.new(x, y, z)
    end
end

-- Specific function for your Shop
function TeleportUtils.ToLobby()
    TeleportUtils.TeleportTo(-27.62, 7.79, 146.20)
end
function TeleportUtils.ToWin()
    TeleportUtils.TeleportTo(-27.32, 7.79, 64.33) -- -27.32, 7.79, 64.33
end
function TeleportUtils.ToStep1()
    TeleportUtils.TeleportTo(-28.10, 1.11, 177.05) -- -28.10, 1.11, 177.05
end
function TeleportUtils.ToStep3()
    TeleportUtils.TeleportTo(-27.62, 7.79, 146.20) -- -51.72, -0.25, 157.33
end



local GameLogic = GameLogic or {}

function GameLogic.ForceStats(enabled)
    if enabled then
        if GameLogic.StatConnection then return end -- avoid double connections
        GameLogic.StatConnection = RunService.Stepped:Connect(function()
            local char = Player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 40
                hum.JumpPower = 50
            end
        end)
    else
        if GameLogic.StatConnection then
            GameLogic.StatConnection:Disconnect()
            GameLogic.StatConnection = nil
        end
    end
end

function handleEquipBook(state)
    if state then
        local bookName = Player:GetAttribute("EquippedBook")
        if bookName then
            game:GetService("ReplicatedStorage").Remotes.Training.EquipBook:FireServer(bookName)
            print("Successfully equipped: " .. tostring(bookName))
            GameLogic.ForceStats(true) -- actually turn it on
        else
            warn("The Attribute 'EquippedBook' was not found on the player!")
        end
    else
        game:GetService("ReplicatedStorage").Remotes.Training.UnequipBook:FireServer()
        GameLogic.ForceStats(false)
        print("Book unequipped.")
    end
end

function ToggleAutoTap2x(state)
    Player:SetAttribute("GP_AutoX2", state)
end
function TogglePerfectBlast(state)
    Player:SetAttribute("GP_AutoPerfect", state)
end

local Workspace = game:GetService("Workspace")

local targetZombies = {
    "BasketZombie", "BigZombie", "BossZombie", "CircusZombie", 
    "ElectricZombie", "FireFighterZombie", "GreekZombie", "IceZombie", 
    "InfernalZombie", "MagmaZombie", "MeteorZombie", "NinjaZombie", 
    "PoliceZombie", "ToxicZombie", "ZombiGiant", "Zombie", "ZombieMiner"
}

task.spawn(function()
    while true do
        task.wait(0.2)
        for _, obj in ipairs(Workspace:GetChildren()) do
            for _, zombieName in ipairs(targetZombies) do
                if obj.Name == zombieName then
                    pcall(function()
                    	task.wait(3)
                        obj:Destroy()
                    end)
                end
            end
        end
    end
end)
-- =============================================================================
-- AUTOMATION & CONTROLLERS (Separate Walk Speed & Chase Speed)
-- =============================================================================
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local ChaseSpeedController = {
    Speed = 500, -- Default high physics speed for chase
    Thread = nil
}

function ChaseSpeedController:Toggle(state)
    _G.autoAllEnabled = state
    local StarterGui = game:GetService("StarterGui")

    if _G.autoAllEnabled then
        pcall(function() TeleportUtils.ToLobby() end)
        
        self.Thread = task.spawn(function()
            local hud = player:WaitForChild("PlayerGui"):WaitForChild("HUD", 10)
            local wasInChase = false
            
            while _G.autoAllEnabled do
                -- 1. BlastButton Clicker
                if hud then
                    local blastFrame = hud:FindFirstChild("BlastFrame")
                    local blastButton = blastFrame and blastFrame:FindFirstChild("BlastButton")
                    
                    if blastButton and blastButton.Visible then
                        local guiService = game:GetService("GuiService")
                        local inset = guiService:GetGuiInset()
                        local cx = blastButton.AbsolutePosition.X + (blastButton.AbsoluteSize.X / 2) + inset.X
                        local cy = blastButton.AbsolutePosition.Y + (blastButton.AbsoluteSize.Y / 2) + inset.Y
                        
                        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                        task.wait(0.02)
                        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
                    end
                end
                
                -- 2. DropOpen Handler
                if player:GetAttribute("DropOpen") == false then
                    player:SetAttribute("DropOpen", true)
                end

                if player:GetAttribute("DropOpen") == true and _G.autoAllEnabled then
                    local camera = Workspace.CurrentCamera
                    if camera then
                        local vp = camera.ViewportSize
                        VirtualInputManager:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, false, game, 1)
                    end
                end

                -- 3. Chase Handling & Auto-Run using Chase Speed
                local currentInChase = (player:GetAttribute("InChase") == true)
                
                if currentInChase and not wasInChase then
                    wasInChase = true
                    
                    local character = player.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    
                    if rootPart then
                        local moveConnection
                        moveConnection = RunService.RenderStepped:Connect(function()
                            if not _G.autoAllEnabled or not character or not rootPart or rootPart.Parent == nil or player:GetAttribute("InChase") ~= true then
                                if moveConnection then
                                    moveConnection:Disconnect()
                                end
                                return
                            end
                            
                            local lookVector = rootPart.CFrame.LookVector
                            local targetVelocity = lookVector * ChaseSpeedController.Speed
                            rootPart.AssemblyLinearVelocity = Vector3.new(targetVelocity.X, rootPart.AssemblyLinearVelocity.Y, targetVelocity.Z)
                        end)
                        
                        while _G.autoAllEnabled and player:GetAttribute("InChase") == true and character.Parent do
                            task.wait(0.1)
                            local Event = game:GetService("ReplicatedStorage").Remotes.Zombie.ZombieResult
                            pcall(function()
                                firesignal(Event.OnClientEvent, true)
                            end)
                        end
                        
                        if moveConnection then
                            moveConnection:Disconnect()
                        end
                    end
                end
                
                if wasInChase and not currentInChase then
                    task.wait(8)
                    wasInChase = false
                    pcall(function()
                        TeleportUtils.ToLobby()
                        TeleportUtils.ToWin()
                        TeleportUtils.ToLobby()
                    end)
                end
                
                task.wait(0.1)
            end
        end)
    else
        _G.autoAllEnabled = false
        if self.Thread then
            task.cancel(self.Thread)
            self.Thread = nil
        end
    end
end

-- =============================================================================
-- 2. CHASE SPEED SLIDER (Controls Active Physics Chase Speed)
-- =============================================================================
local function addChaseSpeedSlider(page, order)
    local DEFAULT_SPEED = 500
    local MAX_SPEED = 1000
    
    local sliderBg = Instance.new("Frame", page)
    sliderBg.Name = "ChaseSpeedSlider"
    sliderBg.LayoutOrder = order
    sliderBg.Size = UDim2.new(1, 0, 0, 50)
    sliderBg.BackgroundColor3 = Colors.CardBg
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", sliderBg)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 14, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = "Chase Speed: " .. DEFAULT_SPEED
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextColor3 = Colors.TextWhite
    label.TextXAlignment = Enum.TextXAlignment.Left

    local bar = Instance.new("Frame", sliderBg)
    bar.Size = UDim2.new(1, -28, 0, 4)
    bar.Position = UDim2.new(0, 14, 0, 35)
    bar.BackgroundColor3 = Colors.Separator
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((DEFAULT_SPEED / MAX_SPEED), 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton", bar)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local function updateSpeed(input)
        local relativeX = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local newSpeed = math.floor(relativeX * MAX_SPEED)
        if newSpeed < 10 then newSpeed = 10 end
        
        fill.Size = UDim2.new(relativeX, 0, 1, 0)
        label.Text = "Chase Speed: " .. newSpeed
        
        ChaseSpeedController.Speed = newSpeed
    end

    btn.MouseButton1Down:Connect(function()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                updateSpeed({Position = UserInputService:GetMouseLocation()})
            else
                conn:Disconnect()
            end
        end)
    end)
end

local function toggleAutoRebirth(state)
    _G.autoRebirthEnabled = state
    if _G.autoRebirthEnabled then
        task.spawn(function()
            local Event = game:GetService("ReplicatedStorage").Remotes.Rebirth.DoRebirth
            while _G.autoRebirthEnabled do
                Event:FireServer()
                task.wait(1) -- Delay between rebirth attempts to prevent rate-limiting
            end
        end)
    end
end

local function toggleAutoUpgradeBase(state)
    _G.autoUpgradeBaseEnabled = state
    if _G.autoUpgradeBaseEnabled then
        task.spawn(function()
            local Event = game:GetService("ReplicatedStorage").Remotes.Bases.BuyBaseUpgrade
            while _G.autoUpgradeBaseEnabled do
                Event:FireServer()
                task.wait(0.5) -- Delay between upgrade attempts to prevent rate-limiting
            end
        end)
    end
end

local function toggleAutoBuySpeed(state)
    _G.autoBuySpeedEnabled = state
    if _G.autoBuySpeedEnabled then
        task.spawn(function()
            local Event = game:GetService("ReplicatedStorage").Remotes.Shops.BuySpeed
            while _G.autoBuySpeedEnabled do
                Event:FireServer(1)
                task.wait(0.2) -- Delay between purchase attempts to prevent rate-limiting
            end
        end)
    end
end

local function toggleAutoClaimPass(state)
    _G.autoClaimPassEnabled = state
    if _G.autoClaimPassEnabled then
        task.spawn(function()
            local Event = game:GetService("ReplicatedStorage").Remotes.SummerPass.Claim
            while _G.autoClaimPassEnabled do
                for i = 1, 30 do
                    if not _G.autoClaimPassEnabled then break end
                    Event:FireServer(i, "free")
                    task.wait(0.1) -- Small delay between each claim request
                end
                task.wait(2) -- Delay before looping through all numbers again
            end
        end)
    end
end

local function toggleAutoSellAll(state)
    _G.autoSellAllEnabled = state
    if _G.autoSellAllEnabled then
        task.spawn(function()
            local Event = game:GetService("ReplicatedStorage").Remotes.Shops.SellAll
            while _G.autoSellAllEnabled do
                Event:FireServer()
                task.wait(1) -- Delay between sell attempts to prevent rate-limiting
            end
        end)
    end
end

local function toggleAutoClaimPlaytime(state)
    _G.autoClaimPlaytimeEnabled = state
    if _G.autoClaimPlaytimeEnabled then
        task.spawn(function()
            local Event = game:GetService("ReplicatedStorage").Remotes.Rewards.ClaimPlaytime
            while _G.autoClaimPlaytimeEnabled do
                for i = 1, 12 do
                    if not _G.autoClaimPlaytimeEnabled then break end
                    Event:FireServer(i)
                    task.wait(0.2) -- Small delay between each claim request
                end
                task.wait(2) -- Delay before checking the sequence again
            end
        end)
    end
end

-- =============================================================================
-- FLY LOGIC
-- =============================================================================
local flyEnabled = false
local flyVelocity = nil
local flyGyro = nil
local flySpeed = 50

local function setFly(enabled)
    flyEnabled = enabled
    local character = Player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if flyEnabled then
        if not hrp then return end
        
        -- Create Velocity to push player
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyVelocity.Parent = hrp
        
        -- Create Gyro to keep player upright/facing forward
        flyGyro = Instance.new("BodyGyro")
        flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyGyro.P = 10000
        flyGyro.D = 100
        flyGyro.CFrame = hrp.CFrame
        flyGyro.Parent = hrp

        -- Fly Loop
        task.spawn(function()
            while flyEnabled and character and hrp do
                local cameraCFrame = workspace.CurrentCamera.CFrame
                local moveDir = Vector3.new(0, 0, 0)
                
                -- Check input direction
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cameraCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cameraCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cameraCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cameraCFrame.RightVector end
                
                flyVelocity.Velocity = moveDir * flySpeed
                flyGyro.CFrame = cameraCFrame
                task.wait()
            end
        end)
    else
        -- Clean up
        if flyVelocity then flyVelocity:Destroy() end
        if flyGyro then flyGyro:Destroy() end
    end
end



-- =============================================================================
-- NOCLIP LOGIC
-- =============================================================================
local noclipEnabled = false
local noclipConnection

local function setNoclip(enabled)
    noclipEnabled = enabled
    
    if noclipEnabled then
        -- Start loop to constantly set CanCollide to false
        noclipConnection = RunService.Stepped:Connect(function()
            local character = Player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        -- Stop loop
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end




-- =============================================================================
-- ANTI-AFK CONTROLLER & GUI (10 Taps Every 1 Minute)
-- =============================================================================
local AntiAFKController = {
    Enabled = false,
    Thread = nil
}

function AntiAFKController:Toggle(state)
    self.Enabled = state
    local StarterGui = game:GetService("StarterGui")
    local player = game:GetService("Players").LocalPlayer
    local vim = pcall(function() return game:GetService("VirtualInputManager") end) and game:GetService("VirtualInputManager") or nil

    if self.Enabled then
        self.Thread = task.spawn(function()
            while AntiAFKController.Enabled do
                pcall(function()
                    local viewportSize = workspace.CurrentCamera.ViewportSize
                    local cx, cy = viewportSize.X / 2, viewportSize.Y / 2
                    
                    -- Tap/Click 10 times rapidly
                    for i = 1, 10 do
                        if not AntiAFKController.Enabled then break end
                        
                        if vim then
                            vim:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
                            task.wait(0.05)
                            vim:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
                        else
                            local VirtualUser = game:GetService("VirtualUser")
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton1(Vector2.new(cx, cy))
                        end
                        
                        task.wait(0.2) -- short delay between the 10 clicks
                    end

                    -- Small jump nudge to ensure Roblox registers activity
                    local char = player.Character
                    if char then
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid.Jump = true
                        end
                    end
                end)
                
                -- Wait 60 seconds (1 minute) before the next 10-tap sequence
                task.wait(60)
            end
        end)

        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Anti AFK",
                Text = "Anti AFK Enabled (10 Clicks / 1m)",
                Duration = 3
            })
        end)
    else
        if self.Thread then
            task.cancel(self.Thread)
            self.Thread = nil
        end

        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Anti AFK",
                Text = "Anti AFK Disabled",
                Duration = 3
            })
        end)
    end
end

-- =============================================================================
-- AUTO TELEPORT TO TRAINING ZONE WITH RETURN CONTROLLER
-- =============================================================================
local AutoTrainingTeleport = {
    Enabled = false,
    WasInZone = false,
    ReturnPosition = Vector3.new(-27.62, 7.79, 146.20)
}

function AutoTrainingTeleport:Toggle(state)
    self.Enabled = state
    if not state then
        self.WasInZone = false
    end
end

task.spawn(function()
    while true do
        if AutoTrainingTeleport.Enabled then
            pcall(function()
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                
                if humanoidRootPart then
                    local zoneNames = {"X3TrainingZone", "X2TrainingZone", "X1.5TrainingZone"}
                    local foundZone = nil
                    
                    for _, zoneName in ipairs(zoneNames) do
                        local zone = workspace:FindFirstChild(zoneName, true)
                        if zone then
                            foundZone = zone
                            break
                        end
                    end
                    
                    if foundZone then
                        -- Mark that we are currently/recently in a training zone
                        AutoTrainingTeleport.WasInZone = true
                        
                        local targetCFrame
                        if foundZone:IsA("BasePart") then
                            targetCFrame = foundZone.CFrame + Vector3.new(0, 3, 0)
                        elseif foundZone:IsA("Model") then
                            local primary = foundZone.PrimaryPart or foundZone:FindFirstChildWhichIsA("BasePart")
                            if primary then
                                targetCFrame = primary.CFrame + Vector3.new(0, 3, 0)
                            end
                        end
                        
                        if targetCFrame then
                            humanoidRootPart.CFrame = targetCFrame
                        end
                    else
                        -- If the zone was previously there, but now it disappeared, teleport back once
                        if AutoTrainingTeleport.WasInZone then
                            AutoTrainingTeleport.WasInZone = false
                            humanoidRootPart.CFrame = CFrame.new(AutoTrainingTeleport.ReturnPosition)
			    humanoidRootPart.CFrame = CFrame.new(AutoTrainingTeleport.ReturnPosition)
			    humanoidRootPart.CFrame = CFrame.new(AutoTrainingTeleport.ReturnPosition)
			    humanoidRootPart.CFrame = CFrame.new(AutoTrainingTeleport.ReturnPosition)
			    humanoidRootPart.CFrame = CFrame.new(AutoTrainingTeleport.ReturnPosition)
			    humanoidRootPart.CFrame = CFrame.new(AutoTrainingTeleport.ReturnPosition)
                            humanoidRootPart.CFrame = CFrame.new(AutoTrainingTeleport.ReturnPosition)
			    humanoidRootPart.CFrame = CFrame.new(AutoTrainingTeleport.ReturnPosition)
			    humanoidRootPart.CFrame = CFrame.new(AutoTrainingTeleport.ReturnPosition)
			    humanoidRootPart.CFrame = CFrame.new(AutoTrainingTeleport.ReturnPosition)
			    humanoidRootPart.CFrame = CFrame.new(AutoTrainingTeleport.ReturnPosition)
			    humanoidRootPart.CFrame = CFrame.new(AutoTrainingTeleport.ReturnPosition)
                        end
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

-- =============================================================================
-- AFK MODE CONTROLLER & GUI (Updated: Case -> Cash)
-- =============================================================================
local AFKController = {
    Enabled = false,
    ScreenGui = nil,
    Connection = nil
}

function AFKController:Toggle(state)
    self.Enabled = state
    
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    if self.Enabled then
        -- 1. Create Black Screen UI
        if not self.ScreenGui then
            self.ScreenGui = Instance.new("ScreenGui")
            self.ScreenGui.Name = "AFKModeScreen"
            self.ScreenGui.IgnoreGuiInset = true
            self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            self.ScreenGui.ResetOnSpawn = false
            
            -- Background
            local bg = Instance.new("Frame")
            bg.Name = "Background"
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            bg.BorderSizePixel = 0
            bg.Parent = self.ScreenGui
            
            -- Stats Container
            local container = Instance.new("Frame")
            container.Name = "Container"
            container.Size = UDim2.new(0, 400, 0, 250)
            container.AnchorPoint = Vector2.new(0.5, 0.5)
            container.Position = UDim2.new(0.5, 0, 0.5, -30)
            container.BackgroundTransparency = 1
            container.Parent = bg
            
            local layout = Instance.new("UIListLayout")
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            layout.VerticalAlignment = Enum.VerticalAlignment.Center
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 15)
            layout.Parent = container
            
            -- Title Label
            local title = Instance.new("TextLabel")
            title.Name = "Title"
            title.Size = UDim2.new(1, 0, 0, 40)
            title.BackgroundTransparency = 1
            title.Text = "🌙 AFK MODE ENGAGED"
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.TextScaled = true
            title.Font = Enum.Font.GothamBold
            title.LayoutOrder = 1
            title.Parent = container
            
            -- Stats Label
            local statsLabel = Instance.new("TextLabel")
            statsLabel.Name = "StatsLabel"
            statsLabel.Size = UDim2.new(1, 0, 0, 90)
            statsLabel.BackgroundTransparency = 1
            statsLabel.Text = "Loading Stats..."
            statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            statsLabel.TextScaled = true
            statsLabel.Font = Enum.Font.Gotham
            statsLabel.LayoutOrder = 2
            statsLabel.Parent = container
            
            -- Exit Button
            local exitBtn = Instance.new("TextButton")
            exitBtn.Name = "ExitButton"
            exitBtn.Size = UDim2.new(0, 200, 0, 45)
            exitBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            exitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            exitBtn.Text = "Exit AFK Mode"
            exitBtn.TextSize = 16
            exitBtn.Font = Enum.Font.GothamBold
            exitBtn.LayoutOrder = 3
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = exitBtn
            
            exitBtn.MouseButton1Click:Connect(function()
                AFKController:Toggle(false)
            end)
            
            exitBtn.Parent = container
            self.ScreenGui.Parent = playerGui
        else
            self.ScreenGui.Enabled = true
        end
        
        -- 2. Lower Rendering/Lag reduction settings
        pcall(function()
            game:GetService("RunService"):Set3dRenderingEnabled(false)
        end)
        
        -- 3. Live stat updater loop (using Cash instead of Case)
        local statsLabelRef = self.ScreenGui.Background.Container.StatsLabel
        local leaderstats = player:WaitForChild("leaderstats", 2)
        
        self.Connection = game:GetService("RunService").RenderStepped:Connect(function()
            if not self.Enabled then return end
            
            local bp = leaderstats and leaderstats:FindFirstChild("BrainPower") and leaderstats.BrainPower.Value or "N/A"
            local cashVal = leaderstats and leaderstats:FindFirstChild("Cash") and leaderstats.Cash.Value or "N/A"
            local rebirths = leaderstats and leaderstats:FindFirstChild("Rebirths") and leaderstats.Rebirths.Value or "N/A"
            
            statsLabelRef.Text = string.format("BrainPower: %s\nCash: %s\nRebirths: %s", tostring(bp), tostring(cashVal), tostring(rebirths))
        end)
        
    else
        -- Clean up & Restore
        if self.Connection then
            self.Connection:Disconnect()
            self.Connection = nil
        end
        
        if self.ScreenGui then
            self.ScreenGui.Enabled = false
        end
        
        pcall(function()
            game:GetService("RunService"):Set3dRenderingEnabled(true)
        end)
    end
end


-- =============================================================================
-- AUTO BUY LUCKY BLOCK CONTROLLER
-- =============================================================================
local AutoBuyLuckyBlock = {
    Enabled = false
}

function AutoBuyLuckyBlock:Toggle(state)
    self.Enabled = state
end

task.spawn(function()
    while true do
        if AutoBuyLuckyBlock.Enabled then
            pcall(function()
                local args = {
                    1
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Meteors"):WaitForChild("BuyLuckyBlock"):InvokeServer(unpack(args))
            end)
        end
        task.wait(0.5)
    end
end)

function ToggleX2MutationLuck(state)
    Player:SetAttribute("GP_X2MutationLuck", state)
end
function ToggleLuck(state)
    Player:SetAttribute("GP_X2Luck", state)
end
function ToggleLuck(state)
    Player:SetAttribute("GP_X2Luck", state)
end
function ToggleBlast(state)
    Player:SetAttribute("GP_X2BlastPower", state)
end

local function addDropdown(page, text, options, order, callback)
    local selected = options[1]
    local isOpen = false
    local MAX_LIST_HEIGHT = 120
    
    -- Helper to format the display text
    local function formatText(val)
        if type(val) == "number" then
            return "Stage " .. (val + 1)
        else
            return tostring(val)
        end
    end
    
    local container = Instance.new("Frame", page)
    container.LayoutOrder = order
    container.Size = UDim2.new(1, 0, 0, 42)
    container.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Colors.CardBg
    btn.Text = text .. ": " .. formatText(selected) -- Use helper
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextColor3 = Colors.TextMuted
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local spacer = Instance.new("Frame", page)
    spacer.LayoutOrder = order + 1
    spacer.Size = UDim2.new(1, 0, 0, 0)
    spacer.BackgroundTransparency = 1
    spacer.ClipsDescendants = true
    
    local list = Instance.new("ScrollingFrame", spacer)
    list.Size = UDim2.new(1, 0, 0, 0)
    list.BackgroundColor3 = Colors.CardBg
    list.ScrollBarThickness = 4
    list.BorderSizePixel = 0
    list.CanvasSize = UDim2.new(0, 0, 0, #options * 32)
    Instance.new("UICorner", list).CornerRadius = UDim.new(0, 8)
    local uiList = Instance.new("UIListLayout", list)
    uiList.Padding = UDim.new(0, 2)
    
    btn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local targetSize = isOpen and UDim2.new(1, 0, 0, MAX_LIST_HEIGHT) or UDim2.new(1, 0, 0, 0)
        TweenService:Create(spacer, TWEEN_FAST, {Size = targetSize}):Play()
        TweenService:Create(list, TWEEN_FAST, {Size = targetSize}):Play()
    end)
    
    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton", list)
        optBtn.Size = UDim2.new(1, -4, 0, 30)
        optBtn.BackgroundColor3 = Colors.CardBgHover
        optBtn.Text = formatText(opt) -- Use helper
        optBtn.TextColor3 = Colors.TextWhite
        optBtn.Font = Enum.Font.Gotham
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            btn.Text = text .. ": " .. formatText(selected)
            isOpen = false
            TweenService:Create(spacer, TWEEN_FAST, {Size = UDim2.new(1, 0, 0, 0)}):Play()
            TweenService:Create(list, TWEEN_FAST, {Size = UDim2.new(1, 0, 0, 0)}):Play()
            callback(selected)
        end)
    end
end

-- =============================================================================
-- BOOK BUYER CONTROLLER
-- =============================================================================
local BookController = {
    Enabled = false,
    SelectedBook = "Book" -- Default choice
}

local BookEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shops"):WaitForChild("BuyBook")

function BookController:Toggle(state)
    self.Enabled = state
end

function BookController:SetBook(bookName)
    self.SelectedBook = bookName
end

-- Heartbeat loop with rate-limiting (0.5s delay) to prevent spamming the server
RunService.Heartbeat:Connect(function()
    if BookController.Enabled then
        BookEvent:FireServer(BookController.SelectedBook)
        task.wait(0.5)
    end
end)

local function toggleAutoCollectCash(state)
    _G.autoCollectCashEnabled = state
    if _G.autoCollectCashEnabled then
        task.spawn(function()
            local Event = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Bases"):WaitForChild("CollectCash")
            while _G.autoCollectCashEnabled do
                for baseIndex = 1, 5 do
                    for cashIndex = 1, 8 do
                        if not _G.autoCollectCashEnabled then break end
                        local argString = baseIndex .. "_" .. cashIndex
                        Event:FireServer(argString)
                        task.wait(0.05) -- Fast interval to cycle through all combinations
                    end
                end
                task.wait(1) -- Delay before restarting the full sweep
            end
        end)
    end
end

local function toggleAutoPlaceBest(state)
    _G.autoPlaceBestEnabled = state
    if _G.autoPlaceBestEnabled then
        task.spawn(function()
            local Event = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Bases"):WaitForChild("PlaceBest")
            while _G.autoPlaceBestEnabled do
                Event:FireServer()
                task.wait(10) -- Delay between attempts to prevent rate-limiting
            end
        end)
    end
end

-- =============================================================================
-- AUTO UPGRADE BRAINROT CONTROLLER (Loop All)
-- =============================================================================
local AutoUpgradeBrainrot = {
    Enabled = false
}

function AutoUpgradeBrainrot:Toggle(state)
    self.Enabled = state
end

task.spawn(function()
    while true do
        if AutoUpgradeBrainrot.Enabled then
            pcall(function()
                -- Loop through categories 1 to 3 and tiers 1 to 24
                for cat = 1, 4 do
                    for tier = 1, 32 do
                        if not AutoUpgradeBrainrot.Enabled then break end
                        
                        local args = {
                            cat .. "_" .. tier
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Bases"):WaitForChild("UpgradeBrainrot"):FireServer(unpack(args))
                        task.wait(0.05) -- Small delay between each remote call to prevent lagging/kicking
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- =============================================================================
-- AUTO BUY AURA CONTROLLER
-- =============================================================================
local AutoBuyAura = {
    Enabled = false,
    SelectedAura = "WaterAura"
}

function AutoBuyAura:Toggle(state)
    self.Enabled = state
end

function AutoBuyAura:SetAura(auraName)
    self.SelectedAura = auraName
end

task.spawn(function()
    while true do
        if AutoBuyAura.Enabled then
            pcall(function()
                local args = {
                    AutoBuyAura.SelectedAura
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Auras"):WaitForChild("BuyAura"):FireServer(unpack(args))
            end)
        end
        task.wait(0.5)
    end
end)

-- =============================================================================
-- AUTO METEOR UPGRADE CONTROLLER
-- =============================================================================
local AutoMeteorUpgrade = {
    Enabled = false,
    SelectedUpgrade = "MoreSpawns"
}

function AutoMeteorUpgrade:Toggle(state)
    self.Enabled = state
end

function AutoMeteorUpgrade:SetUpgrade(upgradeName)
    self.SelectedUpgrade = upgradeName
end

task.spawn(function()
    while true do
        if AutoMeteorUpgrade.Enabled then
            pcall(function()
                local args = {
                    AutoMeteorUpgrade.SelectedUpgrade
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Meteors"):WaitForChild("BuyUpgrade"):InvokeServer(unpack(args))
            end)
        end
        task.wait(0.5)
    end
end)



-- =============================================================================
-- BUILD PAGES / TABS
-- =============================================================================
createTabButton("Dashboard", 1)
createTabButton("Auto", 2)
createTabButton("Settings", 3)

local dashLeft, dashRight = createPage("Dashboard")
local autoLeft, autoRight = createPage("Auto")
local settingsLeft, settingsRight = createPage("Settings")

-- ===== Dashboard: LEFT column =====
-- Box 1: overview / status content
local dashOverviewBox = addBox(dashLeft, 1)
addSectionLabel(dashOverviewBox, "OVERVIEW", 1)
addStatCard(dashOverviewBox, "STATUS", "Online", 2)
addSectionLabel(dashOverviewBox, "ACTIONS",4)
addToggle(dashOverviewBox, "Fly Mode", 6, false, function(state)
    setFly(state)
end)
addToggle(dashOverviewBox, "Noclip (Pass Walls)", 7, false, function(state)
    setNoclip(state)
end)
addButton(dashOverviewBox, "Lobby", 265, function()
    TeleportUtils.ToStep1()

end)



local dashActionsBoxR = addBox(dashRight, 1)
addSectionLabel(dashActionsBoxR, "MISC",2)
addToggle(dashActionsBoxR, "2x Luck", 2, false, function(state)
   ToggleLuck(state)
end)
addToggle(dashActionsBoxR, "2x Mutation Luck", 3, false, function(state)
   ToggleX2MutationLuck(state)
end)
addToggle(dashActionsBoxR, "2x Blast Power", 4, false, function(state)
   ToggleBlast(state)
end)
addToggle(dashActionsBoxR, "Auto Claim Playtime", 5, false, function(state)
    toggleAutoClaimPlaytime(state)
end)
addToggle(dashActionsBoxR, "Auto Claim Pass", 6, false, function(state)
    toggleAutoClaimPass(state)
end)


local AutoFirst = addBox(autoLeft, 1)
addSectionLabel(AutoFirst , "AUTOMATION",2)
addChaseSpeedSlider(settingsPlayer, 2)
addToggle(AutoFirst, "Auto Farm", 2, false, function(state)
	  TogglePerfectBlast(state)
    toggleAutoAll(state)
  
end)

addToggle(AutoFirst, "Auto Fast Train Brain", 4, false, function(state)
    handleEquipBook(state)
    ToggleAutoTap2x(state)
end)


addToggle(AutoFirst, "Auto TP Training Zone", 4, false, function(state)
    AutoTrainingTeleport:Toggle(state)
end)

addToggle(AutoFirst, "Auto Collect Cash", 6, false, function(state)
    toggleAutoPlaceBest(state)
end)
--addToggle(autoPage, "Auto Collect Cash V2", 7, false, function(state)
    --toggleAutoCollectCash(state)
--end)
local AutoSecond = addBox(autoLeft, 2)
addSectionLabel(AutoSecond , "UPGRADES",2)
addToggle(AutoSecond, "Auto Upgrade Brainrot", 7, false, function(state)
    AutoUpgradeBrainrot:Toggle(state)
end)
addToggle(AutoSecond, "Auto Rebirth", 8, false, function(state)
    toggleAutoRebirth(state)
end)
addToggle(AutoSecond, "Auto Upgrade Base", 9, false, function(state)
    toggleAutoUpgradeBase(state)
end)
addToggle(AutoSecond, "Auto Buy Speed", 10, false, function(state)
    toggleAutoBuySpeed(state)
end)
addToggle(AutoSecond, "Auto Sell All", 12, false, function(state)
    toggleAutoSellAll(state)
end)


local AutoFirstR = addBox(autoRight, 1)
addSectionLabel(AutoFirstR, "BOOK SHOP",2)
local bookOptions = {
    "Book", "GoldenBook", "MetalBook", "GemBook", "GhostBook", "FungiBook", 
    "WaterBook", "MagmaBook", "SolarBook", "CandyBook", "ShadoBook", 
    "AngelicBook", "EstelarBook", "ToxicBook", "BunnyBook", "CosmicBook", 
    "MagneticBook", "AdaptationBook", "DemonicBook", "DragonBook", 
    "KingBook", "ReaperBook", "StormBook"
}



-- Dropdown (LayoutOrder 51, Spacer 52)
addDropdown(AutoFirstR, "Select Book", bookOptions, 2, function(val)
    BookController:SetBook(val)
end)

-- Toggle (LayoutOrder 53)
addToggle(AutoFirstR, "Auto Buy Books", 3, false, function(state)
    BookController:Toggle(state)
end)


local auraOptions = {
    "WaterAura", "ToxicAura", "FireAura", "LightningAura", "CosmicAura", "SuperAura"
}

local AutoSecondR = addBox(autoRight, 1)
addSectionLabel(AutoSecondR, "AURA SHOP", 4)

addDropdown(AutoSecondR, "Select Aura", auraOptions, 5, function(val)
    AutoBuyAura:SetAura(val)
end)

addToggle(AutoSecondR, "Auto Buy Aura", 6, false, function(state)
    AutoBuyAura:Toggle(state)
end)

local AutoThirdR = addBox(autoRight, 1)
local meteorUpgradeOptions = {
    "MoreSpawns", "MoreMeteors", "Moredifiers", "GoldenChance", "MagnetUpgrade", "GoldenValue", "LavaTotem", "DynamicBrainrot"
}

addSectionLabel(AutoThirdR, "METEOR SHOP", 100)

addDropdown(AutoThirdR, "Select Item", meteorUpgradeOptions, 101, function(val)
    AutoMeteorUpgrade:SetUpgrade(val)
end)

addToggle(AutoThirdR, "Auto Buy", 102, false, function(state)
    AutoMeteorUpgrade:Toggle(state)
end)
addToggle(AutoThirdR, "Auto Buy Lucky Block", 106, false, function(state)
    AutoBuyLuckyBlock:Toggle(state)
end)

  


local settingsPlayer = addBox(settingsLeft, 1)
addSectionLabel(settingsPlayer, "PLAYER CONFIG", 1)
addWalkSpeedSlider(settingsPlayer, 2)
addToggle(settingsPlayer, "Anti AFK", 3, false, function(state)
    AntiAFKController:Toggle(state)
end)
-- ===== Settings: LEFT column =====
local settingsPrefsBox = addBox(settingsRight, 2)
addSectionLabel(settingsPrefsBox, "PREFERENCES", 1)
addToggle(settingsPrefsBox, "Notifications", 2, true, function(state)
    print("Notifications:", state)
end)
addToggle(settingsPrefsBox, "Sound Effects", 3, true, function(state)
    print("Sound Effects:", state)
end)

-- ===== Settings: RIGHT column =====
local settingsAboutBox = addBox(settingsRight, 1)
addSectionLabel(settingsAboutBox, "ABOUT", 1)
addStatCard(settingsAboutBox, "VERSION", "1.1.1", 2)

tabButtons["Dashboard"].button.MouseButton1Click:Connect(function() switchTab("Dashboard") end)
tabButtons["Auto"].button.MouseButton1Click:Connect(function() switchTab("Auto") end)
tabButtons["Settings"].button.MouseButton1Click:Connect(function() switchTab("Settings") end)

switchTab("Dashboard")

-- =============================================================================
-- DRAGGING (from top bar)
-- =============================================================================
local dragging = false
local dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- =============================================================================
-- RESIZE HANDLE (bottom-right corner, no minimum size)
-- =============================================================================
local ResizeGrip = Instance.new("Frame", Main)
ResizeGrip.Name = "ResizeGrip"
ResizeGrip.Size = UDim2.new(0, 18, 0, 18)
ResizeGrip.Position = UDim2.new(1, -18, 1, -18)
ResizeGrip.BackgroundTransparency = 1
ResizeGrip.ZIndex = 20

for i = 1, 3 do
    local line = Instance.new("Frame", ResizeGrip)
    line.Size = UDim2.new(0, 10 - (i * 2), 0, 2)
    line.Position = UDim2.new(1, -(10 - (i * 2)) - 2, 1, -(i * 5))
    line.Rotation = -45
    line.BackgroundColor3 = Colors.Accent
    line.BackgroundTransparency = 0.35
    line.BorderSizePixel = 0
    line.ZIndex = 21
    Instance.new("UICorner", line).CornerRadius = UDim.new(1, 0)
end

local ResizeButton = Instance.new("TextButton", ResizeGrip)
ResizeButton.Size = UDim2.new(1, 0, 1, 0)
ResizeButton.BackgroundTransparency = 1
ResizeButton.Text = ""
ResizeButton.ZIndex = 22

local resizing = false
local resizeStart, startSize

ResizeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStart = input.Position
        startSize = Main.Size
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                resizing = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - resizeStart
        -- No minimum size enforced: only guard against negative/zero so the frame doesn't invert
        local newWidth = math.max(startSize.X.Offset + delta.X, 1)
        local newHeight = math.max(startSize.Y.Offset + delta.Y, 1)
        Main.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = false
    end
end)

ResizeButton.MouseEnter:Connect(function()
    for _, line in ipairs(ResizeGrip:GetChildren()) do
        if line:IsA("Frame") then
            TweenService:Create(line, TWEEN_FAST, {BackgroundTransparency = 0}):Play()
        end
    end
end)
ResizeButton.MouseLeave:Connect(function()
    for _, line in ipairs(ResizeGrip:GetChildren()) do
        if line:IsA("Frame") then
            TweenService:Create(line, TWEEN_FAST, {BackgroundTransparency = 0.35}):Play()
        end
    end
end)

-- =============================================================================
-- FLOATING LAUNCHER (shown while minimized)
-- =============================================================================
-- Its own ScreenGui with a high DisplayOrder so it renders above the rest of
-- the interface (the closest equivalent to "always on top" inside Roblox's
-- GUI layering model, since there's no OS-level window here).
local FloatingGui = Instance.new("ScreenGui")
FloatingGui.Name = "NovaFloatingLauncher"
FloatingGui.ResetOnSpawn = false
FloatingGui.DisplayOrder = 999
FloatingGui.Enabled = false
FloatingGui.Parent = Player:WaitForChild("PlayerGui")

local FloatingFrame = Instance.new("Frame")
FloatingFrame.Name = "FloatingFrame"
FloatingFrame.Size = UDim2.new(0, 60, 0, 60)
FloatingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)-- starts near the top-right corner
FloatingFrame.BackgroundColor3 = Colors.Background
FloatingFrame.BackgroundTransparency = 0.05
FloatingFrame.BorderSizePixel = 0
FloatingFrame.Parent = FloatingGui

Instance.new("UICorner", FloatingFrame).CornerRadius = UDim.new(1, 0)

local FloatingStroke = Instance.new("UIStroke", FloatingFrame)
FloatingStroke.Color = Colors.Accent
FloatingStroke.Thickness = 1
FloatingStroke.Transparency = 0.5

-- Lightweight recreation of the splash screen's glow ring + orbiting particle
local FloatRing = Instance.new("Frame", FloatingFrame)
FloatRing.Name = "FloatRing"
FloatRing.AnchorPoint = Vector2.new(0.5, 0.5)
FloatRing.Position = UDim2.new(0.5, 0, 0.5, 0)
FloatRing.Size = UDim2.new(0, 32, 0, 32)
FloatRing.BackgroundTransparency = 1
Instance.new("UICorner", FloatRing).CornerRadius = UDim.new(1, 0)

local FloatRingStroke = Instance.new("UIStroke", FloatRing)
FloatRingStroke.Color = Colors.Accent
FloatRingStroke.Thickness = 2
FloatRingStroke.Transparency = 0.35

local FloatCore = Instance.new("Frame", FloatRing)
FloatCore.AnchorPoint = Vector2.new(0.5, 0.5)
FloatCore.Position = UDim2.new(0.5, 0, 0.5, 0)
FloatCore.Size = UDim2.new(0, 11, 0, 11)
FloatCore.BackgroundColor3 = Colors.Accent
Instance.new("UICorner", FloatCore).CornerRadius = UDim.new(1, 0)

local FloatOrbiter = Instance.new("Frame", FloatRing)
FloatOrbiter.AnchorPoint = Vector2.new(0.5, 0.5)
FloatOrbiter.Size = UDim2.new(0, 5, 0, 5)
FloatOrbiter.Position = UDim2.new(0.5, 16, 0.5, 0)
FloatOrbiter.BackgroundColor3 = Colors.TextWhite
Instance.new("UICorner", FloatOrbiter).CornerRadius = UDim.new(1, 0)

-- These loop continuously for as long as the script runs so the animation
-- never has to "restart" -- it's simply hidden behind FloatingGui.Enabled.
TweenService:Create(FloatRing, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.new(0, 38, 0, 38)}):Play()
TweenService:Create(FloatCore, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.new(0, 8, 0, 8)}):Play()

local floatOrbitAngle = 0
local floatOrbitRadius = 16
RunService.RenderStepped:Connect(function(dt)
    floatOrbitAngle = floatOrbitAngle + dt * 260
    local rad = math.rad(floatOrbitAngle)
    FloatOrbiter.Position = UDim2.new(0.5, math.cos(rad) * floatOrbitRadius, 0.5, math.sin(rad) * floatOrbitRadius)
end)

-- Click-through button covering the whole launcher: restores the main window.
-- Dragging is also handled here; a small movement threshold keeps a drag from
-- being misread as a restore-click when the mouse is released.
local FloatButton = Instance.new("TextButton", FloatingFrame)
FloatButton.Size = UDim2.new(1, 0, 1, 0)
FloatButton.BackgroundTransparency = 1
FloatButton.Text = ""
FloatButton.ZIndex = 5

local floatDragging = false
local floatDragStart, floatStartPos
local floatMoved = false
local isMinimized = false

local function restoreFromFloating()
    FloatingGui.Enabled = false
    Main.Visible = true
    isMinimized = false
end

FloatButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        floatDragging = true
        floatMoved = false
        floatDragStart = input.Position
        floatStartPos = FloatingFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                floatDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if floatDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - floatDragStart
        if delta.Magnitude > 4 then
            floatMoved = true
        end
        FloatingFrame.Position = UDim2.new(
            floatStartPos.X.Scale, floatStartPos.X.Offset + delta.X,
            floatStartPos.Y.Scale, floatStartPos.Y.Offset + delta.Y
        )
    end
end)

FloatButton.MouseButton1Click:Connect(function()
    if floatMoved then return end -- this release ended a drag, not a click
    restoreFromFloating()
end)

-- =============================================================================
-- MINIMIZE / CLOSE BEHAVIOR
-- =============================================================================
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = true
    Main.Visible = false
    FloatingGui.Enabled = true
end)

CloseBtn.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(Main, TWEEN_MED, {
        Size = UDim2.new(0, Main.Size.X.Offset, 0, 0),
        Position = Main.Position + UDim2.new(0, 0, 0, Main.Size.Y.Offset / 2)
    })
    tween:Play()
    tween.Completed:Connect(function()
        ScreenGui:Destroy()
        FloatingGui:Destroy()
    end)
end)

-- Reopen hotkey (remove this block if you don't want it)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        if isMinimized then
            restoreFromFloating()
        else
            Main.Visible = not Main.Visible
        end
    end
end)


-- =============================================================================
-- SPLASH -> MAIN HANDOFF
-- =============================================================================
task.delay(SPLASH_DURATION, function()
    -- stop the looping splash animations cleanly
    if orbitConn then orbitConn:Disconnect() end
    if percentConn then percentConn:Disconnect() end
    pulseTween:Cancel()
    corePulse:Cancel()
    PercentLabel.Text = "100%"

    -- brief settle at 100% before transitioning out
    task.wait(0.35)

    -- fade every splash element out together
    local fadeOutTime = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(Splash, fadeOutTime, {BackgroundTransparency = 1}):Play()
    TweenService:Create(GlowStroke, fadeOutTime, {Transparency = 1}):Play()
    TweenService:Create(CoreDot, fadeOutTime, {BackgroundTransparency = 1}):Play()
    TweenService:Create(Orbiter, fadeOutTime, {BackgroundTransparency = 1}):Play()
    TweenService:Create(SplashTitle, fadeOutTime, {TextTransparency = 1}):Play()
    TweenService:Create(SplashSubtitle, fadeOutTime, {TextTransparency = 1}):Play()
    TweenService:Create(BarTrack, fadeOutTime, {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarFill, fadeOutTime, {BackgroundTransparency = 1}):Play()
    TweenService:Create(PercentLabel, fadeOutTime, {TextTransparency = 1}):Play()

    task.wait(0.4)
    Splash:Destroy()

    -- reveal the main window with a safe fade (never touches Size/ClipsDescendants,
    -- so it can never get stuck invisible even if interrupted)
    Main.Visible = true
    TweenService:Create(Main, TWEEN_SLOW, {BackgroundTransparency = 0}):Play()
    TweenService:Create(MainStroke, TWEEN_SLOW, {Transparency = 0.75}):Play()
end)
