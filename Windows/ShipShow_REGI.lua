
local class = require("libs.classic.classic");
-- Window class
local Window = class:extend()

-- Constructor
function Window:new(shipObject)
    self.w = w or 51
    self.h = h or 19
    self.x = x or 1
    self.y = y or 1
    self.ship = shipObject;
    self.parent = parent or term.current();
    self.children = {};
    -- local eval_text_input = API.UI.windows.ToplessBase(1,h-1,w,3);

    --[[
        |   [REGI][NAVI][RTOR][CARG][ENGI][MODU][MOUN]    |
        |               [FRAM][FUEL][CREW]                |
    ]]


    self.selected = 1;
    self.items = {    }
    local regi =  self.ship:getAttribute('registration');
    self.items['FACTION'] = regi.faction
    self.items['ROLE   '] = regi.role
    self.items['NAME   '] = regi.name

    
    -- table.insert(self.children,eval_text_input);
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

    local lngest = 1;
    for k,v in pairs(self.items) do if(#k > lngest) then lngest = #k end end

    local y = 6;
    for k,v in pairs(self.items) do
        local text = k .. ' '..v
        term.setCursorPos(w/2-#text/2,y)
        term.write(text)
        y = y + 1;
    end
        
    term.setTextColor(colors.white);

    for k,v in pairs(self.children) do
        v:draw()
    end
end

function Window:onKeyEvent(keycode,repeating)
    local key = keys.getName(keycode)
    if key == 'left' then
        self.selected = math.max(1,self.selected-1);
    end
    if key == 'right' then
        self.selected = math.min(#self.options,self.selected+1);
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
    local option = string.lower(self.options[self.selected]);
    if option == 'back' then
        _w = API.UI.windows.ShipsManagement(1,1,w,h)
        current_window = _w
    end

end

--refresh(), cache(), autoupdate(i), destroy(), autocache(i)

return Window