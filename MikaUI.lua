--[[
==================================================================================
  Mika UI  ·  v1.0.0
  make interfaces with Mika ui
----------------------------------------------------------------------------------
  A soft, glassy UI library for Roblox scripts and executors.

  Features
    · Unique "Aurora glass" look (gradient accents, soft strokes, micro animations)
    · 7 built-in themes + fully custom themes + themes loaded from a URL
    · 12 element types, notifications, toggle key, smooth tab switching
    · Load external URLs *inside* the hub (text/HTML/markdown viewer)
    · Deep customization: accent, gradients, fonts, radius, transparency,
      animation speed, watermark, window size, tab position, blur
    · Tiny, almost invisible watermark in the corner (fully configurable)

  Quick start
    local MikaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/<you>/<repo>/main/MikaUI.lua"))()
    local Window = MikaUI:CreateWindow({ Title = "Mika UI", Subtitle = "make interfaces with Mika ui" })
    local Tab    = Window:CreateTab("Main")
    local Sec    = Tab:CreateSection("General")
    Sec:CreateToggle({ Name = "Enabled", Default = true, Callback = function(v) print(v) end })

  License: MIT
==================================================================================
]]

--!nocheck

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

local MikaUI = {}
MikaUI.Version = "1.0.0"
MikaUI.Author = "Mika"

--==================================================================================
-- 0 · Executor helpers
--==================================================================================

local function protectGui(gui)
  local s = syn
  if s and s.protect_gui then
    pcall(s.protect_gui, gui)
  end
  local p = protectgui
  if p then
    pcall(p, gui)
  end
end

local function getGuiParent()
  local ok, hui = pcall(function()
    if gethui then
      return gethui()
    end
    return nil
  end)
  if ok and hui then
    return hui
  end
  local playerGui = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
  if playerGui then
    return playerGui
  end
  return game:GetService("CoreGui")
end

local function httpGet(url)
  local requestFn = (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request
  if requestFn then
    local ok, res = pcall(requestFn, { Url = url, Method = "GET" })
    if ok and type(res) == "table" then
      local body = res.Body or res.body
      if body then
        return body
      end
    end
  end
  if game.HttpGet then
    local ok, body = pcall(game.HttpGet, game, url)
    if ok and type(body) == "string" then
      return body
    end
  end
  return nil, "no http client available"
end

--==================================================================================
-- 1 · Themes
--==================================================================================

local Themes = {}

Themes.Aurora = {
  Background = Color3.fromRGB(17, 19, 28),
  Surface = Color3.fromRGB(27, 30, 44),
  SurfaceHigh = Color3.fromRGB(36, 40, 59),
  Stroke = Color3.fromRGB(56, 63, 92),
  Text = Color3.fromRGB(238, 242, 255),
  SubText = Color3.fromRGB(148, 157, 189),
  Accent = Color3.fromRGB(124, 164, 255),
  Accent2 = Color3.fromRGB(190, 138, 255),
  Good = Color3.fromRGB(120, 226, 168),
  Bad = Color3.fromRGB(255, 120, 140),
}

Themes.Midnight = {
  Background = Color3.fromRGB(10, 11, 16),
  Surface = Color3.fromRGB(19, 21, 30),
  SurfaceHigh = Color3.fromRGB(28, 31, 43),
  Stroke = Color3.fromRGB(44, 49, 68),
  Text = Color3.fromRGB(228, 233, 247),
  SubText = Color3.fromRGB(128, 136, 163),
  Accent = Color3.fromRGB(96, 214, 255),
  Accent2 = Color3.fromRGB(120, 140, 255),
  Good = Color3.fromRGB(110, 216, 160),
  Bad = Color3.fromRGB(250, 110, 130),
}

Themes.Sakura = {
  Background = Color3.fromRGB(28, 20, 26),
  Surface = Color3.fromRGB(42, 29, 38),
  SurfaceHigh = Color3.fromRGB(56, 38, 50),
  Stroke = Color3.fromRGB(84, 57, 73),
  Text = Color3.fromRGB(255, 237, 245),
  SubText = Color3.fromRGB(196, 152, 174),
  Accent = Color3.fromRGB(255, 145, 190),
  Accent2 = Color3.fromRGB(255, 190, 150),
  Good = Color3.fromRGB(150, 226, 178),
  Bad = Color3.fromRGB(255, 120, 140),
}

Themes.Neon = {
  Background = Color3.fromRGB(9, 12, 14),
  Surface = Color3.fromRGB(17, 22, 25),
  SurfaceHigh = Color3.fromRGB(24, 33, 37),
  Stroke = Color3.fromRGB(38, 58, 60),
  Text = Color3.fromRGB(226, 255, 249),
  SubText = Color3.fromRGB(120, 168, 160),
  Accent = Color3.fromRGB(80, 255, 200),
  Accent2 = Color3.fromRGB(80, 200, 255),
  Good = Color3.fromRGB(120, 255, 170),
  Bad = Color3.fromRGB(255, 95, 120),
}

Themes.Mono = {
  Background = Color3.fromRGB(22, 22, 24),
  Surface = Color3.fromRGB(32, 32, 35),
  SurfaceHigh = Color3.fromRGB(43, 43, 47),
  Stroke = Color3.fromRGB(64, 64, 70),
  Text = Color3.fromRGB(244, 244, 246),
  SubText = Color3.fromRGB(152, 152, 160),
  Accent = Color3.fromRGB(232, 232, 238),
  Accent2 = Color3.fromRGB(178, 178, 188),
  Good = Color3.fromRGB(178, 220, 190),
  Bad = Color3.fromRGB(236, 140, 150),
}

Themes.Void = {
  Background = Color3.fromRGB(8, 6, 14),
  Surface = Color3.fromRGB(18, 14, 28),
  SurfaceHigh = Color3.fromRGB(27, 21, 41),
  Stroke = Color3.fromRGB(50, 38, 74),
  Text = Color3.fromRGB(240, 234, 255),
  SubText = Color3.fromRGB(150, 134, 184),
  Accent = Color3.fromRGB(168, 108, 255),
  Accent2 = Color3.fromRGB(255, 108, 208),
  Good = Color3.fromRGB(126, 232, 176),
  Bad = Color3.fromRGB(255, 112, 146),
}

Themes.Daylight = {
  Background = Color3.fromRGB(240, 242, 248),
  Surface = Color3.fromRGB(255, 255, 255),
  SurfaceHigh = Color3.fromRGB(232, 236, 246),
  Stroke = Color3.fromRGB(206, 212, 228),
  Text = Color3.fromRGB(26, 30, 44),
  SubText = Color3.fromRGB(112, 122, 148),
  Accent = Color3.fromRGB(96, 132, 255),
  Accent2 = Color3.fromRGB(160, 112, 255),
  Good = Color3.fromRGB(34, 158, 106),
  Bad = Color3.fromRGB(220, 66, 92),
}

--==================================================================================
-- 2 · Config, live theme state and registries
--==================================================================================

local Config = {
  Theme = "Aurora",
  WindowTransparency = 0.04,
  ElementTransparency = 0.42,
  CornerRadius = 12,
  Animations = true,
  AnimSpeed = 0.18,
  Font = Enum.Font.GothamMedium,
  TitleFont = Enum.Font.GothamBold,
  Blur = false,
  Watermark = {
    Text = "make interfaces with Mika ui",
    Visible = true,
    Transparency = 0.86,
    TextSize = 10,
    Position = "BottomRight",
  },
}

local Theme = {}
for key, value in pairs(Themes.Aurora) do
  Theme[key] = value
end

local registry = {
  colors = {},
  gradients = {},
  corners = {},
  fonts = {},
  watermarks = {},
  rows = setmetatable({}, { __mode = "k" }),
}

local function refreshColors()
  for _, item in ipairs(registry.colors) do
    local value = Theme[item.key]
    if value then
      pcall(function()
        item.inst[item.prop] = value
      end)
    end
  end
end

local function refreshGradients()
  for _, item in ipairs(registry.gradients) do
    local a = Theme[item.a]
    local b = Theme[item.b]
    if a and b then
      pcall(function()
        item.inst.Color = ColorSequence.new({
          ColorSequenceKeypoint.new(0, a),
          ColorSequenceKeypoint.new(1, b),
        })
      end)
    end
  end
end

local function refreshCorners()
  for _, item in ipairs(registry.corners) do
    local base = item.base
    local radius = Config.CornerRadius
    pcall(function()
      if base.Scale > 0 then
        item.inst.CornerRadius = UDim.new(base.Scale, 0)
      else
        item.inst.CornerRadius = UDim.new(0, math.floor(radius))
      end
    end)
  end
end

local function refreshFonts()
  for _, item in ipairs(registry.fonts) do
    pcall(function()
      item.inst.Font = item.bold and Config.TitleFont or Config.Font
    end)
  end
end

local function refreshWatermarks()
  for _, label in ipairs(registry.watermarks) do
    pcall(function()
      label.Text = Config.Watermark.Text
      label.TextTransparency = Config.Watermark.Transparency
      label.TextSize = Config.Watermark.TextSize
      label.Visible = Config.Watermark.Visible
    end)
  end
end

--==================================================================================
-- 3 · Builders
--==================================================================================

local function new(class, props, children)
  local inst = Instance.new(class)
  local parent = nil
  if props then
    for key, value in pairs(props) do
      if key == "Parent" then
        parent = value
      else
        inst[key] = value
      end
    end
  end
  if children then
    for _, child in ipairs(children) do
      child.Parent = inst
    end
  end
  if parent then
    inst.Parent = parent
  end
  return inst
end

local function text(props, bold, colorKey)
  local inst = Instance.new("TextLabel")
  inst.BackgroundTransparency = 1
  inst.BorderSizePixel = 0
  inst.Font = bold and Config.TitleFont or Config.Font
  inst.TextColor3 = Theme[colorKey or "Text"]
  inst.TextXAlignment = Enum.TextXAlignment.Left
  inst.TextYAlignment = Enum.TextYAlignment.Center
  inst.Text = ""
  if props then
    for key, value in pairs(props) do
      inst[key] = value
    end
  end
  table.insert(registry.fonts, { inst = inst, bold = bold and true or false })
  table.insert(registry.colors, { inst = inst, prop = "TextColor3", key = colorKey or "Text" })
  return inst
end

local function corner(inst, radius)
  local c = Instance.new("UICorner")
  c.CornerRadius = UDim.new(0, radius or Config.CornerRadius)
  c.Parent = inst
  table.insert(registry.corners, { inst = c, base = c.CornerRadius })
  return c
end

local function stroke(inst, colorKey, thickness, transparency)
  local s = Instance.new("UIStroke")
  s.Color = Theme[colorKey or "Stroke"]
  s.Thickness = thickness or 1
  s.Transparency = transparency or 0.5
  s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  s.Parent = inst
  table.insert(registry.colors, { inst = s, prop = "Color", key = colorKey or "Stroke" })
  return s
end

local function accentGradient(inst, keyA, keyB, rotation)
  local g = Instance.new("UIGradient")
  g.Rotation = rotation or 90
  g.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme[keyA or "Accent"]),
    ColorSequenceKeypoint.new(1, Theme[keyB or "Accent2"]),
  })
  g.Parent = inst
  table.insert(registry.gradients, { inst = g, a = keyA or "Accent", b = keyB or "Accent2" })
  return g
