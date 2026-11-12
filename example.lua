--[[
	example.lua  ·  Mika UI showcase
	Paste this into your executor after replacing the URL with your repo raw link.
]]

local MikaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/vexzinho0/Mika-UI/main/MikaUI.lua"))()

-- ---------------------------------------------------------------- customization
MikaUI:SetTheme("Aurora")                                   -- Aurora | Midnight | Sakura | Neon | Mono | Void | Daylight
MikaUI:SetAccentGradient(Color3.fromRGB(124, 164, 255), Color3.fromRGB(190, 138, 255))
MikaUI:SetCornerRadius(12)
MikaUI:SetAnimationSpeed(0.18)
MikaUI:SetWatermark({ Text = "make interfaces with Mika ui", Transparency = 0.86, Visible = true })
-- MikaUI:SetFont(Enum.Font.SourceSans)                     -- any Enum.Font
-- MikaUI:SetTheme({ Accent = "#7aa4ff", Background = { 14, 16, 24 } }) -- custom theme
-- MikaUI:LoadThemeFromURL("https://example.com/mika-theme.json")

-- ---------------------------------------------------------------------- window
local Window = MikaUI:CreateWindow({
	Title = "Mika UI",
	Subtitle = "make interfaces with Mika ui",
	Size = UDim2.fromOffset(680, 460),
	ToggleKey = Enum.KeyCode.RightShift,
})

-- ------------------------------------------------------------------------ tabs
local MainTab = Window:CreateTab("Main")
local VisualTab = Window:CreateTab("Visuals")
local LinksTab = Window:CreateTab("Links")

-- ---------------------------------------------------------------------- main
local General = MainTab:CreateSection("General")

General:CreateLabel({
	Name = "Welcome",
	Text = "Mika UI is a single file library. Every element below is live — toggle, drag, type and reload.",
})

General:CreateButton({
	Name = "Notify me",
	Description = "Fires a notification in the corner",
	Callback = function()
		MikaUI:Notify({
			Title = "Mika UI",
			Content = "make interfaces with Mika ui",
			Duration = 4,
		})
	end,
})

local enabled = General:CreateToggle({
	Name = "Feature enabled",
	Description = "Showcases the animated switch",
	Default = true,
	Callback = function(value)
		print("toggle:", value)
	end,
})

local speed = General:CreateSlider({
	Name = "Speed",
	Min = 0,
	Max = 200,
	Default = 42,
	Step = 1,
	Suffix = " km/h",
	Callback = function(value)
		print("slider:", value)
	end,
})

local mode = General:CreateDropdown({
	Name = "Mode",
	Options = { "Legit", "Rage", "Silent", "Custom" },
	Default = "Legit",
	Callback = function(value)
		print("dropdown:", value)
	end,
})

local extras = General:CreateDropdown({
	Name = "Extras",
	Multi = true,
	Options = { "ESP", "Aimbot", "Tracers", "FOV", "Crosshair" },
	Default = { "ESP", "FOV" },
	Callback = function(values)
		print("multi:", table.concat(values, ", "))
	end,
})

General:CreateDivider()

General:CreateInput({
	Name = "Webhook",
	Placeholder = "https://discord.com/api/webhooks/...",
	Callback = function(text, enter)
		print("input:", text, enter)
	end,
})

General:CreateKeybind({
	Name = "Menu key",
	Default = Enum.KeyCode.RightShift,
	Callback = function(key)
		print("keybind:", key.Name)
	end,
})

-- -------------------------------------------------------------------- visual
local Look = VisualTab:CreateSection("Appearance")

Look:CreateColorPicker({
	Name = "Accent color",
	Default = Color3.fromRGB(124, 164, 255),
	Callback = function(color)
		MikaUI:SetAccent(color)
	end,
})

local themeDrop = Look:CreateDropdown({
	Name = "Theme",
	Options = MikaUI:ListThemes(),
	Default = "Aurora",
	Callback = function(name)
		MikaUI:SetTheme(name)
	end,
})

Look:CreateSlider({
	Name = "Window transparency",
	Min = 0,
	Max = 1,
	Default = 0.04,
	Step = 0.01,
	Callback = function(value)
		MikaUI:SetTransparency({ window = value })
	end,
})

Look:CreateSlider({
	Name = "Corner radius",
	Min = 0,
	Max = 24,
	Default = 12,
	Step = 1,
	Callback = function(value)
		MikaUI:SetCornerRadius(value)
	end,
})

Look:CreateToggle({
	Name = "Animations",
	Default = true,
	Callback = function(value)
		MikaUI:SetAnimations(value)
	end,
})

-- --------------------------------------------------------- external in-hub view
local Remote = LinksTab:CreateSection("External content")

Remote:CreateExternalView({
	Name = "Loaded page",
	Url = "https://example.com",
	Height = 190,
})

Remote:CreateExternalView({
	Name = "Plain text / raw file",
	Url = "https://raw.githubusercontent.com/vexzinho0/Mika-UI/main/README.md",
	Height = 160,
	AutoLoad = false,
})

Remote:CreateLinkButton({
	Name = "Open repository",
	Description = "Copies the link and notifies",
	Url = "https://github.com/vexzinho0/Mika-UI",
})

Remote:CreateLabel({
	Text = "Tip: any element created above can be changed later with :Set(value).",
})

-- --------------------------------------------------------------------- demo
task.delay(1, function()
	MikaUI:Notify({ Title = "Ready", Content = "Mika UI loaded successfully.", Duration = 4 })
end)
