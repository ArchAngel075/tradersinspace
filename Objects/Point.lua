
local class = require("Objects.Model");
-- Point class
local Point = class:extend()

-- Constructor
function Point:new(x,y)
    Point.super.new(self)
    self:setAttribute('x',x or 0)
    self:setAttribute('y',y or 0)
end

function Point:distanceTo(B)
    local x,y = self:getAttribute('x'),self:getAttribute('y')
    local a,b = B:getAttribute('x'),B:getAttribute('y')
    local dx = a - x
    local dy = b - y
    return math.sqrt(dx*dx + dy*dy)
  end

--refresh(), cache(), autoupdate(i), destroy(), autocache(i)

return Point