end

local function tween(inst, props, info)
  if not Config.Animations then
    for key, value in pairs(props) do
      inst[key] = value
    end
    return nil
  end
  local t = TweenService:Create(
    inst,
    info or TweenInfo.new(Config.AnimSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    props
  )
  t:Play()
  return t
end

local function colorToHex(color)
  return string.format(
    "%02X%02X%02X",
    math.floor(color.R * 255 + 0.5),
    math.floor(color.G * 255 + 0.5),
    math.floor(color.B * 255 + 0.5)
  )
end

local function parseColor(value)
  if typeof(value) == "Color3" then
    return value
  end
  if type(value) == "string" then
    local hex = value:gsub("#", "")
    if #hex == 6 then
      return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16) or 255,
        tonumber(hex:sub(3, 4), 16) or 255,
        tonumber(hex:sub(5, 6), 16) or 255
      )
    end
    local r, g, b = value:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
    if r then
      return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
    end
  end
  if type(value) == "table" then
    local r = value.R or value.r or value[1]
    local g = value.G or value.g or value[2]
    local b = value.B or value.b or value[3]
    if r then
      local function norm(c)
        if c <= 1 and c >= 0 and typeof(value) ~= "Color3" and not value.r then
          return math.floor(c * 255 + 0.5)
        end
        return math.floor(c)
      end
      return Color3.fromRGB(norm(r), norm(g), norm(b))
    end
  end
  return nil
end

local function makeDraggable(frame, handle)
  local dragging = false
  local dragStart = nil
  local startPos = nil

  handle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
      dragging = true
      dragStart = input.Position
      startPos = frame.Position
      input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
          dragging = false
        end
      end)
    end
  end)

  handle.InputChanged:Connect(function(input)
    if not dragging then
      return
    end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
      local delta = input.Position - dragStart
      frame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
      )
    end
  end)
end

local function dragBar(track, onFraction)
  local dragging = false
  local function update(position)
    local fraction = (position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1)
    onFraction(math.clamp(fraction, 0, 1))
  end
  track.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
      dragging = true
      update(input.Position)
    end
  end)
  UserInputService.InputChanged:Connect(function(input)
    if not dragging then
      return
    end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
      update(input.Position)
    end
  end)
  UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
      dragging = false
    end
  end)
end

--==================================================================================
-- 4 · External content helpers
--==================================================================================

local function stripHtml(html)
  local LF = string.char(10)
  local TAB = string.char(9)
  local s = tostring(html)
  s = s:gsub("<script.->", " ")
  s = s:gsub("<style.->", " ")
  s = s:gsub("<br%s*/?>", LF)
  s = s:gsub("</p>", LF .. LF)
  s = s:gsub("</div>", LF)
  s = s:gsub("</li>", LF)
  s = s:gsub("<.->", "")
  s = s:gsub("&nbsp;", " ")
  s = s:gsub("&amp;", "&")
  s = s:gsub("&lt;", "<")
  s = s:gsub("&gt;", ">")
  s = s:gsub("&quot;", '"')
  s = s:gsub("&#39;", "'")
  s = s:gsub("[ " .. TAB .. "]+", " ")
  s = s:gsub(LF .. "[ " .. TAB .. "]*" .. LF .. "[ " .. TAB .. "]*" .. LF .. "+", LF .. LF)
  s = s:gsub("^%s+", "")
  s = s:gsub("%s+$", "")
  return s
end

local function looksLikeHtml(body)
  local lower = body:lower()
  return lower:find("<html", 1, true) ~= nil
    or lower:find("<body", 1, true) ~= nil
    or lower:find("<div", 1, true) ~= nil
    or lower:find("<p>", 1, true) ~= nil
end

local function fetchReadable(url)
  local body, err = httpGet(url)
  if not body then
    return nil, err or "request failed"
  end
  if looksLikeHtml(body) then
    body = stripHtml(body)
  end
  return body:sub(1, 8000)
end

--==================================================================================
-- 5 · Notifications
--==================================================================================

local notifGui = nil
local notifHolder = nil

local function ensureNotifications()
  if notifGui then
    return
  end
  notifGui = new("ScreenGui", {
    Name = "MikaUINotifications",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = 10000,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = getGuiParent(),
  })
  protectGui(notifGui)
  notifHolder = new("Frame", {
    Name = "Holder",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -18, 0, 18),
    Size = UDim2.new(0, 290, 1, -36),
    BackgroundTransparency = 1,
    Parent = notifGui,
  })
  new("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    Parent = notifHolder,
  })
end

