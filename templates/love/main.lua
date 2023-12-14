--[[
    test
]]

local WIDTH = 500
local HEIGHT = 500

function love.load()
    love.window.setMode(WIDTH, HEIGHT)
end

function love.draw()
    love.graphics.print("Hello World", 215, 250)
end
