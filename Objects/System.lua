
local class = require("Objects.Model");
-- System class
local System = class:extend()

-- Constructor
function System:new()
    -- print("==System==")
    System.super.new(self)
    --retrieve from external API this object
    self.waypoints = {};
    self.factions = {};
end

function System:refresh()
    -- print("System:refresh()")
    local options = {
        method = "GET",
        TOKEN = __TOKEN__,
        payload = false
    }
    local success,response = self.API.request('systems/'..self.symbol,options);
    if success then
        for k,v in pairs(response.body) do
            self:setAttribute(k,v)
        end
    end
    return true;
end

local types = {
    'NEUTRON_STAR',
    'RED_STAR',
    'ORANGE_STAR',
    'BLUE_STAR',
    'YOUNG_STAR',
    'WHITE_DWARF',
    'BLACK_HOLE',
    'HYPERGIANT',
    'NEBULA',
    'UNSTABLE',
}

function System:getDrawData()
    local data = {
        ['NEUTRON_STAR'] = {char=string.char(7),bg=colors.black,fg=colors.lightBlue},
        ['RED_STAR']= {char=string.char(42),bg=colors.black,fg=colors.red},
        ['ORANGE_STAR']= {char=string.char(42),bg=colors.black,fg=colors.orange},
        ['BLUE_STAR']= {char=string.char(42),bg=colors.black,fg=colors.blue},
        ['YOUNG_STAR']= {char=string.char(4),bg=colors.black,fg=colors.yellow},
        ['WHITE_DWARF']= {char=string.char(7),bg=colors.black,fg=colors.white},
        ['BLACK_HOLE']= {char=string.char(167),bg=colors.black,fg=colors.magenta},
        ['HYPERGIANT']= {char=string.char(42),bg=colors.black,fg=colors.purple},
        ['UNSTABLE']= {char=string.char(36),bg=colors.black,fg=colors.green},
    }

    local fgs = { colors.red,colors.blue,colors.green,colors.orange, colors.purple }
    local bgs = { colors.yellow, colors.magenta, colors.black, colors.black, colors.black, colors.black}

    data['NEBULA']= {char=string.char(127),bg=math.random(1,#bgs),fg=math.random(1,#fgs)}
    return data[self:getAttribute('type')];
end

function System:getSystemSummaryString()
    

end

function System:distanceTo(B)
    local x,y = self:getAttribute('x'),self:getAttribute('y')
    local a,b = B:getAttribute('x'),B:getAttribute('y')
    local dx = a - x
    local dy = b - y
    return math.sqrt(dx*dx + dy*dy)
  end

function System.fromCache(symbol)
    return API.fromCache('Systems/'..tostring(symbol),System);
end

function System.listCache()
    local files = fs.list('disk/Systems');
    local output = {}
    for k,v in pairs(files) do
        local ext_from = string.find(v,"%.")
        local name = string.sub(v,1,ext_from-1);
        table.insert(output,name);
    end
    return output;
end

function System.clearCache()
    term.clear()
    term.setCursorPos(52/2 -#("CLEARING SYSTEMS CACHE")/2 ,19/2)
    term.write('CLEARING SYSTEMS CACHE')
    local files = fs.list('disk/Systems');
    os.startTimer(10.001)
    for k,v in pairs(files) do
        os.pullEvent('timer')
        fs.delete('disk/Systems/'..v)
        os.startTimer(0.001)
    end
end

function System:toCache()
    return API.toCache('Systems/'..tostring(self.symbol),self);
end

function System:collectWaypoints()
    self:getAttribute('waypoints')
end

function System:getWaypoints()
    -- local options = {
    --     method = "GET",
    --     TOKEN = __TOKEN__,
    --     payload = false
    -- }
    -- local success,response = self.API.request('my/ships',options);
    -- if success then
    --     self.ships = {};
    --     for _,shipData in pairs(response.body) do
    --         print("GET SHIP",shipData.symbol)
    --         local ship = self.API.Objects.Ship()
    --         ship.symbol = shipData.symbol;
    --         for k,v in pairs(shipData) do
    --             ship:setAttribute(k,v)
    --         end
    --         table.insert(self.ships,ship)
    --     end
    -- end
end

--refresh(), cache(), autoupdate(i), destroy(), autocache(i)
fs.makeDir('disk/Systems');

return System