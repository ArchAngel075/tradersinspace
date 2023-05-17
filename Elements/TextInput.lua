
local class = require("libs.classic.classic");
-- Element class
local Element = class:extend()
Element:implement(require("Elements.handleInputMixin"))

-- Constructor
function Element:new(x,y,w,h,parent)
    self.w = w or 51
    self.h = h or 19
    self.x = x or 1
    self.y = y or 1
    self.parent = parent or term.current();
    self.Element = window.create(self.parent,self.x,self.y,self.w,self.h)
    self.buffer = "";
    self.cursor = 1;
end

function Element:draw()
    term.redirect(self.Element);
    term.clear();
    term.setCursorPos(1,1)
    local w,h = self.w,self.h;
    local buffer,cursor = self.buffer,self.cursor
    term.setTextColor(colors.yellow)
    local text = string.sub(buffer,1,cursor-1) ..'|'..string.sub(buffer,cursor,cursor)..string.sub(buffer,cursor+1);
    term.write(text)
    term.redirect(term.native())
    term.setTextColor(colors.white)

end

function Element:onEvent(e)
    local _,ch,r = e[1],e[2],e[3]
    if((_ == 'key' or _ == 'key_up')) then
        self:handleInput(ch,_,r);
    end
    return false;
end

--refresh(), cache(), autoupdate(i), destroy(), autocache(i)

return Element