function MikaUI:Notify(opts)
  opts = opts or {}
  local title = opts.Title or "Notification"
  local content = opts.Content or opts.Text or ""
  local duration = opts.Duration or 4
  local accentKey = opts.Accent or "Accent"

  ensureNotifications()

  local card = new("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundColor3 = Theme.Surface,
    BackgroundTransparency = 0.06,
    Parent = notifHolder,
    ClipsDescendants = true,
  })
  corner(card, 10)
  stroke(card, "Stroke", 1, 0.55)
  table.insert(registry.colors, { inst = card, prop = "BackgroundColor3", key = "Surface" })

  local bar = new("Frame", {
    Size = UDim2.new(0, 3, 1, -18),
    Position = UDim2.new(0, 0, 0, 9),
    BackgroundColor3 = Theme[accentKey],
    Parent = card,
  })
  corner(bar, 3)
  accentGradient(bar, accentKey, accentKey == "Bad" and "Bad" or "Accent2", 90)

  new("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 14),
    PaddingRight = UDim.new(0, 12),
    Parent = card,
  })

  local titleLabel = text({
    Size = UDim2.new(1, 0, 0, 16),
    Text = title,
    TextSize = 13,
    Parent = card,
  }, true)
  titleLabel.TextXAlignment = Enum.TextXAlignment.Left

  text({
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 0, 18),
    Text = content,
    TextSize = 12,
    TextWrapped = true,
    AutomaticSize = Enum.AutomaticSize.Y,
    TextColor3 = Theme.SubText,
    Parent = card,
  }, false, "SubText")

  local holder = notifHolder
  local created = card

  if Config.Animations then
    created.Position = UDim2.new(0, 60, 0, 0)
    created.BackgroundTransparency = 1
    tween(created, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.06 })
  end

  task.delay(math.max(duration, 1.5), function()
    if not created or not created.Parent then
      return
    end
    if Config.Animations then
      local out = tween(created, {
        Position = UDim2.new(0, 60, 0, 0),
        BackgroundTransparency = 1,
      })
      if out then
        out.Completed:Wait()
      end
    end
    if created then
      created:Destroy()
    end
    if holder and #holder:GetChildren() == 1 then
      -- only the UIListLayout left: gui stays, keeps things simple
    end
  end)

  return card
end

--==================================================================================
-- 6 · Section rows
--==================================================================================

local Section = {}
Section.__index = Section

local function makeRow(section, height, opts)
  opts = opts or {}
  local rowHeight = height or 42
  local row = new("Frame", {
    Size = UDim2.new(1, 0, 0, rowHeight),
    BackgroundColor3 = Theme.Surface,
    BackgroundTransparency = Config.ElementTransparency,
    Parent = section.Container,
    ClipsDescendants = opts.clip and true or false,
  })
  corner(row, 10)
  stroke(row, "Stroke", 1, 0.7)
  table.insert(registry.colors, { inst = row, prop = "BackgroundColor3", key = "Surface" })

  registry.rows[row] = { base = Config.ElementTransparency }

  if opts.hover ~= false then
    row.MouseEnter:Connect(function()
      local state = registry.rows[row]
      if state then
        tween(row, { BackgroundTransparency = math.max((state.base or 0.4) - 0.22, 0) })
      end
    end)
    row.MouseLeave:Connect(function()
      local state = registry.rows[row]
      if state then
        tween(row, { BackgroundTransparency = state.base or 0.4 })
      end
    end)
  end

  return row
end

local function rowTitle(row, name, description)
  local nameLabel = text({
    Size = UDim2.new(1, -140, 0, description and 16 or 20),
    Position = UDim2.new(0, 14, 0, description and 6 or 0),
    Text = name or "",
    TextSize = 13,
    Parent = row,
  })
  nameLabel.TextYAlignment = Enum.TextYAlignment.Center
  if description then
    local desc = text({
      Size = UDim2.new(1, -140, 0, 14),
      Position = UDim2.new(0, 14, 0, 20),
      Text = description,
      TextSize = 11,
      Parent = row,
    }, false, "SubText")
    desc.TextYAlignment = Enum.TextYAlignment.Top
  end
  return nameLabel
end

local function rightHolder(row, width)
  local holder = new("Frame", {
    Size = UDim2.new(0, width or 140, 1, 0),
    Position = UDim2.new(1, -(width or 140) - 12, 0, 0),
    BackgroundTransparency = 1,
    Parent = row,
  })
  return holder
end

--==================================================================================
-- 7 · Elements
--==================================================================================

function Section:CreateButton(opts)
  opts = opts or {}
  local row = new("TextButton", {
    Size = UDim2.new(1, 0, 0, opts.Description and 50 or 40),
    BackgroundColor3 = Theme.Surface,
    BackgroundTransparency = Config.ElementTransparency,
    Text = "",
    AutoButtonColor = false,
    Parent = self.Container,
    ClipsDescendants = true,
  })
  corner(row, 10)
  stroke(row, "Stroke", 1, 0.7)
  table.insert(registry.colors, { inst = row, prop = "BackgroundColor3", key = "Surface" })
  registry.rows[row] = { base = Config.ElementTransparency }

  rowTitle(row, opts.Name or "Button", opts.Description)

  local bar = new("Frame", {
    Size = UDim2.new(0, 3, 0, 18),
    Position = UDim2.new(0, 0, 0.5, -9),
    BackgroundColor3 = Theme.Accent,
    Parent = row,
  })
  corner(bar, 3)
  accentGradient(bar)

  row.MouseEnter:Connect(function()
    tween(row, { BackgroundTransparency = math.max(Config.ElementTransparency - 0.24, 0) })
  end)
  row.MouseLeave:Connect(function()
    tween(row, { BackgroundTransparency = Config.ElementTransparency })
  end)
  row.MouseButton1Click:Connect(function()
    if opts.Callback then
      local ok, err = pcall(opts.Callback)
      if not ok then
        MikaUI:Notify({ Title = "Error", Content = tostring(err), Accent = "Bad" })
      end
    end
  end)

  return row
end

function Section:CreateToggle(opts)
  opts = opts or {}
  local row = makeRow(self, opts.Description and 50 or 40)
  rowTitle(row, opts.Name or "Toggle", opts.Description)

  local holder = rightHolder(row, 46)
  local state = opts.Default and true or false

  local pill = new("Frame", {
    Size = UDim2.new(0, 38, 0, 20),
    Position = UDim2.new(1, -38, 0.5, -10),
    BackgroundColor3 = Theme.SurfaceHigh,
    Parent = holder,
  })
  corner(pill, 10)
  local pillStroke = stroke(pill, "Stroke", 1, 0.5)

  local fill = new("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 1,
    Parent = pill,
  })
  corner(fill, 10)
  accentGradient(fill, "Accent", "Accent2", 0)

  local knob = new("Frame", {
    Size = UDim2.new(0, 14, 0, 14),
    Position = UDim2.new(0, 3, 0.5, -7),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    Parent = pill,
  })
  corner(knob, 8)

  local click = new("TextButton", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "",
    Parent = row,
  })

  local function visual(on, animate)
    local target = on and 0.05 or 1
    local x = on and 21 or 3
    if animate then
      tween(fill, { BackgroundTransparency = target })
      tween(knob, { Position = UDim2.new(0, x, 0.5, -7) })
    else
      fill.BackgroundTransparency = target
      knob.Position = UDim2.new(0, x, 0.5, -7)
    end
    pillStroke.Transparency = on and 1 or 0.5
  end

  visual(state, false)

  local function setValue(value, fire)
    state = value and true or false
    visual(state, true)
    if fire and opts.Callback then
      local ok, err = pcall(opts.Callback, state)
      if not ok then
        MikaUI:Notify({ Title = "Error", Content = tostring(err), Accent = "Bad" })
      end
    end
  end

  click.MouseButton1Click:Connect(function()
    setValue(not state, true)
  end)

  return {
    Set = function(_, value)
      setValue(value, false)
    end,
    Get = function()
      return state
    end,
    Instance = row,
  }
end

