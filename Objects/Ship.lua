
local class = require("Objects.Model");
-- Ship class
local Ship = class:extend()

-- Constructor
function Ship:new()
    print("==Ship==")
    Ship.super.new(self)
end

function Ship.fromAPI(symbol)
    local ship = Ship();
    ship.symbol = symbol;
    ship:refresh();
    return ship;
end

function Ship:navigateTo(waypointSymbol)
    local options = {
        method = "POST",
        TOKEN = __TOKEN__,
        payload = {
            waypointSymbol = waypointSymbol
        }
    }
    local success,response = self.API.request('/my/ships/'..self.symbol..'/navigate', options)
    if success then
        for k,v in pairs(response.body) do
            self:setAttribute(k,v)
        end
    end
    return true;
end

function Ship:extract(survey)
    local options = {
        method = "POST",
        TOKEN = __TOKEN__,
        payload = {
            survey = survey or nil
        }
    }
    local success,response = self.API.request('/my/ships/'..self.symbol..'/extract', options)
    if success then
        for k,v in pairs(response.body) do
            self:setAttribute(k,v)
        end
    end
    return true;
end

function Ship:refresh()
    -- print("Ship:refresh()")
    local options = {
        method = "GET",
        TOKEN = __TOKEN__,
        payload = false
    }
    local success,response = self.API.request('my/ships/' .. self.symbol,options);
    if success then
        for k,v in pairs(response.body) do
            self:setAttribute(k,v)
        end
    end
    return true;
end

function Ship:getNav()
    return self:getAttribute('nav')
end

function Ship:status()
    return self:getNav().status
end

function Ship:orbit()
    local options = {
        method = "POST",
        TOKEN = __TOKEN__,
        payload = false
    }
    local success,response = self.API.request('/my/ships/'..self.symbol..'/orbit',options);
    if success then
        -- error("nav updated " .. tostring(response.body.nav.status))
        -- self:refresh();

        self:setAttribute('nav',response.body.nav)
        -- self.attributes.nav.status = response.body.nav.status
    end
end

function Ship:dock()
    local options = {
        method = "POST",
        TOKEN = __TOKEN__,
        payload = false
    }
    local success,response = self.API.request('/my/ships/'..self.symbol..'/dock',options);
    if success then
        -- self:refresh();

        self:setAttribute('nav',response.body.nav)
        -- self.attributes.nav.status = response.body.nav.status
    end
end

function Ship:scanWaypoints()
    print("Ship:scanWaypoints()")
    local options = {
        method = "POST",
        TOKEN = __TOKEN__,
        payload = false
    }
    local success,response = self.API.request('/my/ships/'..self.symbol..'/scan/waypoints',options);
    if success then
        self.waypoints = {};
        for _,waypointData in pairs(response.body.waypoints) do
            local waypoint = self.API.Objects.Waypoint()
            waypoint.symbol = waypointData.symbol;
            for k,v in pairs(waypointData) do
                waypoint:setAttribute(k,v)
            end
            table.insert(self.waypoints,waypoint);
        end
    end
    return true;
end

--refresh(), cache(), autoupdate(i), destroy(), autocache(i)

return Ship