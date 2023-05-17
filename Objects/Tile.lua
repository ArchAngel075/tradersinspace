-- Import the rxi/classic library
local class = require "libs.classic.classic"

-- Define the Tile class
local Tile = class:extend()
Tile.SIZE = 64;

-- Constructor for Tile class
function Tile:new(x, y)
  self.x = x
  self.y = y
end

function Tile:update(dt)
end

-- Draw method for Tile class
function Tile:draw()
    love.graphics.push();
    love.graphics.translate(self.SIZE*self.x - self.SIZE, self.SIZE*self.y - self.SIZE)
    love.graphics.setColor(0.63, 0.63, 0.63)  -- Set color for tile (white in this example)
    love.graphics.rectangle("fill", self.x, self.y, self.SIZE, self.SIZE)  -- Draw a square for the tile
    love.graphics.setColor(0, 0, 0)  -- Set color for tile (white in this example)
    love.graphics.rectangle("line", self.x+1, self.y+1, self.SIZE-1, self.SIZE-1)  -- Draw a square for the tile
    love.graphics.pop();
end

return Tile  -- Return the Tile class