function Section:CreateSlider(opts)
  opts = opts or {}
  local min = opts.Min or 0
  local max = opts.Max or 100
  local step = opts.Step or 1
  local suffix = opts.Suffix or ""
  local value = math.clamp(opts.Default or min, min, max)

  local row = makeRow(self, opts.Description and 56 or 46)
  rowTitle(row, opts.Name or "Slider", opts.Description)

  local holder = rightHolder(row, 150)
  local track = new("Frame", {
    Size = UDim2.new(1, -40, 0, 6),
    Position = UDim2.new(0, 0, 0.5, -3),
    BackgroundColor3 = Theme.SurfaceHigh,
    Parent = holder,
  })
  corner(track, 3)

  local fill = new("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Theme.Accent,
    Parent = track,
  })
  corner(fill, 3)
  accentGradient(fill, "Accent", "Accent2", 0)

  local knob = new("Frame", {
    Size = UDim2.new(0, 12, 0, 12),
    Position = UDim2.new(0, -6, 0.5, -6),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    Parent = track,
  })
  corner(knob, 6)
  stroke(knob, "Accent", 2, 0)

  local valueLabel = text({
    Size = UDim2.new(0, 46, 0, 14),
    Position = UDim2.new(1, -36, 0.5, -7),
    Text = "",
    TextSize = 11,
    Parent = holder,
  }, true)
  valueLabel.TextXAlignment = Enum.TextXAlignment.Right
  valueLabel.Position = UDim2.new(1, 36, 0.5, -7)
  valueLabel.Size = UDim2.new(0, 60, 0, 14)
  valueLabel.TextTruncate = Enum.TextTruncate.AtEnd

  local decimals = step < 1 and 2 or 0

  local function formatValue()
    local base = string.format("%." .. decimals .. "f", value)
    return base .. suffix
  end

  local function update(push)
    local alpha = (max - min) == 0 and 0 or (value - min) / (max - min)
    fill.Size = UDim2.new(alpha, 0, 1, 0)
    knob.Position = UDim2.new(alpha, -6, 0.5, -6)
    valueLabel.Text = formatValue()
    if push and opts.Callback then
      local ok, err = pcall(opts.Callback, value)
      if not ok then
        MikaUI:Notify({ Title = "Error", Content = tostring(err), Accent = "Bad" })
      end
    end
  end

  dragBar(track, function(fraction)
    local raw = min + (max - min) * fraction
    local snapped = math.floor(raw / step + 0.5) * step
    value = math.clamp(snapped, min, max)
    update(true)
  end)

  update(false)

  return {
    Set = function(_, newValue)
      value = math.clamp(newValue, min, max)
      update(false)
    end,
    Get = function()
      return value
    end,
    Instance = row,
  }
end

function Section:CreateDropdown(opts)
  opts = opts or {}
  local options = opts.Options or opts.Items or {}
  local multi = opts.Multi and true or false
  local listHeight = math.min(#options, 5) * 26 + 8

  local row = makeRow(self, 42, { clip = true })
  rowTitle(row, opts.Name or "Dropdown", opts.Description)

  local holder = rightHolder(row, 140)
  local display = text({
    Size = UDim2.new(1, -20, 1, 0),
    Text = "none",
    TextSize = 12,
    Parent = holder,
  }, false, "SubText")
  display.TextXAlignment = Enum.TextXAlignment.Right
  display.TextTruncate = Enum.TextTruncate.AtEnd

  local arrow = text({
    Size = UDim2.new(0, 14, 1, 0),
    Position = UDim2.new(1, -14, 0, 0),
    Text = "v",
    TextSize = 11,
    Parent = holder,
  }, false, "SubText")
  arrow.TextXAlignment = Enum.TextXAlignment.Right

  local button = new("TextButton", {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundTransparency = 1,
    Text = "",
    Parent = row,
  })

  local list = new("ScrollingFrame", {
    Size = UDim2.new(1, -24, 0, listHeight),
    Position = UDim2.new(0, 12, 0, 44),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Theme.Accent,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = row,
  })
  corner(list, 8)
  stroke(list, "Stroke", 1, 0.6)
  table.insert(registry.colors, { inst = list, prop = "BackgroundColor3", key = "Background" })
  new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
  new("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = list })

  local selection = {}
  local open = false

  local function refreshDisplay()
    local parts = {}
    for option in pairs(selection) do
      table.insert(parts, tostring(option))
    end
    table.sort(parts)
    if #parts == 0 then
      display.Text = "none"
    elseif #parts == 1 then
      display.Text = parts[1]
    else
      display.Text = "[" .. #parts .. " selected]"
    end
  end

  local function fire()
    local result
    if multi then
      local arr = {}
      for option in pairs(selection) do
        table.insert(arr, option)
      end
      result = arr
    else
      for option in pairs(selection) do
        result = option
      end
    end
    if opts.Callback then
      local ok, err = pcall(opts.Callback, result)
      if not ok then
        MikaUI:Notify({ Title = "Error", Content = tostring(err), Accent = "Bad" })
      end
    end
  end

  local optionButtons = {}

  for index, option in ipairs(options) do
    local item = new("TextButton", {
      Size = UDim2.new(1, -4, 0, 24),
      Position = UDim2.new(0, 2, 0, 0),
      BackgroundColor3 = Theme.SurfaceHigh,
      BackgroundTransparency = 1,
      Text = "",
      AutoButtonColor = false,
      LayoutOrder = index,
      Parent = list,
    })
    corner(item, 6)
    local itemLabel = text({
      Size = UDim2.new(1, -16, 1, 0),
      Position = UDim2.new(0, 8, 0, 0),
      Text = tostring(option),
      TextSize = 12,
      Parent = item,
    }, false, "SubText")

    item.MouseEnter:Connect(function()
      tween(item, { BackgroundTransparency = 0.7 })
    end)
    item.MouseLeave:Connect(function()
      tween(item, { BackgroundTransparency = 1 })
    end)

    item.MouseButton1Click:Connect(function()
      if multi then
        selection[option] = not selection[option] or nil
      else
        selection = {}
        selection[option] = true
      end
      for opt, btn in pairs(optionButtons) do
        local selected = selection[opt] and true or false
        btn.label.TextColor3 = selected and Theme.Accent or Theme.SubText
        btn.item.BackgroundTransparency = selected and 0.75 or 1
      end
      refreshDisplay()
      fire()
      if not multi then
        open = false
        tween(row, { Size = UDim2.new(1, 0, 0, 42) })
        list.Visible = false
      end
    end)

    optionButtons[option] = { item = item, label = itemLabel }
  end

  local function setOpen(value)
    open = value
    list.Visible = value
    if value then
      tween(row, { Size = UDim2.new(1, 0, 0, 42 + listHeight + 6) })
    else
      tween(row, { Size = UDim2.new(1, 0, 0, 42) })
    end
  end

  list.Visible = false

  button.MouseButton1Click:Connect(function()
    setOpen(not open)
  end)

  -- defaults
  if opts.Default then
    if type(opts.Default) == "table" then
      for _, option in ipairs(opts.Default) do
        selection[option] = true
      end
    else
      selection[opts.Default] = true
    end
    for opt, btn in pairs(optionButtons) do
      local selected = selection[opt] and true or false
      btn.label.TextColor3 = selected and Theme.Accent or Theme.SubText
      btn.item.BackgroundTransparency = selected and 0.75 or 1
    end
  end
  refreshDisplay()

  return {
    Set = function(_, value)
      selection = {}
      if type(value) == "table" then
        for _, option in ipairs(value) do
          selection[option] = true
        end
      elseif value ~= nil then
        selection[value] = true
      end
      for opt, btn in pairs(optionButtons) do
        local selected = selection[opt] and true or false
        btn.label.TextColor3 = selected and Theme.Accent or Theme.SubText
        btn.item.BackgroundTransparency = selected and 0.75 or 1
      end
      refreshDisplay()
    end,
    Get = function()
      local arr = {}
      for option in pairs(selection) do
        table.insert(arr, option)
      end
      return multi and arr or arr[1]
    end,
    Instance = row,
  }
end

function Section:CreateInput(opts)
  opts = opts or {}
  local row = makeRow(self, 42)
  rowTitle(row, opts.Name or "Input", opts.Description)

  local box = new("TextBox", {
    Size = UDim2.new(0, 150, 0, 26),
    Position = UDim2.new(1, -162, 0.5, -13),
    BackgroundColor3 = Theme.SurfaceHigh,
    BackgroundTransparency = 0.15,
    Text = opts.Default or "",
    PlaceholderText = opts.Placeholder or "type here...",
    PlaceholderColor3 = Theme.SubText,
    TextColor3 = Theme.Text,
    TextSize = 12,
    Font = Config.Font,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = row,
  })
  corner(box, 7)
  stroke(box, "Stroke", 1, 0.5)
  table.insert(registry.colors, { inst = box, prop = "BackgroundColor3", key = "SurfaceHigh" })
  table.insert(registry.colors, { inst = box, prop = "TextColor3", key = "Text" })
  table.insert(registry.colors, { inst = box, prop = "PlaceholderColor3", key = "SubText" })
  table.insert(registry.fonts, { inst = box, bold = false })
  new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = box })

  box.Focused:Connect(function()
    tween(box, { BackgroundTransparency = 0 })
  end)
  box.FocusLost:Connect(function(enter)
    if opts.Callback then
      local ok, err = pcall(opts.Callback, box.Text, enter)
      if not ok then
        MikaUI:Notify({ Title = "Error", Content = tostring(err), Accent = "Bad" })
      end
    end
  end)

  return {
    Set = function(_, value)
      box.Text = tostring(value)
      if opts.Callback then
        pcall(opts.Callback, box.Text, false)
      end
    end,
    Get = function()
      return box.Text
    end,
    Instance = row,
  }
