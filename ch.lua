local f = fs.open("chars",'w')
term.clear()
term.setCursorPos(1,1)
local col = 1
local row = 1
local from = tonumber(... or 1)
for i = from,255 do
 if (i < 48 or i > 57) and (i < 65 or i > 90) 
     and (i < 97 or i > 122)
 then
  term.setCursorPos(col,row)
  term.setBackgroundColor(colors.blue)
  term.setTextColor(colors.yellow)
  term.write(tostring(i)..""..string.char(i))
  f.writeLine(tostring(i).."="..string.char(i))
  col = col + 5
  if col > 45 then
   col = 1; row = row + 2
  end
 end
end
f.flush()
f.close();
