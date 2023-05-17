
local class = require("libs.classic.classic");
-- Window class
local Window = class:extend()

-- Constructor
function Window:new(shipObject,return_to)
    self.w = w or 51
    self.h = h or 19
    self.x = x or 1
    self.y = y or 1
    self.ship = shipObject;
    self.parent = parent or term.current();
    self.children = {};
    self.return_to = return_to;
    -- local eval_text_input = API.UI.windows.ToplessBase(1,h-1,w,3);

    --[[
        |   [REGI][NAVI][RTOR][CARG][ENGI][MODU][MOUN]    |
        |               [FRAM][FUEL][CREW]                |
    ]]

    -- self.ship:getAttribute('nav') =  self.ship:getAttribute('nav');
    -- table.insert(self.children,eval_text_input);

    self.selected = 1;
end

function Window:draw()
    term.setCursorPos(1,1)
    local w,h = self.w,self.h;
    for i = 5,h-1 do
        term.setCursorPos(1,i)
        term.write("|"..string.rep(' ',w-2).."|")
    end
    term.setCursorPos(1,h)
    term.write("\\"..string.rep('_',w-2).."/")

    local y = 5;
    -- term.setCursorPos(w/2-#text/2,y)

    term.setCursorPos(2,6)
    term.write("SYSTEM : " .. self.ship:getAttribute('nav').systemSymbol)
    term.setCursorPos(2,7)
    term.write("WAYPNT : " .. tostring(self.ship:getAttribute('nav').waypointSymbol))
    term.setCursorPos(2,8)
    term.write("STATUS : " .. self.ship:getAttribute('nav').status)
    term.setCursorPos(2,9)
    term.write("MODE   : " .. self.ship:getAttribute('nav').flightMode)
    if(self.ship:getAttribute('nav').status == 'IN_TRANSIT') then
        term.setCursorPos(2,11)
        term.write("IN_TRANSIT FROM <" .. self.ship:getAttribute('nav').route.departure.type .. ">#"..self.ship:getAttribute('nav').route.departure.symbol )
        term.setCursorPos(2,12)
        term.write("LOCATED AT ("..tostring(self.ship:getAttribute('nav').route.departure.x)..','..tostring(self.ship:getAttribute('nav').route.departure.y)..")")
        term.write(" IN SYSTEM #" .. self.ship:getAttribute('nav').route.departure.systemSymbol)
        term.setCursorPos(2,13)
        term.write("TO <" .. self.ship:getAttribute('nav').route.destination.type .. ">#"..self.ship:getAttribute('nav').route.destination.symbol )
        term.setCursorPos(2,14)
        term.write("LOCATED AT ("..tostring(self.ship:getAttribute('nav').route.destination.x)..','..tostring(self.ship:getAttribute('nav').route.destination.y)..")")
        term.write(" IN SYSTEM #" .. self.ship:getAttribute('nav').route.destination.systemSymbol)
        term.setCursorPos(2,15)
        term.write("DEPARTED  " .. self.ship:getAttribute('nav').route.departureTime )
        term.setCursorPos(2,16)
        term.write("ARRIVAL   " .. self.ship:getAttribute('nav').route.arrival )
        local depart = "2023-05-15T14:31:40.120Z";
        local depart = self.ship:getAttribute('nav').route.departureTime;
        local arrive = "2023-05-15T14:32:08.115Z";
        local arrive = self.ship:getAttribute('nav').route.arrival;
    
        term.setCursorPos(2,17)
        local ratio = API.periodToRatio(depart,arrive)
        term.write("RATIO  "..tostring(ratio));
    end
       
    right_side_starts_at = 26;

    function selectedText(text,x,y)
        term.setTextColor(colors.yellow)
        term.setCursorPos(x,y)
        term.write('['..text..']')
        term.setTextColor(colors.white)
    end
    
    function normalText(text,x,y)
        term.setTextColor(colors.white)
        term.setCursorPos(x,y)
        term.write(text)
    end

    function write(text,x,y,selected)
        if(selected) then selectedText(text,x,y) else normalText(' '..text,x,y) end
    end

    local action = "DOCK"
    if self.ship:getAttribute('nav').status ~= "IN_TRANSIT" then
        if self.ship:getAttribute('nav').status == "DOCKED" then action = "ORBIT" end
        write(action,2,11,self.selected == 1)
    end

    if self.ship:getAttribute('nav').status == 'IN_ORBIT' then
        write('STAR MAP',2,12,self.selected == 2)
    end

    term.setTextColor(colors.white);

    for k,v in pairs(self.children) do
        v:draw()
    end
end

function Window:onKeyEvent(keycode,repeating)
    local key = keys.getName(keycode)
    if key == 'up' then
        self.selected = math.max(1,self.selected-1);
    end
    if key == 'down' then
        self.selected = self.selected+1
    end
    if key == "enter" then
        self:onSubmit()
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
    if self.selected == 1 then
        if self.ship:getAttribute('nav').status ~= "IN_TRANSIT" then
            local action = 'dock'
            if self.ship:getAttribute('nav').status == "DOCKED" then action = "orbit" end
            self.ship[action](self.ship)
            self:draw();
        end
    end
    if self.selected == 2 then
        _w = API.UI.windows.StarMap(self.ship,self.return_to)
        current_window = _w
    end
end

--refresh(), cache(), autoupdate(i), destroy(), autocache(i)

return Window