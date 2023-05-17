
local class = require("libs.classic.classic");
-- Window class
local Window = class:extend()

-- Constructor
function Window:new(shipObject,systemObject,backto)
    self.w = w or 51
    self.h = h or 19
    self.x = x or 1
    self.y = y or 1
    self.ship = shipObject or false;
    self.system = systemObject;
    self.children = {};
    self._back_to = backto;

    self.completed = false;
    self.fetch_page = 1;
    self.page = 1;
    self.per_page = 12;

    -- API.Systems = {};
    -- self:starFetch(self.force_fetch);

    self.selected = 1;
    self.selected_lr = 1;
    
    local waypoints = systemObject:getAttribute('waypoints');
    local ship_system_symbol = false;
    local ship_waypoint_symbol = false;
    if self.ship then
        ship_system_symbol = self.ship:getAttribute('nav').systemSymbol
        ship_waypoint_symbol = self.ship:getAttribute('nav').waypointSymbol
    end
    --find the ships current waypoint ->
    local ship_waypoint = false;
    self.waypoints = {}
    for k,v in pairs(waypoints) do
        waypoint = API.Objects.Waypoint()
        waypoint.symbol = v.symbol;
        for i,o in pairs(v) do
            waypoint:setAttribute(i,o)
        end
        if ship_waypoint_symbol and v.symbol == ship_waypoint_symbol then 
            ship_waypoint = waypoint
        end
        table.insert(self.waypoints,waypoint);
    end
    self.waypoints = API.Objects.Waypoint.groupByOwnership(self.waypoints)
    self.per_page = math.min(math.max(self.per_page,12),#self.waypoints);
    self.ship_waypoint = ship_waypoint;
end

function Window:drawMapBackground()
    --40 x 14 starmap
    for x = 11,self.w do
        for y = 5,self.h do
            if  not ((x >= 11 and x <= 13 and y == 5)
                or (x >= 11 and x <= 12 and y == 6)
                or (x >= 11 and x <= 11 and y == 7)) then
                term.setCursorPos(x,y)
                -- term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.lightGray)
                term.write(string.char(127))
            end
        end
    end
    term.setTextColor(colors.white)

end

function Window:drawMapForground(target_waypoint)
    
    --40 x 14 starmap
    --get those nearby, sorting the starmap ->

    local close_by = {}
    local x,y = target_waypoint:getAttribute('x'),target_waypoint:getAttribute('y')
    for k,B in pairs(self.waypoints) do
        if B.symbol ~= target_waypoint.symbol then
            local dx = B:distanceTo(target_waypoint)
            table.insert(close_by,{waypoint=B,distance=dx,ox = B:getAttribute('x')-x,oy = B:getAttribute('y')-y});
        end
        if B.symbol == target_waypoint.symbol then
            table.insert(close_by,{waypoint=B,distance=0,ox = 0,oy = 0});
        end
    end

    local function compareByDistance(a, b)
        return a.distance < b.distance
    end
    
    table.sort(close_by, compareByDistance)

    for k,v in pairs(close_by) do
        local x,y = math.ceil(v.ox/4)+11+20, math.ceil(v.oy/4) + 5 + 7
        if  not ((x >= 11 and x <= 13 and y == 5)
        or (x >= 11 and x <= 12 and y == 6)
        or (x >= 11 and x <= 11 and y == 7)) then
            if(y > 4) then
                term.setTextColor(colors.red)
                if(self.ship and v.waypoint.symbol == self.ship:getAttribute('nav').waypointSymbol) then term.setTextColor(colors.green) end
                if v.waypoint.symbol == target_waypoint.symbol then term.setTextColor(colors.yellow) end
                term.setCursorPos(x,y)
                -- term.setBackgroundColor(colors.black)
                local char = "?"
                char = v.waypoint:getChar();
                term.write(char)
            end
        end
    end
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)

    -- for x = 11,self.w do
    --     for y = 5,self.h do
    --         if  not ((x >= 11 and x <= 13 and y == 5)
    --             or (x >= 11 and x <= 12 and y == 6)
    --             or (x >= 11 and x <= 11 and y == 7)) then
    --             term.setCursorPos(x,y)
                
    --         end
    --     end
    -- end
