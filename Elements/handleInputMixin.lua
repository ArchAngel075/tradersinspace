
local class = require("libs.classic.classic");
-- Element class
local Element = class:extend()

function Element:handleInput(keycode,event,repeating)
  -- assert(self.buffer)
  -- assert(self.cursor)
  -- assert(self.shifting)
  -- assert(self.controlling)
  -- assert(w)
  -- assert(h)
  local keyname = keys.getName(keycode)

  local mapping = {
    [45]= {'-','_'},
    [48] = {'0',')'},
    [49] = {'1','!'},
    [50] = {'2','@'},
    [51] = {'3','#'},
    [52] = {'4','$'},
    [53] = {'5','%'},
    [54] = {'6','^'},
    [55] = {'7','&'},
    [56] = {'8','*'},
    [57] = {'9','('},
    [59] = {';',':'},
    [39] = {"'",'"'},
    [44] = {",",'<'},
    [46] = {".",'>'},
    [47] = {"/",'?'},
    [47] = {"/",'?'},
    [91] = {"[",'{'},
    [92] = {"\\",'|'},
    [93] = {"]",'}'},
    [61]= {'=','+'},
    [32]= {' ',' '},
  }

  if(keyname == "leftShift" or keyname == "rightShift") then
    if(event == 'key') then
      self.shifting = true;
    else
      self.shifting = false
    end
    if(self.onShiftModifier) then self:onShiftModifier(self.shifting) end
    return
  end
  if(keyname == "leftCtrl" or keyname == "rightCtrl" ) then
    if(event == 'key') then
      self.controlling = true;
    else
      self.controlling = false
    end
    return
  end
  if(keyname == "leftAlt" or keyname == "rightAlt" ) then
    if(event == 'key') then
      self.alting = true;
    else
      self.alting = false
    end
    return
  end

  if(event == 'key_up') then
    return
  end

  if keyname == "enter" then
    if(type(self.onSubmit) == 'function') then self:onSubmit(self.buffer) end
    return 
  end
  
  -- Handle special keys
  if keyname == "backspace" then
    if self.cursor > 1 then
      self.buffer = self.buffer:sub(1, self.cursor-2) .. self.buffer:sub(self.cursor)
      self.cursor = self.cursor - 1
    end
    return
  elseif keyname == "delete" then
    self.buffer = self.buffer:sub(1, self.cursor-1) .. self.buffer:sub(self.cursor+1)
    return
  elseif keyname == "home" then
    self.cursor = 1
    if(self.onGoHome) then self:onGoHome() end
    return
  elseif keyname == "end" then
    if(self.onGoEnd) then self:onGoEnd() end
    self.cursor = #self.buffer + 1
    return
  elseif keyname == "u" and self.controlling then -- Ctrl-U (clear line)
    self.buffer = ""
    self.cursor = 1
    return
  elseif keyname == "w" and self.controlling then -- Ctrl-W (delete previous word)
    local startpos = self.cursor
    while startpos > 1 and self.buffer:sub(startpos-1, startpos-1) ~= " " do
      startpos = startpos - 1
    end
    self.buffer = self.buffer:sub(1, startpos-1) .. self.buffer:sub(self.cursor)
    self.cursor = startpos
    return
  elseif keyname == "x" and self.controlling then -- Ctrl-X (cut)
    if self.cursor > 1 then
      local cuttext = self.buffer:sub(self.cursor)
      self.buffer = self.buffer:sub(1, self.cursor-1)
      self.cursor = self.cursor - 1
      return self.buffer, self.cursor, cuttext
    end
    return
  elseif keyname == "c" and self.controlling then -- Ctrl-C (copy)
    if self.cursor > 1 then
      local cuttext = self.buffer:sub(self.cursor)
      return self.buffer, self.cursor, cuttext
    end
    return
  elseif keyname == "v" and self.controlling then -- Ctrl-V (paste)
    if clipboard and #clipboard > 0 then
      self.buffer = self.buffer:sub(1, self.cursor-1) .. clipboard .. self.buffer:sub(self.cursor)
      self.cursor = self.cursor + #clipboard
    end
    return
  elseif keyname == "left" then -- Left arrow
    if(self.onArrow) then self:onArrow('left') end

    if self.cursor > 1 then
      self.cursor = self.cursor - 1
    end
    return
  elseif keyname == "right" then -- Right arrow
    if(self.onArrow) then self:onArrow('right') end

    if self.cursor <= #self.buffer then
      self.cursor = self.cursor + 1
    end
    return
  elseif keyname == "up" then -- Left arrow
    if(self.onArrow) then self:onArrow('up') end
    return
  elseif keyname == "down" then -- Right arrow
    if(self.onArrow) then self:onArrow('down') end
    return
  end
  
  -- Handle printable characters
  if keyname and #keyname >= 1 then
    -- Printable character, semicolon, parentheses, or numeral
    local char = mapping[keycode];
    if char then
      if(self.shifting) then char = char[2]; else char = char[1] end
    else
      char = keyname;  
      if(self.shifting) then char = string.upper(char) end
    end
    -- error(keycode)
    self.buffer = self.buffer:sub(1, self.cursor-1) .. char .. self.buffer:sub(self.cursor)
    self.cursor = self.cursor + 1
  end
  
end



return Element