
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
    
    --[[
        cargo will consist of [========---------]
        style progress bar;

        sum all units of items to get the used over capacity

        tabular form using a constricted cell approach :

        
         _____________________      _____________________
        /   NAME   |  AMOUNT  \    /   NAME   |  AMOUNT  \
     -> |ANTIMATTER|    30    |    |          |          |
        |          |          |    |          |          |
        |          |          |    |          |          |
        |          |          |    |          |          |
        |          |          |    |          |          |
        |          |          |    |          |          |
        |          |          |    |          |          |
        |          |          |    |          |          |
        |          |          |    |          |          |
        \=====================+====+===++=====+==========/
         \    ANTIMATTER [ANTIMATTER]                   /
          | A highly valuable and dangerous substance  |
          | used for advanced propulsion and weapons   |
          | systems.                                   |
          \                                            /
           ============================================
    ]]

    self.design = [[

/     NAME     | AMOUNT \;
|              |        |;
|              |        |;
|              |        |;
|              |        |;
|              |        |;
|              |        |;
|              |        |;
|              |        |;
|              |        |;
|              |        |;
|              |        |;
\=======================/;
]];

   

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


    term.setTextColor(colors.lime);


    local lines = {}
    for line in string.gmatch(self.design, "[^" .. ';' .. "]+") do
        table.insert(lines, line)
    end

    term.setCursorPos(4,5)
    term.write('_______________________')
    for k,v in pairs(lines) do
        term.setCursorPos(2,k+5)
        term.write(v)
    end

    term.setCursorPos(4,7)
   
    
    local function centeredText(text,width)
        assert(width,debug.traceback())
        local text = text:sub(1,math.min(width,#text));
        --TODO drop occurances of vowel after first letter to shorten the word IF longer than limit
        local padding = string.rep(" ", math.floor((width - #text) / 2))
        return padding .. text .. padding
    end

    local name_width = 14;
    local units_width = 8;

    for k,item in pairs(self.ship:getAttribute('cargo').inventory) do
        if (self.selected == k) then
            term.setTextColor(colors.yellow);
        else
            term.setTextColor(colors.white);
        end

        term.setCursorPos(4,6+k)
        term.write(centeredText(item.name,name_width))
        term.setCursorPos(4+15,6+k)
        term.write(centeredText(tostring(item.units or -1),units_width))
    end

    self.selected_max = #self.ship:getAttribute('cargo').inventory

    local function splitString(str, n)
        local result = {}
        for i = 1, #str, n do
          table.insert(result, string.sub(str, i, i + n - 1))
        end
        return result
    end

    term.setTextColor(colors.white);
    local desc_length = 21;
    local selected = self.ship:getAttribute('cargo').inventory[self.selected]
    term.setCursorPos(27+2,6)
    for k,line in pairs(splitString(selected.description,21)) do
        term.setCursorPos(27+2,5+k)
        term.write(line)
    end
    
    for k,v in pairs(self.children) do
        v:draw()
    end
    
    term.setTextColor(colors.white);
end

function Window:onKeyEvent(keycode,repeating)
    local key = keys.getName(keycode)
    if key == 'up' then
        self.selected = self.selected-1;
        if self.selected < 1 then
            self.selected = self.selected_max
        end
    end
    if key == 'down' then
        self.selected = self.selected+1
        if self.selected > self.selected_max then
            self.selected = 1
        end
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