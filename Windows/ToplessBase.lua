
local class = require("libs.classic.classic");
-- Window class
local Window = class:extend()

-- Constructor
function Window:new(x,y,w,h,parent)
    self.w = w or 51
    self.h = h or 19
    self.x = x or 1
    self.y = y or 1
    self.parent = parent or term.current();
    self.window = window.create(self.parent,self.x,self.y,self.w,self.h)
    self.textInput = require("Elements.TextInput")(2,self.y+1,self.w-2,1);

    self.textInput.onSubmit = function(self,submission)
        local is_eval = string.sub(submission,1,#";") == ";"
        local is_debug = string.sub(submission,1,#"!") == "!"
        if(is_debug) then error('debug!') end

        if is_eval then
            local to_eval = loadstring(string.sub(submission,#";"+1))
            if(to_eval) then
                term.setCursorPos(2,2)
                setfenv(to_eval, _ENV)
                local resultant = {pcall(to_eval)};
                if resultant[1] then
                print("success;")
                for k,v in pairs(resultant) do
                    print(k,v)
                end
                else
                print("error;")
                print(resultant[2])
                end
                os.pullEvent('key')
            end
        else
            term.setCursorPos(2,2)
            local s,e = string.find(submission,"%w+");
            local word = string.sub(submission,s,e);
            local to_eval = loadstring(word .. "()")
            if(to_eval) then
                term.setCursorPos(2,2)
                setfenv(to_eval, _ENV)
                local resultant = {pcall(to_eval)};
                if resultant[1] then
                print("success;")
                for k,v in pairs(resultant) do
                    print(k,v)
                end
                else
                print("error;")
                print(resultant[2])
                end
                os.pullEvent('key')
            end
        end

    end

end

function Window:draw()
    term.redirect(self.window);
    term.clear();
    term.setCursorPos(1,1)
    local w,h = self.w,self.h;
    term.write("/"..string.rep(' ',w-2).."\\")
    for i = 2,h-1 do
        term.setCursorPos(1,i)
        term.write("|"..string.rep(' ',w-2).."|")
    end
    term.setCursorPos(1,h)
    term.write("\\"..string.rep('_',w-2).."/")
    self.textInput:draw();
    term.redirect(term.native())
end

function Window:onEvent(e)
    self.textInput:onEvent(e);
end

--refresh(), cache(), autoupdate(i), destroy(), autocache(i)

return Window