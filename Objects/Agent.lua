
local class = require("Objects.Model");
-- Agent class
local Agent = class:extend()

-- Constructor
function Agent:new()
    print("==AGENT==")
    self.invalid = true;
    Agent.super.new(self)
    --retrieve from external API this object
    self.ships = {};
    
    function spinwait()
        local state = 0

        local stateToCharCode = {
            129,
            131,
            130,
            138,
            136,
            140,
            132,
            133,
            149,
        }
        while true do
            term.clear()
            term.setCursorPos(51/2,19/2)
            state = state + 1
            if state == #stateToCharCode then state = 1 end
            print(string.char(stateToCharCode[state]))
            os.sleep(0.1)
        end
    end
    function refreshing()
        while true do
            local ok,code = self:refresh()
            if ok then self.invalid = false; break end
            if not ok and code == 4104 then
                self.agent_missing = true
                return
            end
            os.sleep(0.2);
        end
    end
    parallel.waitForAny(refreshing,spinwait);
end

function Agent:remake()
    local options = {
        method = "POST",
        -- TOKEN = __TOKEN__,
        payload = {
            faction= 'VOID',
            symbol="ARCHANGEL",
            email="JACO@KOTZE.CO.ZA"
        }
    }
    local success,response = self.API.request('register',options);
    if success then
        if not response.err then
            local token = response.body.token
            token_file = fs.open("token",'w');
            token_file.write(token);
            token_file.flush()
            token_file.close();
            API.TOKEN = token;
            term.clear()
            term.setCursorPos(1,1)
            print(token);
            os.pullEvent('key')
            os.reboot()
        else
            error('!!!!'..response.error_message)
            return false,response.error_code
        end
    end
    error('ASDASD'..response.error_message)
    return false;

end

function Agent:refresh()
    print("Agent:refresh()")
    local options = {
        method = "GET",
        TOKEN = API.TOKEN,
        payload = false
    }
    local success,response = self.API.request('my/agent',options);
    if success then
        if not response.err then
            for k,v in pairs(response.body) do
                self:setAttribute(k,v)
            end
            return true
        else
            return false,response.error_code
        end
    end
    return false,response.error_code;
end

function Agent:getShips()
    local options = {
        method = "GET",
        TOKEN = __TOKEN__,
        payload = false
    }
    local success,response = self.API.request('my/ships',options);
    if success then
        self.ships = {};
        for _,shipData in pairs(response.body) do
            print("GET SHIP",shipData.symbol)
            local ship = self.API.Objects.Ship()
            ship.symbol = shipData.symbol;
            for k,v in pairs(shipData) do
                ship:setAttribute(k,v)
            end
            table.insert(self.ships,ship)
        end
    end
end

--refresh(), cache(), autoupdate(i), destroy(), autocache(i)

return Agent