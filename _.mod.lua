--[[
	Custom Font Tools
	A system that uses spritesheets to produce unique font style for use in game
	@author EgoMoose
	@link http://www.roblox.com/Rbx-CustomFont-item?id=230767320
	@date 19/10/2016
--]]

-- Github	: https://github.com/EgoMoose/Rbx_CustomFont
-- Fonts 	: https://github.com/EgoMoose/Rbx_CustomFont/wiki/Creating-your-own-font

------------------------------------------------------------------------------------------------------------------------------
--// Setup

local fonts = script
local content = game:GetService("ContentProvider")

------------------------------------------------------------------------------------------------------------------------------
--// Built-in local declerations

local pairs = pairs
local type = type
local pcall = pcall
local unpack = unpack
local tostring = tostring
local tonumber = tonumber

local abs = math.abs
local min = math.min
local max = math.max

local sort = table.sort

local udim2 = UDim2.new
local color3 = Color3.new
local vector2 = Vector2.new
local instance = Instance.new

------------------------------------------------------------------------------------------------------------------------------
--// Other declerations

local IMGFRAME = instance("ImageLabel")
IMGFRAME.Size = udim2(0, 0, 0, 0)
IMGFRAME.BackgroundTransparency = 1
IMGFRAME.ScaleType = Enum.ScaleType.Stretch

local REPLACE = ("?"):byte()

local justify1 = {
	["Right"] = true,
	["Bottom"] = true
}

local justify0 = {
	["Left"] = true,
	["Top"] = true
}

local redraws = {
	["AbsoluteSize"] = true,
	["TextWrapped"] = true,
	["TextScaled"] = true,
	["TextXAlignment"] = true,
	["TextYAlignment"] = true
}

local overwrites = {
	["TextTransparency"] = true,
	["TextStrokeTransparency"] = true,
	["BackgroundTransparency"] = true
}

local noReplicate = {
	["AbsolutePosition"] = true,
	["AbsoluteSize"] = true,
	["Position"] = true,
	["Size"] = true,
	["Rotation"] = true,
	["Parent"] = true
}

local customProperties = {
	["FontName"] = true,
	["Style"] = true
}

------------------------------------------------------------------------------------------------------------------------------
--// Static functions

local function getAlignMultiplier(enum)
	return (justify1[enum.Name] and 1) or (justify0[enum.Name] and 0) or 0.5
end

local function getClosestNumber(n, set)
	sort(set, function(a, b) return abs(n - a) < abs(n - b) end)
	return set[1]
end

-- wrapper function

local function wrapper(child, addition)
	local this = newproxy(true)
	local mt = getmetatable(this)
	mt.__index = function(t, k) return addition[k] or child[k] end
	mt.__newindex = function(t, k, v) if addition[k] then addition[k] = v else child[k] = v end end
	mt.__call = function() return child end
	mt.__tostring = function(t) return tostring(child) end
	mt.__metatable = "The metatable is locked."
	return this
end

-- background stuff

local function defaultHide(child)
	child.TextTransparency = 2
	child.BackgroundTransparency = 2
	child.TextStrokeTransparency = 2
end

local function newBackground(child, class)
	local frame = instance("Frame")
	frame.Name = "_background"
	frame.Size = udim2(1, 0, 1, 0)
	frame.BackgroundTransparency = child.BackgroundTransparency
	frame.BackgroundColor3 = child.BackgroundColor3
	frame.BorderSizePixel = child.BorderSizePixel
	frame.BorderColor3 = child.BorderColor3
	frame.ZIndex = child.ZIndex
	frame.Parent = child
	if class == "TextButton" then
		frame.MouseEnter:Connect(function()
			if child.AutoButtonColor then 
				local origin = child.BackgroundColor3
				frame.BackgroundColor3 = color3(origin.r - 75/255, origin.g - 75/255, origin.b - 75/255) 
			end
		end)
		child.MouseLeave:Connect(function()
			if child.AutoButtonColor then
				frame.BackgroundColor3 = child.BackgroundColor3
			end
		end)
	end
	return frame
end

-- functions for grabbing data from input strings

