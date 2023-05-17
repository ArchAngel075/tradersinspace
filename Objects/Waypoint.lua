
local class = require("Objects.Model");
-- Waypoint class
local Waypoint = class:extend()

-- Constructor
function Waypoint:new()
    print("==Waypoint==")
    Waypoint.super.new(self)
    self.children = {}
end

function Waypoint.fromAPI(symbol,systemSymbol)
    local Waypoint = Waypoint();
    Waypoint.symbol = symbol;
    Waypoint:setAttribute('systemSymbol',systemSymbol);
    Waypoint:refresh();
    return Waypoint;
end

function Waypoint:distanceTo(B)
    local x,y = self:getAttribute('x'),self:getAttribute('y')
    local a,b = B:getAttribute('x'),B:getAttribute('y')
    local dx = a - x
    local dy = b - y
    return math.sqrt(dx*dx + dy*dy)
  end

function Waypoint:refresh()
    print("Waypoint:refresh()")
    local options = {
        method = "GET",
        TOKEN = __TOKEN__,
        payload = false
    }
    local success,response = self.API.request('/systems/'..self:getAttribute('systemSymbol')..'/waypoints/' .. self.symbol,options);
    if success then
        for k,v in pairs(response.body) do
            self:setAttribute(k,v)
        end
    end
    return true;
end

function Waypoint:getChar()
    local char = "?"
    local waypoint_type = self:getAttribute('type')
    if waypoint_type == "PLANET" then 
        char = string.char(42)
    elseif waypoint_type == "GAS_GIANT" then 
        char = "G"
    elseif waypoint_type == "JUMP_GATE" then 
        char = string.char(164)
    elseif waypoint_type == "MOON" then 
        char = string.char(7)
    elseif waypoint_type == "ASTEROID_FIELD" then 
        char = string.char(35)
    end
    return char;
end

function Waypoint:localSystemView()
    local points = {self}
    for k,v in pairs(self.children) do
        table.insert(points,v)
    end
    return points;
end

function Waypoint.groupByOwnership(list)
    --[[
        given some list of waypoints, find those parent celestial bodies.
        given the next pass over the list - place other celestials under their respective parents.
    ]]
    local parents = {}
    local parent_types = {"GAS_GIANT", "PLANET", "ASTEROID_FIELD", "JUMP_GATE"}
    function isParent(celestial_type)
        for k,v in pairs(parent_types) do
            if v == celestial_type then return true end
        end
        return false
    end

    function findParentOf(waypoint,parents)
        local waypoint_x,waypoint_y = waypoint:getAttribute('x'), waypoint:getAttribute('y')
        --local waypoint_type = waypoint:getAttribute('type');
        for k,parent in pairs(parents) do
            local parent_x,parent_y = parent:getAttribute('x'), parent:getAttribute('y')
            if parent_x == waypoint_x and parent_y == waypoint_y then return k end
        end
        return false
    end
        
    for index,waypoint in pairs(list) do
        local x,y = waypoint:getAttribute('x'), waypoint:getAttribute('y')
        local waypoint_type = waypoint:getAttribute('type');
        if isParent(waypoint_type) then
            table.insert(parents,waypoint);
        end
    end

    for index,waypoint in pairs(list) do
        local waypoint_type = waypoint:getAttribute('type');
        if not isParent(waypoint_type) then
            local parent_index = findParentOf(waypoint,parents)
            if parent_index then
                table.insert(parents[parent_index].children,waypoint)
            else
                table.insert(parents,waypoint)
                error('unexpected parent '..tostring(waypoint_type)..'] [' .. waypoint.symbol .. ']')
            end
        end
    end
    return parents;
end

--refresh(), cache(), autoupdate(i), destroy(), autocache(i)

return Waypoint