end

function Section:CreateKeybind(opts)
  opts = opts or {}
  local row = makeRow(self, 42)
  rowTitle(row, opts.Name or "Keybind", opts.Description)

  local current = opts.Default or Enum.KeyCode.Unknown
  local listening = false

  local button = new("TextButton", {
    Size = UDim2.new(0, 92, 0, 26),
    Position = UDim2.new(1, -104, 0.5, -13),
    BackgroundColor3 = Theme.SurfaceHigh,
    BackgroundTransparency = 0.15,
    Text = "",
    AutoButtonColor = false,
    Parent = row,
  })
  corner(button, 7)
  stroke(button, "Stroke", 1, 0.5)
  table.insert(registry.colors, { inst = button, prop = "BackgroundColor3", key = "SurfaceHigh" })

  local keyLabel = text({
    Size = UDim2.new(1, 0, 1, 0),
    Text = current.Name,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Center,
    Parent = button,
  }, true)

  local connection

  local function stopListening()
    listening = false
    keyLabel.Text = current.Name
    if connection then
      connection:Disconnect()
      connection = nil
    end
  end

  button.MouseButton1Click:Connect(function()
    if listening then
      stopListening()
      return
    end
    listening = true
    keyLabel.Text = "press..."
    connection = UserInputService.InputBegan:Connect(function(input)
      if input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
      end
      current = input.KeyCode
      stopListening()
      if opts.Callback then
        pcall(opts.Callback, current)
      end
    end)
  end)

  return {
    Set = function(_, key)
      current = key
      keyLabel.Text = key.Name
    end,
    Get = function()
      return current
    end,
    Instance = row,
  }
end

function Section:CreateColorPicker(opts)
  opts = opts or {}
  local row = makeRow(self, 42, { clip = true })
  rowTitle(row, opts.Name or "Color", opts.Description)

  local current = opts.Default or Color3.fromRGB(124, 164, 255)
  local expanded = false

  local swatch = new("TextButton", {
    Size = UDim2.new(0, 54, 0, 24),
    Position = UDim2.new(1, -68, 0.5, -12),
    BackgroundColor3 = current,
    Text = "",
    AutoButtonColor = false,
    Parent = row,
  })
  corner(swatch, 7)
  local swatchStroke = stroke(swatch, "Stroke", 1, 0.4)

  local hexLabel = text({
    Size = UDim2.new(0, 54, 0, 24),
    Position = UDim2.new(1, -68, 0.5, -12),
    Text = "",
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Center,
    Parent = row,
  }, true)

  local channels = {
    { key = "R", value = current.R },
    { key = "G", value = current.G },
    { key = "B", value = current.B },
  }

  local bars = {}

  local function updateSwatch(fire)
    local color = Color3.fromRGB(
      math.floor(channels[1].value * 255 + 0.5),
      math.floor(channels[2].value * 255 + 0.5),
      math.floor(channels[3].value * 255 + 0.5)
    )
    current = color
    swatch.BackgroundColor3 = color
    hexLabel.Text = "#" .. colorToHex(color)
    hexLabel.TextColor3 = (color.R * 0.299 + color.G * 0.587 + color.B * 0.114) > 0.55
        and Color3.fromRGB(30, 30, 40)
      or Color3.fromRGB(245, 245, 250)
    if fire and opts.Callback then
      local ok, err = pcall(opts.Callback, color)
      if not ok then
        MikaUI:Notify({ Title = "Error", Content = tostring(err), Accent = "Bad" })
      end
    end
  end

  for index, channel in ipairs(channels) do
    local line = new("Frame", {
      Size = UDim2.new(1, -28, 0, 26),
      Position = UDim2.new(0, 14, 0, 44 + (index - 1) * 30),
      BackgroundTransparency = 1,
      Parent = row,
    })

    text({
      Size = UDim2.new(0, 12, 1, 0),
      Text = channel.key,
      TextSize = 10,
      Parent = line,
    }, true, "SubText")

    local track = new("Frame", {
      Size = UDim2.new(1, -52, 0, 6),
      Position = UDim2.new(0, 18, 0.5, -3),
      BackgroundColor3 = Theme.SurfaceHigh,
      Parent = line,
    })
    corner(track, 3)

    local channelColor = Color3.fromRGB(
      channel.key == "R" and 255 or 40,
      channel.key == "G" and 255 or 40,
      channel.key == "B" and 255 or 40
    )

    local fill = new("Frame", {
      Size = UDim2.new(channel.value, 0, 1, 0),
      BackgroundColor3 = channelColor,
      Parent = track,
    })
    corner(fill, 3)

    local readout = text({
      Size = UDim2.new(0, 26, 0, 14),
      Position = UDim2.new(1, -26, 0.5, -7),
      Text = tostring(math.floor(channel.value * 255 + 0.5)),
      TextSize = 10,
      TextXAlignment = Enum.TextXAlignment.Right,
      Parent = line,
    }, false, "SubText")

    bars[index] = { fill = fill, readout = readout }

    dragBar(track, function(fraction)
      channel.value = fraction
      fill.Size = UDim2.new(fraction, 0, 1, 0)
      readout.Text = tostring(math.floor(fraction * 255 + 0.5))
      updateSwatch(true)
    end)
  end

  swatch.MouseButton1Click:Connect(function()
    expanded = not expanded
    if expanded then
      tween(row, { Size = UDim2.new(1, 0, 0, 44 + 3 * 30 + 6) })
    else
      tween(row, { Size = UDim2.new(1, 0, 0, 42) })
    end
  end)

  updateSwatch(false)

  return {
    Set = function(_, color)
      current = color
      channels[1].value = color.R
      channels[2].value = color.G
      channels[3].value = color.B
      for index, bar in ipairs(bars) do
        bar.fill.Size = UDim2.new(channels[index].value, 0, 1, 0)
        bar.readout.Text = tostring(math.floor(channels[index].value * 255 + 0.5))
      end
      updateSwatch(false)
    end,
    Get = function()
      return current
    end,
    Instance = row,
  }
end

function Section:CreateLabel(opts)
  opts = opts or {}
  if type(opts) == "string" then
    opts = { Text = opts }
  end
  local card = new("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundColor3 = Theme.Surface,
    BackgroundTransparency = Config.ElementTransparency,
    Parent = self.Container,
  })
  corner(card, 10)
  stroke(card, "Stroke", 1, 0.75)
  table.insert(registry.colors, { inst = card, prop = "BackgroundColor3", key = "Surface" })
  new("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 14),
    PaddingRight = UDim.new(0, 14),
    Parent = card,
  })

  if opts.Name or opts.Title then
    text({
      Size = UDim2.new(1, 0, 0, 16),
      Text = opts.Name or opts.Title,
      TextSize = 12,
      Parent = card,
    }, true)
  end

  local body = text({
    Size = UDim2.new(1, 0, 0, 0),
    Position = UDim2.new(0, 0, 0, (opts.Name or opts.Title) and 18 or 0),
    Text = opts.Text or opts.Content or "",
    TextSize = 12,
    TextWrapped = true,
    TextYAlignment = Enum.TextYAlignment.Top,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = card,
  }, false, "SubText")

  if opts.RichText then
    body.RichText = true
  end

  return {
    Set = function(_, value)
      body.Text = tostring(value)
    end,
    Instance = card,
  }
end

function Section:CreateParagraph(opts)
  return self:CreateLabel(opts)
end