end

function Window:draw()
    term.clear();
    term.setCursorPos(1,1)
    
    local w,h = self.w,self.h;
    term.write(" "..string.rep('_',w-2).." ")
    term.setCursorPos(1,2)
    term.write("/"..string.rep(' ',w-2).."\\")
    for i = 3,h-1 do
        term.setCursorPos(1,i)
        term.write("|"..string.rep(' ',w-2).."|")
    end
    term.setCursorPos(1,h)
    term.write("\\"..string.rep('_',w-2).."/")

    self:drawMapBackground()

    local y = 5;
    -- term.setCursorPos(w/2-#text/2,y)
    local waypoints_page = {}
    local count = 0;
    for waypoint_symbol,waypoint in pairs(self.waypoints) do
        if(count >= self.page * self.per_page - self.per_page and count <= self.page * self.per_page) then
            table.insert(waypoints_page,waypoint)
        end
        count = count + 1;
    end

    term.setCursorPos(3,3)
    term.write(string.char(171) .. tostring(self.system.symbol) .. string.char(187));
    term.setCursorPos(3,4)
    term.write(tostring(self.page)..' of '..tostring(math.ceil(count/self.per_page)))

    function selectedText(text,x,y,prepend,append)
        term.setTextColor(colors.yellow)
        term.setCursorPos(x,y)
        term.write((prepend or "") .. '['..text..']' .. (append or ""))
        term.setTextColor(colors.white)
    end

    function highlightedText(text,x,y,prepend,append)
        term.setTextColor(colors.lime)
        term.setCursorPos(x,y)
        term.write((prepend or "") .. '['..text..']' .. (append or ""))
        term.setTextColor(colors.white)
    end
    
    function normalText(text,x,y,prepend,append)
        term.setTextColor(colors.white)
        term.setCursorPos(x,y)
        term.write((prepend or "")..text.. (append or ""))
    end

    for i = 1,math.min(self.per_page,#waypoints_page) do
        local waypoint = waypoints_page[i];
        local mode = false
        if self.ship and waypoint.symbol == self.ship:getAttribute('nav').waypointSymbol then
            mode = highlightedText
        end
        if self.selected == i then
            mode = true
        end
        local symbol = waypoint.symbol
        local symbol = string.sub(symbol,9)
        local waypoint_type = waypoint:getAttribute('type')
        local prepend = '?'
        if waypoint_type == "PLANET" then 
            prepend = string.char(42)
        elseif waypoint_type == "GAS_GIANT" then 
            prepend = "G"
        elseif waypoint_type == "JUMP_GATE" then 
            prepend = string.char(164)
        elseif waypoint_type == "MOON" then 
            prepend = string.char(7)
        elseif waypoint_type == "ASTEROID_FIELD" then 
            prepend = string.char(35)
        end
        write(symbol, 2,5+i,mode,prepend..'',append)
    end

    right_side_starts_at = 26;

    function write(text,x,y,mode,prepend,append)
        if type(mode) == "boolean" then
            if(mode) then selectedText(text,x,y,prepend,append) else normalText(' '..text,x,y,prepend,append) end
        else
            mode(text,x,y,prepend,append)
        end
    end
    term.setCursorPos(15,2)
    term.write("|")
    term.setCursorPos(15,3)
    term.write("|")
    term.setCursorPos(15,4)
    term.write("=")
    term.setCursorPos(14,5)
    term.write("/")
    term.setCursorPos(13,6)
    term.write("/")
    term.setCursorPos(12,7)
    term.write("/")
    for y = 8,h-1 do
        term.setCursorPos(11,y)
        term.write("|")
    end

    for x = 16,w-1 do
        term.setCursorPos(x,4)
        term.write("=")
    end

    term.setCursorPos(17,3)
    if(#waypoints_page > 0) then
        assert(#waypoints_page > 0, "no waypoints in system [" .. tostring(self.system.symbol) .. ']')
        assert(self.selected and self.selected > 0, 'selected must be greater than one and less than ' .. tostring(self.page * self.per_page))
        term.write(waypoints_page[self.selected]:getAttribute('type') or "UNKNOWN TYPE")
        term.write(" @ ( " .. waypoints_page[self.selected]:getAttribute('x') .. " , " .. waypoints_page[self.selected]:getAttribute('y') .. " )")


        self:drawMapForground(waypoints_page[self.selected])
    else
        term.write("No way points in system?")
    end

    term.setTextColor(colors.white);

    for k,v in pairs(self.children) do
        v:draw()
    end
end

function Window:onKeyEvent(keycode,repeating)
    local key = keys.getName(keycode)
    if key == 'up' then
        self.selected = self.selected-1;
        if self.selected < 1 then
            self.selected = self.per_page
            self.page = self.page - 1
            self.page = math.max(1,self.page)
        end
        assert(self.selected)
        assert(self.page)
    end
    if key == 'down' then
        self.selected = self.selected+1;
        if self.selected > self.per_page then 
            self.selected = 1;
            self.page = self.page + 1
            self.page = math.min(self.page,math.floor(#self.waypoints/self.per_page))
        end 
        assert(self.selected)
        assert(self.page)
    end
    if key == 'pageUp' then
        self.page = math.max(1,self.page - 1);
        assert(self.page)
    end
    if key == 'pageDown' then
        self.page = self.page + 1;
        assert(self.page)
    end

    if key == 'home' then
        --take current ship?
        --get system symbol
        --for each page seek if system symbol in page
        --set page to that page
        --get i of symbol and set as selected
        if(self.ship) then
            local target = self.ship:getAttribute('nav').waypointSymbol
            local found_on_page = false
            local nth = false
            for page = 1,math.ceil(#self.waypoints/self.per_page) do
                if not found_on_page then
                    for i = 0,self.per_page do
                        -- term.clear()
                        -- term.setCursorPos(1,1)
                        -- term.write("i = " .. tostring(i))
                        -- term.write(" page = " .. tostring(page));
                        -- term.write(" k = " .. tostring(page*self.per_page-self.per_page + i))
                        if not found_on_page then
                            local waypoint = self.waypoints[page*self.per_page-self.per_page + i];
                            if waypoint and waypoint.symbol == target then
                                found_on_page = page
                                nth = i
                            end
                        end
                    end
                end
            end 
            if(found_on_page) then
                self.page = found_on_page;
                self.selected = nth;       
            end
        else
            self.page = 1;
            self.selected = 1;
        end
    end

    if key == "enter" then
        self:onSubmit()
    end

    if key == "backspace" then
        if self._back_to then
            current_window = self._back_to
            if(current_window.onReturnTo) then
                current_window:onReturnTo()
            end
        else
            _w = API.UI.windows.Base(1,1,w,h)
            current_window = _w
        end
    end
    
end

function Window:onEvent(e)

    if e[1] == "key" then
        self:onKeyEvent(e[2],e[3])
    end

    for k,v in pairs(self.children) do
        if(v.onEvent) then
            if v:onEvent(e) then
                return
            end
        end
    end
end

function Window:onSubmit()
    local waypoints_page = {}
    local count = 0;
    for waypoint_symbol,waypoint in pairs(self.waypoints) do
        if(count >= self.page * self.per_page - self.per_page and count <= self.page * self.per_page) then
            table.insert(waypoints_page,waypoint)
        end
        count = count + 1;
    end

    _w = API.UI.windows.LocalSystemMap(self.ship,self.systemObject,waypoints_page[self.selected],self,1,1,w,h)
    current_window = _w
end

--refresh(), cache(), autoupdate(i), destroy(), autocache(i)

return Window