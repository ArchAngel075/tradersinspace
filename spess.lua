

term.clear()
term.setCursorPos(1,1)
for k,v in pairs(package.loaded) do
  print(k,v)
end
package.loaded.Api = nil;
ccemux.attach("left","disk_drive",{id=0});
API = require("Api");


API.genericKeyEventHandler = function(pressed,k,r)
  local keyname = keys.getName(k);
  if(keyname == "leftCtrl" or keyname == "rightCtrl" ) then
    if(pressed) then
      API._controlling = true;
    else
      API._controlling = false
    end
  end
  if(keyname == "leftShift" or keyname == "rightShift" ) then
    if(pressed) then
      API._shifting = true;
    else
      API._shifting = false
    end
  end
  if(keyname == "leftAlt" or keyname == "rightAlt" ) then
    if(pressed) then
      API._alting = true;
    else
      API._alting = false
    end
  end
  
end



output_handle = fs.open("disk/out.json",'w');

local w,h = 51,19;


local function _Draw()
  if(API.loading) then
    API.spin()
  else
    current_window:draw();
  end
  -- term.setCursorPos(3,h-1)
  -- local text = string.sub(buffer,1,cursor-1) ..'|'..string.sub(buffer,cursor,cursor)..string.sub(buffer,cursor+1);
  -- term.write(text)
  -- term.write("\t\t"..tostring(controlling):sub(1,1).."|"..tostring(shifting):sub(1,1)) 
  -- term.write(cursor) 
end

history = {}
print("get agent :")
Agent = API.Objects.Agent()
API.Agent = Agent;


if API.Agent.agent_missing then
  while true do
    term.clear()
    term.setCursorPos(1,1)
    term.write("AGENT WAS MISSING (BAD TOKEN)")
    term.setCursorPos(1,2)
    term.write("CREATE NEW AGENT? (ARCHANGEL)")
    term.setCursorPos(1,4)
    term.write("Y/N > ")
    local e,keycode = os.pullEvent('key');
    local keyname = keys.getName(keycode)
    if keyname == "y" then
      API.Agent:remake()
      break;
    end
    if keyname == "n" then
      os.reboot()
      break;
    end
  end
end

_base = API.UI.windows.Base(1,1,w,h)
current_window = _base;

while true do
  term.redirect(term.native())
  term.clear();
  _Draw()
  local e = {os.pullEvent()};
  
  if(e[1] == 'key') then
    API.genericKeyEventHandler(true,e[2],e[3]);
  end
  if(e[1] == 'key_up') then
    API.genericKeyEventHandler(false,e[2],e[3]);
  end

  current_window:onEvent(e);  
end

-- print("success",success)
-- print("code",response.code)
-- print("response",response.body)
-- output_handle.write(API.json.encode(response.body))
-- output_handle.flush()
-- output_handle.close();

--[[

  objects can be stored on disk in the /cache folder.
  this will represent the last known state of the object, a file name indicates the unique id, the first line indicates last timestamp of data and then onwards will be a json string of data;
  as a result using Ship:fromCache("id") will rebuild a ship object from a cached instance. calling cache() will save the object to cache.
  cached objects will return true on isOutdated()
  once per minute volatile data is cached automatically if it is in the autocache whitelist.

  autoupdating :
  if some object is pertinent to keep aware of for some reason, it may be flagged as "watched"
  if a object is watched then before an automatic cache cycle the object will be refreshed.
  this ensures once per minute the object is in its latest state.
  frequency may be increased to 30s and 15s using the modifiers - important - critical - to increase the cache run on that object.

  watchdog procedures
    a watchdog procedure is some closure that runs once per cycle of 60,30,15s - watchdogs are allways performed *after* all autoupdates.
    a watchdog may observe some state of objects and create a signal that may be responded to by the system. all signals generated thusly are prepended WATCHDOG_


  define a object, when performing a method on it then generate the appropriate HTTP request flow; 
    for instance Agent() has "refresh()" that performs appropriately the GET my/agent
    or 
    Universe.Systems:get() -> appropriately retreives /systems as a array of System{} object

    System:waypoints() retreives the waypoints of a system using /systems/:id/waypoints as an array of Waypoint{} object

    Waypoint:traits() retreives those traits of a waypoint as an array of Trait{} object

    Ship object will have 
    dock() and orbit()
    cruise(); burn(); drift(); stealth();

    etc.

    all objects have refresh(), cache(), autoupdate(i), destroy(), autocache(i)

    Static methods include
    fromCache(id), New(id)
    
]]