function Section:CreateDivider(opts)
  opts = opts or {}
  local holder = new("Frame", {
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundTransparency = 1,
    Parent = self.Container,
  })
  local line = new("Frame", {
    Size = UDim2.new(1, -8, 0, 1),
    Position = UDim2.new(0, 4, 0.5, 0),
    BackgroundColor3 = Theme.Stroke,
    BackgroundTransparency = 0.4,
    Parent = holder,
  })
  table.insert(registry.colors, { inst = line, prop = "BackgroundColor3", key = "Stroke" })
  return holder
end

function Section:CreateLinkButton(opts)
  opts = opts or {}
  local row = self:CreateButton({
    Name = opts.Name or "Open link",
    Description = opts.Description or opts.Url,
    Callback = function()
      MikaUI:OpenLink(opts.Url)
    end,
  })
  return row
end

--==================================================================================
-- 8 · External content viewer (loads URLs inside the hub)
--==================================================================================

function Section:CreateExternalView(opts)
  opts = opts or {}
  local height = opts.Height or 190
  local title = opts.Name or opts.Title or "External content"

  local card = new("Frame", {
    Size = UDim2.new(1, 0, 0, height + 66),
    BackgroundColor3 = Theme.Surface,
    BackgroundTransparency = Config.ElementTransparency,
    Parent = self.Container,
  })
  corner(card, 10)
  stroke(card, "Stroke", 1, 0.7)
  table.insert(registry.colors, { inst = card, prop = "BackgroundColor3", key = "Surface" })

  local head = text({
    Size = UDim2.new(1, -120, 0, 18),
    Position = UDim2.new(0, 14, 0, 10),
    Text = title,
    TextSize = 12,
    Parent = card,
  }, true)

  local status = text({
    Size = UDim2.new(1, -120, 0, 14),
    Position = UDim2.new(0, 14, 0, 28),
    Text = "waiting...",
    TextSize = 10,
    Parent = card,
  }, false, "SubText")

  local refreshBtn = new("TextButton", {
    Size = UDim2.new(0, 58, 0, 22),
    Position = UDim2.new(1, -132, 0, 12),
    BackgroundColor3 = Theme.SurfaceHigh,
    BackgroundTransparency = 0.15,
    Text = "reload",
    TextColor3 = Theme.Text,
    TextSize = 11,
    Font = Config.Font,
    AutoButtonColor = false,
    Parent = card,
  })
  corner(refreshBtn, 7)
  stroke(refreshBtn, "Stroke", 1, 0.5)
  table.insert(registry.colors, { inst = refreshBtn, prop = "BackgroundColor3", key = "SurfaceHigh" })
  table.insert(registry.colors, { inst = refreshBtn, prop = "TextColor3", key = "Text" })
  table.insert(registry.fonts, { inst = refreshBtn, bold = false })

  local openBtn = new("TextButton", {
    Size = UDim2.new(0, 62, 0, 22),
    Position = UDim2.new(1, -66, 0, 12),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 0.1,
    Text = "open",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 11,
    Font = Config.TitleFont,
    AutoButtonColor = false,
    Parent = card,
  })
  corner(openBtn, 7)
  accentGradient(openBtn, "Accent", "Accent2", 0)
  table.insert(registry.fonts, { inst = openBtn, bold = true })

  local body = new("ScrollingFrame", {
    Size = UDim2.new(1, -24, 0, height),
    Position = UDim2.new(0, 12, 0, 46),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Theme.Accent,
    ScrollBarImageTransparency = 0.4,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = card,
  })
  corner(body, 8)
  stroke(body, "Stroke", 1, 0.7)
  table.insert(registry.colors, { inst = body, prop = "BackgroundColor3", key = "Background" })
  new("UIPadding", {
    PaddingTop = UDim.new(0, 6),
    PaddingBottom = UDim.new(0, 6),
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
    Parent = body,
  })

  local content = text({
    Size = UDim2.new(1, 0, 0, 0),
    Text = "",
    TextSize = 11,
    TextWrapped = true,
    TextYAlignment = Enum.TextYAlignment.Top,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = body,
  }, false, "Text")

  local view = {
    Url = opts.Url or "",
    Title = title,
    Content = content,
    Status = status,
  }

  function view:Refresh()
    local url = view.Url
    if not url or url == "" then
      status.Text = "no url set"
      content.Text = "Set a URL with :SetUrl(url) to load content here."
      return
    end
    status.Text = "loading " .. url
    local ok, result, err = pcall(fetchReadable, url)
    if not ok then
      status.Text = "error: " .. tostring(result)
      content.Text = "Could not load this URL.\n" .. tostring(result)
      return
    end
    if not result then
      status.Text = "error: " .. tostring(err)
      content.Text = "Could not load this URL.\n" .. tostring(err or "unknown error")
      return
    end
    status.Text = url
    content.Text = result
  end

  function view:SetUrl(url)
    view.Url = url
    status.Text = url
    view:Refresh()
  end

  function view:SetTitle(newTitle)
    view.Title = newTitle
    head.Text = newTitle
  end

  function view:Destroy()
    card:Destroy()
  end

  refreshBtn.MouseButton1Click:Connect(function()
    view:Refresh()
  end)
  openBtn.MouseButton1Click:Connect(function()
    MikaUI:OpenLink(view.Url)
  end)
  refreshBtn.MouseEnter:Connect(function()
    tween(refreshBtn, { BackgroundTransparency = 0 })
  end)
  refreshBtn.MouseLeave:Connect(function()
    tween(refreshBtn, { BackgroundTransparency = 0.15 })
  end)

  if opts.AutoLoad ~= false then
    task.spawn(function()
      view:Refresh()
    end)
  else
    status.Text = "not loaded"
    content.Text = "Press reload to load " .. tostring(view.Url)
  end

  return view
end

--==================================================================================
-- 9 · Sections and tabs
--==================================================================================

function Section:AddRow(instance)
  instance.Parent = self.Container
  return instance
end

local Tab = {}
Tab.__index = Tab

function Tab:CreateSection(title, opts)
  opts = opts or {}
  local section = setmetatable({}, Section)
  section.Tab = self
  section.Elements = {}

  section.Frame = new("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
    Parent = self.Scroll,
  })
  new("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = section.Frame,
  })

  local head = new("Frame", {
    Size = UDim2.new(1, 0, 0, 22),
    BackgroundTransparency = 1,
    Parent = section.Frame,
  })
  local headLabel = text({
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 2, 0, 0),
    Text = title or "",
    TextSize = 11,
    Parent = head,
  }, true, "SubText")

  local dot = new("Frame", {
    Size = UDim2.new(0, 4, 0, 4),
    Position = UDim2.new(0, -8, 0.5, -2),
    BackgroundColor3 = Theme.Accent,
    Parent = headLabel,
  })
  corner(dot, 2)
  accentGradient(dot)

  section.Container = new("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
    Parent = section.Frame,
  })
  new("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = section.Container,
  })

  table.insert(self.Sections, section)
  return section
end

function Tab:Destroy()
  if self.Button then
    self.Button:Destroy()
  end
  if self.Page then
    self.Page:Destroy()
  end
end

--==================================================================================
-- 10 · Window
--==================================================================================

local Window = {}
Window.__index = Window

local currentWindow = nil

