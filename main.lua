print(string.format("LOVE %s.%s.%s (%s)", love.getVersion()))

-- Modules
require("patches")
local colors = require("colors")
local screen = require("screen")
local colorgrid = require("colorgrid")
local palette = require("palette")

-- Settings
local backgroundColor = colors.darkgrey
local canvasBounds = { x = 0, y = 0, w = C.screenWidth, h = C.screenHeight - 10 }
local paletteRenderPos = { x = 0, y = canvasBounds.y + canvasBounds.h + 1 }
local cursorStart = 30

function love.load()
	colorgrid:init(7, 7)
	palette:init()
    screen:init(C.screenWidth, C.screenHeight)
	require("palettes.basic_rainbow")
end

function love.update(dt)
    local shouldDraw = false
    local x, y = love.mouse.getPosition()
    x, y = screen:localize(x, y)
    if x >= canvasBounds.x and x - canvasBounds.x < canvasBounds.w and
    y >= canvasBounds.y and y - canvasBounds.y < canvasBounds.h then
		local color
        if love.mouse.isDown(1) then
			color = palette:getColor("primary")
        elseif love.mouse.isDown(2) then
			color = palette:getColor("secondary")
        end
		if color then
			-- if drawing with the background, use eraser instead
			if color == backgroundColor then
				color = colors.transparent
			end
            screen:draw(function(w, h)
                love.graphics.setBlendMode("replace")
                love.graphics.setColor(color)
                love.graphics.points({x, y})
            end)
		end
    end
	if love.keyboard.isDown("space") then
		backgroundColor = palette:getColor("secondary")
	end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.push("quit")
    end
end

function love.mousepressed(x, y, button)
	-- turn window pos to pixel pos
	local x, y = screen:localize(x, y)
	local sx, sy = paletteRenderPos.x, paletteRenderPos.y
	-- check if in palette bounds
	if x >= sx and x - sx < colorgrid.width and
	y >= sy and y - sy < colorgrid.height then
		-- clicked on palette
		if button == 1 then
			-- left click a cell
			palette:setPos(x - sx, y - sy, "primary")
		elseif button == 2 then
			-- right click a cell
			palette:setPos(x - sx, y - sy, "secondary")
		end
	end
end

function love.draw()
    love.graphics.clear(backgroundColor)
    screen:draw(function(w, h)
		-- Draw splitter
        love.graphics.setBlendMode("replace")
		love.graphics.setColor(colors.white)
		local splitter = canvasBounds.y + canvasBounds.h
		love.graphics.line(0, splitter, C.screenWidth-1, splitter)
		-- Draw selected colors
		love.graphics.setColor(palette:getColor("primary"))
		love.graphics.line(cursorStart, splitter, cursorStart + 1, splitter)
		love.graphics.setColor(palette:getColor("secondary"))
		love.graphics.line(cursorStart + 3, splitter, cursorStart + 4, splitter)
		-- Draw palette
        palette:render(paletteRenderPos.x, paletteRenderPos.y)
    end)
    screen:renderToWindow()
	--Draw grid
	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(colors.red)
	love.graphics.translate(canvasBounds.x + 0.5, canvasBounds.y + 0.5)
	for x = 0, (canvasBounds.w - 1) * C.pixelSize, 4 * C.pixelSize do
		love.graphics.line(x, 0, x, canvasBounds.h * C.pixelSize - 1)
	end
	for y = 0, (canvasBounds.h - 1) * C.pixelSize, 4 * C.pixelSize do
		love.graphics.line(0, y, canvasBounds.w * C.pixelSize - 1, y)
	end

end