local function split(text, pattern)
	local t = { }
	local lp = 0
	while true do
		local p = text:find(pattern, lp, true)
		if p then
			t[#t + 1] = text:sub(lp, p - 1)
			lp = p + 1
		else
			t[#t + 1] = text:sub(lp)
			break
		end
	end
	return t
end

local function getLines(text)
	local text = text:gsub("\t", (" "):rep(4))
	return split(text, "\n")
end

local function getWords(text, includeNewLines)
	local text = text:gsub("\t", (" "):rep(4))
	local lines , words = split(text, "\n"), { }
	local nlines = #lines
	for i = 1, nlines do
		local line = lines[i]
		for word in line:gmatch(" *[^%s]+ *") do
			words[#words + 1] = word
		end
		if includeNewLines and i < nlines then
			words[#words + 1] = "\n" 
		end
	end
	return words
end

-- functions for calculating data for text from spritesheets

local function getStringWidth(text, sizeSet)
	local length, ntext = 0, #text
	for i = 1, ntext do
		local i2 = i + 1 <= #text and i + 1
		local b = text:sub(i, i):byte()
		local b2 = i2 and text:sub(i2, i2):byte()
		local character = sizeSet.characters[b]
		local kernx = 0
		if b2 and sizeSet.kerning[b] and sizeSet.kerning[b][b2] then
			kernx = sizeSet.kerning[b][b2].x
		end
		length = length + sizeSet.characters[b].xadvance + kernx
	end
	return length
end

local function getMaxHeight(text, sizeSet)
	local mheight, ntext = 0, #text
	for i = 1, ntext do
		local b = text:sub(i, i):byte()
		local character = sizeSet.characters[b]
		local height = sizeSet.characters[b].height + sizeSet.characters[b].yoffset
		if height > mheight then
			mheight = height
		end
	end
	return mheight
end

-- functions for formatting spritesheet strings

local function wrapText(text, size, settings)
	local index = 1
	local lines, words = { "" }, getWords(text, true)
	local lineWidth, maxWidth = 0, abs(settings.child.AbsoluteSize.X)
	for i = 1, #words do
		local word = words[i]
		if word ~= "\n" then
			local width = getStringWidth(word, settings.styles[settings.style][size])
			if width + lineWidth <= maxWidth then
				lines[index] = lines[index] .. word
			else
				lineWidth = 0
				index = index + 1
				lines[index] = word
			end
			lineWidth = lineWidth + width
		else
			lineWidth = 0
			index = index + 1
			lines[index] = ""
		end
	end
	return lines
end

function scaleText(text, settings)
	local child = settings.child
	local attached = settings.attached

	sort(settings.information.sizes, function(a, b) return a > b end)
	local bestSize = settings.information.sizes[1]
	local broke = false
	
	for i = 1, #settings.information.sizes do
		local size = settings.information.sizes[i]
		local sizeSet = settings.styles[settings.style][size]
		local lines = child.TextWrapped and wrapText(text, size, settings) or getLines(text)
	
		local widths = { }
		local height = -sizeSet.firstAdjust
		for j = 1, #lines do
			local line = lines[j]
			height = height + getMaxHeight(line, sizeSet)
			widths[#widths + 1] = getStringWidth(line, sizeSet)
		end
		
		local width = max(unpack(widths))
		if width <= abs(child.AbsoluteSize.X) and height <= abs(child.AbsoluteSize.Y) then
			bestSize = size
			broke = true
			break
		end
	end
	
	return broke and bestSize or settings.information.sizes[#settings.information.sizes]
end

-- functions for drawing

local function drawSprite(byte, nextByte, settings)
	local sprite = IMGFRAME:Clone()
	local child = settings.child
	local attached = settings.attached
	
	local sizeSet = settings.styles[settings.style][settings.size]
	local character = sizeSet.characters[byte]
	
	-- fill in the defining properties
	sprite.Name = byte
	sprite.ImageColor3 = child.TextColor3
	sprite.ImageTransparency = attached.TextTransparency
	sprite.ZIndex = child.ZIndex
	
	-- setup the image
	sprite.Image = settings.atlases[character.atlas + 1]
	sprite.ImageRectSize = vector2(character.width, character.height)
	sprite.ImageRectOffset = vector2(character.x, character.y)
	
	-- kerning
	local kernx, kerny = 0, 0
	if nextByte and sizeSet.kerning[byte] and sizeSet.kerning[byte][nextByte] then
		local k = sizeSet.kerning[byte][nextByte]
		kernx = k.x
		kerny = k.y
	end
	
	-- positioning
	sprite.Position = udim2(0, kernx, 0, character.yoffset + kerny)
	sprite.Size = udim2(0, character.width, 0, character.height)
	
	return sprite, kernx, kerny + character.yoffset + character.height
end

local function drawLine(text, height, gsprites, settings)
	local width = 0
	local maxheight = 0
	local sprites = { }

	local child = settings.child
	local attached = settings.attached
	
	local ntext = #text
	local sizeSet = settings.styles[settings.style][settings.size]
	
	for i = 1, ntext do
		local i2 = i + 1 <= ntext and i + 1
		local b = text:sub(i, i):byte()
		local b2 = i2 and text:sub(i2, i2):byte()
		local character, kernx, mheight = drawSprite(b, b2, settings)
		maxheight = mheight > maxheight and mheight or maxheight
		character.Position = character.Position + udim2(0, width, 0, height)
		width = width + (i2 and sizeSet.characters[b].xadvance or sizeSet.characters[b].width) + kernx
		sprites[#sprites + 1] = character
		gsprites[#gsprites + 1] = character
	end
	
	local xalign = getAlignMultiplier(child.TextXAlignment)
	local adjust = (abs(child.AbsoluteSize.X) - width) * xalign
	for i = 1, ntext do
		local character = sprites[i]
		character.Position = character.Position + udim2(0, adjust, 0, 0)
	end
	
	return width, maxheight
end

local function drawLines(text, settings, parent)
	local child = settings.child	
	
	if child.TextScaled then
		settings.size = scaleText(text, settings)
	end

	local lines = child.TextWrapped and wrapText(text, settings.size, settings) or getLines(text)
	local lineHeight = settings.styles[settings.style][settings.size].lineHeight
	
	local widths = { 0 }
	local height = -settings.styles[settings.style][settings.size].firstAdjust
	local sprites = { }
	
	for i = 1, #lines do
		local line = lines[i]
		local width, lh = drawLine(line, height, sprites, settings)
		height = height + lh
		widths[#widths + 1] = width
	end
	
	local yalign = getAlignMultiplier(child.TextYAlignment)
	local adjust = (abs(child.AbsoluteSize.Y) - height) * yalign
	for i = 1, #sprites do
		local character = sprites[i]
		character.Position = character.Position + udim2(0, 0, 0, adjust)
		character.Parent = parent
	end
	
	return sprites
end
------------------------------------------------------------------------------------------------------------------------------
--// Classes

local event = { }

function event.new(t)
	local evnts = { }
	local self = setmetatable({ }, {
		__index = t,
		__newindex = function(tt, k, v)
			if t[k] ~= v then
				t[k] = v
				if type(evnts[k]) == "function" then
					evnts[k](v)
				end
			end
		end,
		__metatable = "The metatable is locked."
	})
	
	function self:Connect(k, f)
		evnts[k] = f
	end
	
	return self
end

local settings = { }

function settings.new(fontModule, attached, child)
	local self = setmetatable({ }, { __index = settings })
	
	settings.child = child
	settings.attached = attached
	
	-- place data in new format for easy access
	self.information = fontModule.font.information
	self.atlases = fontModule.atlases
	self.styles = fontModule.font.styles
	
	-- sort from least to greatest
	sort(self.information.sizes, function(a, b) return a > b end)
	
	-- establish some settings variables
	self.style = self.information.styles[1]
	self.size = child.TextSize
	
	-- failsafes
	for styleName, style in pairs(self.styles) do
		-- characters that DNE
		for sizeName, size in pairs(style) do
			setmetatable(size.characters, {
				__index = function(t, k)
					local k = tostring(k)
					local v = rawget(t, k)
					if not v then
						warn(k, "is not a valid character. Replaced with, \"" .. REPLACE:char() .. "\"")
						return rawget(t, tostring(REPLACE))
					end
					return v
				end
			})
		end
		-- sizes that DNE
		setmetatable(style, {
			__index = function(t, k)
				local k = tostring(k)
				local v = rawget(t, k)
				if not v then
					local closest = getClosestNumber(k, self.information.sizes)
					self.size = closest
					child.TextSize = closest
					warn(k, "is not a valid size. Using the closest size,", closest)
					return rawget(t, tostring(closest))
				end
				return v
			end
		})
	end
	-- styles that DNE
	setmetatable(self.styles, {
		__index = function(t, k)
			local v = rawget(t, k)
			if not v then 
				local nstyle = self.information.styles[1]
				self.style = nstyle
				attached.Style = nstyle
				warn(k, "is not a valid style. Using first style found", nstyle)
				return rawget(t, nstyle)
			end
			return v
		end
	})
	
	return self
end

function settings:preload()
	for _, atlas in pairs(self.atlases) do
		content:Preload(atlas)
	end
end

-- custom font class (this is what the player interacts with)

local customFont = { }

function customFont.new(fontName, class, isButton)
	local self = event.new { }
	
	local exists = not (type(class) == "string")
	local child = exists and class or instance(class)
	local fontModule = fonts:FindFirstChild(fontName)
	--local folder = instance("Folder", child)
	
	local settings = settings.new(require(fontModule), self, child)
	settings:preload()
	
	local events = { }
	local properties = { }
	local propertyobjects = { }
	local drawncharacters = { }
	
	self.FontName = fontName
	self.Style = settings.style
	self.TextTransparency = child.TextTransparency
	self.TextStrokeTransparency = child.TextStrokeTransparency
	self.BackgroundTransparency = child.BackgroundTransparency
	self.TextFits = false
	
	-- create the physical representation of the custom properties
	for name, _ in pairs(customProperties) do
		local property = self[name]
		local t = type(property)
		local className = t:sub(1, 1):upper() .. t:sub(2) .. "Value"
		local physicalProperty = instance(className, child)
		
		physicalProperty.Name = name
		physicalProperty.Value = property
		
		physicalProperty.Changed:Connect(function(newValue)
			self[name] = newValue
		end)
		
		propertyobjects[physicalProperty.Name] = physicalProperty
		properties[physicalProperty] = true
	end
	
	local background = newBackground(child, isButton and "TextButton")
	defaultHide(child)	
	
	-- common function
	
	local function drawText()
		background:ClearAllChildren()
		drawncharacters = drawLines(child.Text, settings, background)
	end
	
	-- custom events
	
	self:Connect("FontName", function(value) drawText() end)
	self:Connect("TextStrokeTransparency", function(value) drawText() end)
	
	self:Connect("BackgroundTransparency", function(value)
		background.BackgroundTransparency = value
	end)
	
	self:Connect("Style", function(value)
		settings.style = value
		propertyobjects["Style"].Value = value
		drawText()
	end)
	
	self:Connect("TextTransparency", function(value)
		for i = 1, #drawncharacters do
			drawncharacters[i].ImageTransparency = value
		end
	end)
	
	self:Connect("FontName", function(value)
		local fontModule = fonts:FindFirstChild(value)
		settings = settings.new(require(fontModule), self, child)
		settings:preload()
		propertyobjects["FontName"].Value = value
		if not child.TextScaled then
			settings.size = child.TextSize
		end
		settings.style = self.Style
		drawText()
	end)
	
	-- real events
	
	events[#events + 1] = child.Changed:Connect(function(property)
		if overwrites[property] then	
			if child[property] ~= 2 then
				self[property] = child[property]	
			end
			child[property] = 2
		elseif property == "TextSize" then
			settings.size = child[property]
			drawText()
		elseif property == "TextColor3" then
			for _, sprite in pairs(drawncharacters) do
				sprite.ImageColor3 = child[property]
			end
		elseif property == "ZIndex" then
			background.ZIndex = child[property]
			for _, sprite in pairs(drawncharacters) do
				sprite.ZIndex = child[property]
			end
		elseif property == "Text" then
			drawText()
		elseif redraws[property] then
			if property == "TextScaled" and not child[property] then
				settings.size = child.TextSize
			end
			drawText()
		elseif not property:match("Text") and not noReplicate[property] then
			pcall(function() background[property] = child[property] end)
		end
	end)
	
	if child:IsA("TextBox") then
		events[#events + 1] = child.Focused:Connect(function()
			if child.ClearTextOnFocus then
				child.Text = ""
			end
		end)
	end
	
	-- methods
	
	function self:Revert()
		for _, property in pairs(propertyobjects) do property:Destroy() end
		for _, event in pairs(events) do event:Disconnect() end
		background:Destroy()
		child.TextTransparency = self.TextTransparency
		child.BackgroundTransparency = self.BackgroundTransparency
		self, properties, propertyobjects, events = nil, nil, nil, nil
		return child
	end
	
	function self:GetChildren()
		local children = { }
		for _, kid in pairs(child:GetChildren()) do
			if kid ~= background and not properties[kid] then
				children[#children + 1] = kid
			end
		end
		return children
	end
	
	function self:ClearAllChildren()
		for _, kid in pairs(child:GetChildren()) do
			if kid ~= background and not properties[kid] then
				kid:Destroy()
			end
		end
	end
	
	function self:Destroy()
		self:Revert():Destroy()
	end
	
	-- return
	drawText()
	return wrapper(child, self)
end

------------------------------------------------------------------------------------------------------------------------------
--// Module

local module = { }
for _, class in pairs({ "TextLabel", "TextBox", "TextButton", "TextReplace" }) do
	module[class:sub(5)] = function(fontName, child)
		return customFont.new(fontName, class == "TextReplace" and child or class, class == "TextButton" or (class == "TextReplace" and child:IsA("TextButton")))
	end
end

wait() -- top bar can mess with stuff if fonts called instantly

return module