function MikaUI:CreateWindow(opts)
  opts = opts or {}
  currentWindow = nil

  local size = opts.Size or UDim2.fromOffset(640, 430)
  local titleText = opts.Title or "Mika UI"
  local subtitleText = opts.Subtitle or "make interfaces with Mika ui"
  local tabPosition = opts.TabPosition or "Left"
  local topBarVisible = opts.TopBar ~= false and true

  if opts.Theme then
    self:SetTheme(opts.Theme)
  end

  local gui = new("ScreenGui", {
    Name = opts.Name or "MikaUI",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = opts.DisplayOrder or 9999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = getGuiParent(),
  })
  protectGui(gui)

  local root = new("Frame", {
    Name = "Root",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = opts.Position or UDim2.fromScale(0.5, 0.5),
    Size = size,
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.02,
    Parent = gui,
    ClipsDescendants = true,
  })
  corner(root, 16)
  local rootStroke = stroke(root, "Stroke", 1, 0.45)
  table.insert(registry.colors, { inst = root, prop = "BackgroundColor3", key = "Background" })

  if Config.Blur and Lighting then
    local blur = Instance.new("BlurEffect")
    blur.Size = 12
    blur.Parent = Lighting
    root:SetAttribute("MikaBlur", blur)
  end

  -- top accent line
  local topLine = new("Frame", {
    Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = Theme.Accent,
    Parent = root,
  })
  accentGradient(topLine, "Accent", "Accent2", 0)

  local window = setmetatable({
    Gui = gui,
    Root = root,
    Title = titleText,
    Subtitle = subtitleText,
    Tabs = {},
    Selected = nil,
    Minimized = false,
  }, Window)

  -- title bar
  local barHeight = topBarVisible and 52 or 10
  local topBar = new("Frame", {
    Size = UDim2.new(1, 0, 0, barHeight),
    BackgroundTransparency = 1,
    Parent = root,
  })
  topBar.Active = true

  local icon = new("Frame", {
    Size = UDim2.new(0, 26, 0, 26),
    Position = UDim2.new(0, 16, 0, 13),
    BackgroundColor3 = Theme.Accent,
    Parent = topBar,
  })
  corner(icon, 8)
  accentGradient(icon, "Accent", "Accent2", 45)
  if opts.Icon and type(opts.Icon) == "string" then
    local image = new("ImageLabel", {
      Size = UDim2.new(1, 0, 1, 0),
      BackgroundTransparency = 1,
      Image = opts.Icon,
      Parent = icon,
    })
    corner(image, 8)
    icon.BackgroundTransparency = 1
  else
    local glyph = text({
      Size = UDim2.new(1, 0, 1, 0),
      Text = "M",
      TextSize = 14,
      TextXAlignment = Enum.TextXAlignment.Center,
      TextColor3 = Color3.fromRGB(255, 255, 255),
      Parent = icon,
    }, true)
    glyph.Text = string.upper(string.sub(titleText, 1, 1))
  end

  local titleLabel = text({
    Size = UDim2.new(0, 300, 0, 18),
    Position = UDim2.new(0, 52, 0, 13),
    Text = titleText,
    TextSize = 14,
    Parent = topBar,
  }, true)

  local subLabel = text({
    Size = UDim2.new(0, 300, 0, 14),
    Position = UDim2.new(0, 52, 0, 28),
    Text = subtitleText,
    TextSize = 10,
    Parent = topBar,
  }, false, "SubText")

  window.TitleLabel = titleLabel
  window.SubtitleLabel = subLabel

  local closeBtn = new("TextButton", {
    Size = UDim2.new(0, 22, 0, 22),
    Position = UDim2.new(1, -34, 0, 15),
    BackgroundColor3 = Theme.Surface,
    BackgroundTransparency = 0.2,
    Text = "x",
    TextColor3 = Theme.SubText,
    TextSize = 12,
    Font = Config.TitleFont,
    AutoButtonColor = false,
    Parent = topBar,
  })
  corner(closeBtn, 6)
  table.insert(registry.colors, { inst = closeBtn, prop = "BackgroundColor3", key = "Surface" })
  table.insert(registry.colors, { inst = closeBtn, prop = "TextColor3", key = "SubText" })
  table.insert(registry.fonts, { inst = closeBtn, bold = true })

  local minBtn = new("TextButton", {
    Size = UDim2.new(0, 22, 0, 22),
    Position = UDim2.new(1, -60, 0, 15),
    BackgroundColor3 = Theme.Surface,
    BackgroundTransparency = 0.2,
    Text = "-",
    TextColor3 = Theme.SubText,
    TextSize = 14,
    Font = Config.TitleFont,
    AutoButtonColor = false,
    Parent = topBar,
  })
  corner(minBtn, 6)
  table.insert(registry.colors, { inst = minBtn, prop = "BackgroundColor3", key = "Surface" })
  table.insert(registry.colors, { inst = minBtn, prop = "TextColor3", key = "SubText" })
  table.insert(registry.fonts, { inst = minBtn, bold = true })

  closeBtn.MouseButton1Click:Connect(function()
    window:Destroy()
  end)
  minBtn.MouseButton1Click:Connect(function()
    window:Minimize()
  end)
  closeBtn.MouseEnter:Connect(function()
    closeBtn.TextColor3 = Color3.fromRGB(255, 120, 140)
  end)
  closeBtn.MouseLeave:Connect(function()
    closeBtn.TextColor3 = Theme.SubText
  end)

  -- sidebar
  local sidebarWidth = opts.SidebarWidth or 152
  local sidebar = new("Frame", {
    Size = UDim2.new(0, sidebarWidth, 1, -barHeight - 16),
    Position = UDim2.new(0, 10, 0, barHeight + 6),
    BackgroundColor3 = Theme.Surface,
    BackgroundTransparency = 0.55,
    Parent = root,
  })
  corner(sidebar, 12)
  stroke(sidebar, "Stroke", 1, 0.75)
  table.insert(registry.colors, { inst = sidebar, prop = "BackgroundColor3", key = "Surface" })
  new("UIPadding", {
    PaddingTop = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 6),
    Parent = sidebar,
  })
  new("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    Parent = sidebar,
  })

  local contentArea = new("Frame", {
    Size = UDim2.new(1, -(sidebarWidth + 30), 1, -barHeight - 16),
    Position = UDim2.new(0, sidebarWidth + 20, 0, barHeight + 6),
    BackgroundTransparency = 1,
    Parent = root,
  })

  window.Sidebar = sidebar
  window.ContentArea = contentArea
  window.TopBar = topBar
  window.CloseButton = closeBtn

  -- watermark
  local watermark = text({
    Size = UDim2.new(0, 0, 0, 12),
    Position = UDim2.new(1, -12, 1, -8),
    Text = Config.Watermark.Text,
    TextSize = Config.Watermark.TextSize,
    TextColor3 = Theme.Text,
    TextTransparency = Config.Watermark.Transparency,
    TextXAlignment = Enum.TextXAlignment.Right,
    AutomaticSize = Enum.AutomaticSize.X,
    BackgroundTransparency = 1,
    Parent = root,
  })
  watermark.AnchorPoint = Vector2.new(1, 1)
  watermark.ZIndex = 50
  watermark.Visible = Config.Watermark.Visible
  table.insert(registry.watermarks, watermark)
  window.Watermark = watermark

  makeDraggable(root, topBar)

  -- toggle key
  local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
  UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
      return
    end
    if input.KeyCode == toggleKey and not window.Locked then
      window:Toggle()
    end
  end)

  -- intro animation
  if Config.Animations then
    root.BackgroundTransparency = 1
    tween(root, { BackgroundTransparency = 0.02 }, TweenInfo.new(0.25, Enum.EasingStyle.Quad))
  end

  currentWindow = window
  return window
end

function Window:CreateTab(name, icon)
  local tab = setmetatable({
    Name = name,
    Window = self,
    Sections = {},
  }, Tab)

  local button = new("TextButton", {
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundColor3 = Theme.SurfaceHigh,
    BackgroundTransparency = 1,
    Text = "",
    AutoButtonColor = false,
    LayoutOrder = #self.Tabs + 1,
    Parent = self.Sidebar,
  })
  corner(button, 8)
  table.insert(registry.colors, { inst = button, prop = "BackgroundColor3", key = "SurfaceHigh" })

  local indicator = new("Frame", {
    Size = UDim2.new(0, 3, 0, 14),
    Position = UDim2.new(0, 0, 0.5, -7),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 1,
    Parent = button,
  })
  corner(indicator, 2)
  accentGradient(indicator)

  local tabLabel = text({
    Size = UDim2.new(1, -30, 1, 0),
    Position = UDim2.new(0, icon and 30 or 12, 0, 0),
    Text = name,
    TextSize = 12,
    Parent = button,
  })

  if icon and type(icon) == "string" then
    local image = new("ImageLabel", {
      Size = UDim2.new(0, 16, 0, 16),
      Position = UDim2.new(0, 10, 0.5, -8),
      BackgroundTransparency = 1,
      Image = icon,
      ImageColor3 = Theme.SubText,
      Parent = button,
    })
    table.insert(registry.colors, { inst = image, prop = "ImageColor3", key = "SubText" })
  end

  local page = new("CanvasGroup", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Visible = false,
    GroupTransparency = 1,
    Parent = self.ContentArea,
  })

  local scroll = new("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Theme.Accent,
    ScrollBarImageTransparency = 0.45,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png",
    BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png",
    Parent = page,
  })
  new("UIPadding", {
    PaddingRight = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 18),
    Parent = scroll,
  })
  new("UIListLayout", {
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = scroll,
  })

  tab.Button = button
  tab.Label = tabLabel
  tab.Indicator = indicator
  tab.Page = page
  tab.Scroll = scroll

  button.MouseEnter:Connect(function()
    if self.Selected ~= tab then
      tween(button, { BackgroundTransparency = 0.65 })
    end
  end)
  button.MouseLeave:Connect(function()
    if self.Selected ~= tab then
      tween(button, { BackgroundTransparency = 1 })
    end
  end)
  button.MouseButton1Click:Connect(function()
    self:SelectTab(tab)
  end)

  table.insert(self.Tabs, tab)

  if #self.Tabs == 1 or tab.Name == self.StartTab then
    self:SelectTab(tab)
  end

  return tab
