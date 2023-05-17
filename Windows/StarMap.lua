
local class = require("libs.classic.classic");
-- Window class
local Window = class:extend()

-- Constructor
function Window:new(shipObject,backto)
    self.w = w or 51
    self.h = h or 19
    self.x = x or 1
    self.y = y or 1
    self.ship = shipObject or false;
    self.children = {};
    self._back_to = backto;

    self.completed = false;
    self.page = 1;
    self.per_page = 12;
    self.should_init = true;
    -- API.Systems = {};
    if(#API.Systems == 0 or self.should_init) then
        self.should_init = true;
        self.fetch_page = 1;
        self.force_fetch = API._shifting;
        if self.force_fetch then
            API.Objects.System.clearCache()
        end
        self.cachedSystemsList = API.Objects.System.listCache()
        API.Systems = {}
    end
    self.selected = 1;
    self.selected_lr = 1;
    self.spin_state = 1
    self:starFetch(self.force_fetch);
end

function Window:onReturnTo()
    if #API.Systems < 5000 then
        self.cachedSystemsList = API.Objects.System.listCache()
        self:starFetch(self.force_fetch);
    end
end

function Window:starFetch(force)
    API.loading = true;
    if(force) then
        API.loading_text = {"FETCHING SYSTEMS","PLEASE WAIT",tostring(#API.Systems)..' of 5000'}
        Page = API.Objects.Page('systems',self.fetch_page)
        local systems = Page:as(API.Objects.System):fetch():getCollection();
        if systems or self.fetch_page <= 3 then
            -- error(#systems)
            local symbols = {}
            for _,system in pairs(systems) do
                -- API.Systems[system.symbol] = system;
                table.insert(API.Systems,system)
                system:toCache()
                table.insert(symbols,system.symbol)
            end
            os.queueEvent('starfetch',symbols)
            self.per_page = math.min(math.max(self.per_page,12),#API.Systems);
        else
            os.queueEvent('starfetch',false)
        end
    else
        --read some more files from a list of files
        self.cachedSystemsList = self.cachedSystemsList or API.Objects.System.listCache()
        if(self.fetch_page <= #self.cachedSystemsList) then
            local symbols = {}

            for i = 0,math.min(#self.cachedSystemsList-self.fetch_page,1000) do
                local system_to_get = self.cachedSystemsList[self.fetch_page+i];
                local system = API.Objects.System.fromCache(system_to_get)
                if system then
                    table.insert(API.Systems,system)
                    table.insert(symbols,system.symbol)
                else
                    error('unable to load cached system [' .. tostring(system_to_get) .. ']');
                end
                -- API.Systems[system.symbol] = system;
                -- system:toCache();
            end
            self.fetch_page = self.fetch_page + math.min(#self.cachedSystemsList-self.fetch_page,1000);

            local system = false
            if self.ship then
                for k,v in pairs(API.Systems) do if v.symbol == self.ship:getAttribute('nav').systemSymbol then system = v end end
            end
            
            local x,y = 0,0
            if system then
                x,y = system:getAttribute('x'),system:getAttribute('y')
            end
            local function compareByDistance(a, b)
                return a:distanceTo(system or API.Objects.Point(0,0)) < b:distanceTo(system or API.Objects.Point(0,0))
            end
            
            table.sort(API.Systems, compareByDistance)

            
            self.per_page = math.min(math.max(self.per_page,12),#API.Systems);

           

            os.queueEvent('starfetch',symbols)
        else
            os.queueEvent('starfetch',false)
        end
    end
end

function Window:drawStarMapBackground()
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

function Window:drawStarMapForground(system)
    local ship_system
    if(self.ship) then
        ship_system = self.ship:getAttribute('nav').systemSymbol
    else
        ship_system = system.symbol
    end
    --40 x 14 starmap
    --get those nearby, sorting the starmap ->

    local close_by = {}
    local threshold = self.threshold or 50
    local x,y = system:getAttribute('x'),system:getAttribute('y')
    for k,B in pairs(API.Systems) do
        if B.symbol ~= system.symbol then
            local dx = B:distanceTo(system)
            if dx < threshold then
                table.insert(close_by,{system=B,distance=dx,ox = B:getAttribute('x')-x,oy = B:getAttribute('y')-y});
            end
        end
        if B.symbol == system.symbol then
            table.insert(close_by,{system=B,distance=0,ox = 0,oy = 0});
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
                term.setTextColor(v.system:getDrawData().fg)
                term.setBackgroundColor(v.system:getDrawData().bg)
                if(v.system.symbol == ship_system) then term.setTextColor(colors.green) end
                if v.system.symbol == system.symbol then term.setTextColor(colors.yellow) end
                term.setCursorPos(x,y)
                term.write(v.system:getDrawData().char)
                term.setTextColor(colors.white)
                term.setBackgroundColor(colors.black)
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

    self:drawStarMapBackground()

    local y = 5;
    -- term.setCursorPos(w/2-#text/2,y)
    local systems_page = {}
    local count = 0;
    for system_symbol,system in pairs(API.Systems) do
        if(count >= self.page * self.per_page - self.per_page and count <= self.page * self.per_page) then
            table.insert(systems_page,system)
        end
        count = count + 1;
    end

    term.setCursorPos(3,3)
    term.write('Systems ');
    term.setCursorPos(3,4)
    term.write(tostring(self.page)..' of '..tostring(math.ceil(count/self.per_page)))

    function selectedText(text,x,y)
        term.setTextColor(colors.yellow)
        term.setCursorPos(x,y)
        term.write('['..text..']')
        term.setTextColor(colors.white)
    end

    function highlightedText(text,x,y)
        term.setTextColor(colors.lime)
        term.setCursorPos(x,y)
        term.write('['..text..']')
        term.setTextColor(colors.white)
    end
    
    function normalText(text,x,y)
        term.setTextColor(colors.white)
        term.setCursorPos(x,y)
        term.write(text)
    end

    for i = 1,math.min(self.per_page,#systems_page) do
        local system = systems_page[i];
        local mode = false
        if self.ship and system.symbol == self.ship:getAttribute('nav').systemSymbol then
            mode = highlightedText
        end
        if self.selected == i then
            mode = true
        end
        write(system.symbol, 2,5+i,mode)
    end

    right_side_starts_at = 26;

    function write(text,x,y,mode)
        if type(mode) == "boolean" then
            if(mode) then selectedText(text,x,y) else normalText(' '..text,x,y) end
        else
            mode(text,x,y)
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
    term.write(systems_page[self.selected]:getAttribute('type') or "UNKNOWN TYPE")
    term.write(" @ ( " .. systems_page[self.selected]:getAttribute('x') .. " , " .. systems_page[self.selected]:getAttribute('y') .. " )")


    self:drawStarMapForground(systems_page[self.selected])

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
            self.page = math.floor(#API.Systems/self.per_page)
        end
    end
    if key == 'down' then
        self.selected = self.selected+1;
        if self.selected > self.per_page then 
            self.selected = 1;
            self.page = self.page + 1
            self.page = math.min(self.page,math.floor(#API.Systems/self.per_page))
        end 
    end
    if key == 'pageUp' then
        self.page = math.max(1,self.page - 1);
    end
    if key == 'pageDown' then
        self.page = self.page + 1;
    end

    if key == 'home' then
        --take current ship?
        --get system symbol
        --for each page seek if system symbol in page
        --set page to that page
        --get i of symbol and set as selected
        if(self.ship) then
            local target = self.ship:getAttribute('nav').systemSymbol
            local found_on_page = false
            local nth = false
            for page = 1,math.ceil(#API.Systems/self.per_page) do
                if not found_on_page then
                    for i = 0,self.per_page do
                        -- term.clear()
                        -- term.setCursorPos(1,1)
                        -- term.write("i = " .. tostring(i))
                        -- term.write(" page = " .. tostring(page));
                        -- term.write(" k = " .. tostring(page*self.per_page-self.per_page + i))
                        if not found_on_page then
                            local system = API.Systems[page*self.per_page-self.per_page + i];
                            if system and system.symbol == target then
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

    if e[1] == 'starfetch' then
        if e[2] then
            local system_symbols = e[2]
            self.fetch_page = self.fetch_page + 1;
            self:starFetch(self.force_fetch)
        else
            API.loading = false 
        end
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

    local systems_page = {}
    local count = 0;
    for system_symbol,system in pairs(API.Systems) do
        if(count >= self.page * self.per_page - self.per_page and count <= self.page * self.per_page) then
            table.insert(systems_page,system)
        end
        count = count + 1;
    end

    _w = API.UI.windows.SystemMap(self.ship,systems_page[self.selected],self,1,1,w,h)
    current_window = _w
end

--refresh(), cache(), autoupdate(i), destroy(), autocache(i)

return Window