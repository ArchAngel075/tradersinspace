
local class = require("libs.classic.classic");
-- Tile class
local Tile = require "Objects/Tile"

-- World class
local World = class:extend()

-- Constructor
function World:new(width, height)
  self.width = width
  self.height = height
  self.tiles = {}
  -- Create tiles and store them in the 2D table
  for i = 1, width do
    self.tiles[i] = {}
    for j = 1, height do
      local x = (i - 1) * Tile.SIZE  -- Calculate x coordinate based on tile size
      local y = (j - 1) * Tile.SIZE  -- Calculate y coordinate based on tile size
      self.tiles[i][j] = Tile(i,j)
    end
  end
end

-- Draw method
function World:draw()
  -- Draw tiles
  for i = 1, self.width do
    for j = 1, self.height do
      self.tiles[i][j]:draw()
    end
  end
end

-- Update method
function World:update(dt)
  -- Update tiles
  for i = 1, self.width do
    for j = 1, self.height do
      self.tiles[i][j]:update(dt)
    end
  end
end

return World