end

function Window:SelectTab(tab)
  if not tab or self.Selected == tab then
    return
  end
  if self.Selected then
    local previous = self.Selected
    tween(previous.Page, { GroupTransparency = 1 })
    previous.Page.Visible = false
    tween(previous.Button, { BackgroundTransparency = 1 })
    tween(previous.Indicator, { BackgroundTransparency = 1 })
    previous.Label.TextColor3 = Theme.SubText
  end
  self.Selected = tab
  tab.Page.Visible = true
  tab.Page.GroupTransparency = 1
  tween(tab.Page, { GroupTransparency = 0 })
  tween(tab.Button, { BackgroundTransparency = 0.55 })
  tween(tab.Indicator, { BackgroundTransparency = 0 })
  tab.Label.TextColor3 = Theme.Text
end

function Window:SetTitle(value)
  local label = self.TitleLabel
  if label then
    label.Text = value
  end
end

function Window:SetSubtitle(value)
  local label = self.SubtitleLabel
  if label then
    label.Text = value
  end
end

function Window:SetToggleKey(key)
  self.ToggleKey = key
end

function Window:Minimize()
  self.Minimized = not self.Minimized
  if self.Minimized then
    self.RestoreSize = self.Root.Size
    tween(self.Root, { Size = UDim2.new(self.Root.Size.X.Scale, self.Root.Size.X.Offset, 0, 52) })
    self.Sidebar.Visible = false
    self.ContentArea.Visible = false
  else
    tween(self.Root, { Size = self.RestoreSize or UDim2.fromOffset(640, 430) })
    self.Sidebar.Visible = true
    self.ContentArea.Visible = true
  end
end

function Window:Toggle()
  self.Root.Visible = not self.Root.Visible
end

function Window:Destroy()
  if self.Gui then
    self.Gui:Destroy()
  end
  local blur = self.Root and self.Root:GetAttribute("MikaBlur")
  if blur and typeof(blur) == "Instance" then
    blur:Destroy()
  end
end

--==================================================================================
-- 11 · Public customization API
--==================================================================================

function MikaUI:GetTheme()
  return Theme, Config.Theme
end

function MikaUI:ListThemes()
  local names = {}
  for name in pairs(Themes) do
    table.insert(names, name)
  end
  table.sort(names)
  return names
end

function MikaUI:SetTheme(theme)
  local source = nil
  if type(theme) == "string" then
    source = Themes[theme]
    if not source then
      return false, "unknown theme: " .. theme
    end
    Config.Theme = theme
  elseif type(theme) == "table" then
    source = theme
    Config.Theme = "Custom"
  else
    return false, "theme must be a name or a table"
  end

  for key, value in pairs(source) do
    if key ~= "Font" and key ~= "TitleFont" then
      local parsed = parseColor(value)
      if parsed then
        Theme[key] = parsed
      end
    end
  end
  if source.Font then
    Config.Font = source.Font
  end
  if source.TitleFont then
    Config.TitleFont = source.TitleFont
  end

  refreshColors()
  refreshGradients()
  refreshFonts()
  return true
end

function MikaUI:SetAccent(color)
  local parsed = parseColor(color)
  if not parsed then
    return false, "invalid color"
  end
  Theme.Accent = parsed
  refreshColors()
  refreshGradients()
  return true
end

function MikaUI:SetAccentGradient(colorA, colorB)
  local a = parseColor(colorA)
  local b = parseColor(colorB)
  if not a or not b then
    return false, "invalid color"
  end
  Theme.Accent = a
  Theme.Accent2 = b
  refreshColors()
  refreshGradients()
  return true
end

function MikaUI:SetFont(font)
  if not font then
    return false
  end
  Config.Font = font
  refreshFonts()
  return true
end

function MikaUI:SetTitleFont(font)
  if not font then
    return false
  end
  Config.TitleFont = font
  refreshFonts()
  return true
end

function MikaUI:SetCornerRadius(radius)
  if type(radius) ~= "number" then
    return false
  end
  Config.CornerRadius = radius
  refreshCorners()
  return true
end

function MikaUI:SetTransparency(opts)
  opts = opts or {}
  if type(opts) == "number" then
    opts = { window = opts }
  end
  if opts.window and currentWindow then
    Config.WindowTransparency = opts.window
    tween(currentWindow.Root, { BackgroundTransparency = opts.window })
  end
  if opts.element then
    Config.ElementTransparency = opts.element
    for row, state in pairs(registry.rows) do
      if row.Parent then
        state.base = opts.element
        row.BackgroundTransparency = opts.element
      end
    end
  end
  return true
end

function MikaUI:SetAnimations(enabled)
  Config.Animations = enabled and true or false
  return true
end

function MikaUI:SetAnimationSpeed(seconds)
  Config.AnimSpeed = tonumber(seconds) or Config.AnimSpeed
  return true
end

function MikaUI:SetBlur(enabled)
  Config.Blur = enabled and true or false
  if not Lighting then
    return false
  end
  if enabled then
    local blur = Lighting:FindFirstChild("MikaUIBlur") or Instance.new("BlurEffect")
    blur.Name = "MikaUIBlur"
    blur.Size = 12
    blur.Parent = Lighting
  else
    local existing = Lighting:FindFirstChild("MikaUIBlur")
    if existing then
      existing:Destroy()
    end
  end
  return true
end

function MikaUI:SetWatermark(opts)
  if type(opts) == "string" then
    opts = { Text = opts }
  end
  opts = opts or {}
  if opts.Text then
    Config.Watermark.Text = opts.Text
  end
  if opts.Transparency then
    Config.Watermark.Transparency = math.clamp(opts.Transparency, 0, 1)
  end
  if opts.TextSize then
    Config.Watermark.TextSize = opts.TextSize
  end
  if opts.Visible ~= nil then
    Config.Watermark.Visible = opts.Visible and true or false
  end
  refreshWatermarks()
  return true
end

function MikaUI:Fetch(url)
  return fetchReadable(url)
end

function MikaUI:OpenLink(url)
  if not url then
    return false
  end
  local copied = false
  if setclipboard then
    pcall(setclipboard, url)
    copied = true
  elseif toclipboard then
    pcall(toclipboard, url)
    copied = true
  end
  local openFn = (syn and syn.open_browser) or (syn and syn.openbrowser)
  if openFn then
    pcall(openFn, url)
  elseif openbrowser then
    pcall(openbrowser, url)
  end
  self:Notify({
    Title = "Link",
    Content = copied and ("Copied to clipboard:\n" .. url) or url,
    Duration = 4,
  })
  return true
end

function MikaUI:LoadThemeFromURL(url)
  local body, err = httpGet(url)
  if not body then
    return false, err or "could not fetch theme"
  end
  local ok, decoded = pcall(function()
    return HttpService:JSONDecode(body)
  end)
  if not ok or type(decoded) ~= "table" then
    return false, "invalid theme JSON"
  end
  return self:SetTheme(decoded)
end

function MikaUI:GetConfig()
  local snapshot = {}
  for key, value in pairs(Config) do
    if type(value) ~= "table" then
      snapshot[key] = tostring(value)
    end
  end
  return snapshot
end

return MikaUI
