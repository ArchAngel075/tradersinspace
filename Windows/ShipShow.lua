
local class = require("libs.classic.classic");
-- Window class
local Window = class:extend()

-- Constructor
function Window:new(shipObject,x,y,w,h,parent)
    self.w = w or 51
    self.h = h or 19
    self.x = x or 1
    self.y = y or 1
    self.ship = shipObject;
    self.parent = parent or term.current();
    self.window = window.create(self.parent,self.x,self.y,self.w,self.h)
    self.children = {};
    -- local eval_text_input = API.UI.windows.ToplessBase(1,h-1,w,3);

    --[[
        |   [REGI][NAVI][RTOR][CRGO][ENGN][MODL][MOUN]    |
        |               [FRME][FUEL][CREW]                |
    ]]


    self.selected = 1;
    self.options = {
        'REGI', 'NAVI', 'RCTR', 'CRGO', 'ENGN', 'MODL', 'MOUN', 'FRME', 'FUEL', 'CREW'
    }
    
    self.menus = {}

    for k,v in pairs(self.options) do
        local menu = require('Windows/ShipShow_' .. v)(self.ship,self)
        self.menus[k] = menu;
    end

    -- table.insert(self.children,eval_text_input);
end

function Window:draw()
    term.redirect(self.window);
    term.clear();
    term.setCursorPos(1,1)
    local w,h = self.w,self.h;
    term.write(" "..string.rep('_',w-2).." ")
    term.setCursorPos(1,2)
    term.write("/"..string.rep(' ',w-2).."\\")
    local name = self.ship:getAttribute('registration').name;
    term.setCursorPos(w/2-#name/2-1,2)
    term.write('\\'..name..'/')
    for i = 3,h-1 do
        term.setCursorPos(1,i)
        term.write("|"..string.rep(' ',w-2).."|")
    end
    term.setCursorPos(1,h)
    term.write("\\"..string.rep('_',w-2).."/")

    term.setCursorPos(4,3)
    for i = 1,#self.options do
        if i == 8 then
            term.setCursorPos(16,4);
        end
        local text = '['..string.upper(self.options[i])..']';
        local textColor = colors.white;
        if(self.selected == i) then
            text = string.upper(text);
            textColor = colors.yellow
        end
        term.setTextColor(textColor);
        term.write(text)
    end
        
    term.setTextColor(colors.white);

    for k,v in pairs(self.children) do
        v:draw()
    end

    self.menus[self.selected]:draw();

    term.redirect(term.native())
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
    if key == "backspace" then
        _w = API.UI.windows.ShipsManagement(1,1,w,h)
        current_window = _w
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

    self.menus[self.selected]:onEvent(e);
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