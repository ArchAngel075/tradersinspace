token_file = fs.open("token",'r');
local __TOKEN__ = token_file.readAll();
token_file.close();
local json = require("libs.json");

local function awaitResponse(to)
    local t = os.startTimer(to or 5)
    while true do
      local e = {os.pullEvent()}
      if e[1] == "http_success" then
        local handle = e[3]
        local raw_body = handle.readAll();
        local response_body = json.decode(raw_body).data
        local response_meta = json.decode(raw_body)['meta']
        local response_headers = handle.getResponseHeaders()
        local response_code = handle.getResponseCode();
        local response_error = false
        local response_error_code = -1
        local response_error_message = false;
        if response_body.error then
            response_error = true
            response_error_code = response_body.error.code
            response_error_message = response_body.error.message;
        end
            
        return true,{
            from=e[2],
            err=response_error,
            handle=e[3],
            body = response_body,
            meta = response_meta,
            raw = raw_body,
            headers = response_headers,
            code = response_code,
            error_code = response_error_code,
            error_message = response_error_message,
        }
      end
      if e[1] == "http_failure" then
        local handle = e[4]
        local response_body = {};
        local response_headers = "";
        local response_code = -1;
        local raw_body = "";
        local response_meta = "";
        local response_error_code = -1
        local response_error_message = false;
        if handle then
            raw_body = handle.readAll();
            response_body = json.decode(raw_body)
            response_meta = json.decode(raw_body).meta or {}
            response_headers = handle.getResponseHeaders()
            response_code = handle.getResponseCode();
            if response_body and response_body.error then
                response_error = true
                response_error_code = response_body.error.code
                response_error_message = response_body.error.message;
            else
                error(raw_body)
            end
        end
        return false,{
            from=e[2],
            err=e[3],
            handle=e[4],
            body = response_body.data,
            meta = response_meta,
            raw = raw_body,
            headers = response_headers,
            code = response_code,
            error = true,
            error_code = response_error_code,
            error_message = response_error_message,
        }
      end
      if e[1] == "timer" and e[2] == t then return false,"timeout" end
      os.queueEvent(table.unpack(e)); --put event pack into queue?
    end
end
  
local function request(endpoint,options)
    local _ROOT_ = 'https://api.spacetraders.io/v2/';
  
    local headers = options.headers or {};
    
    -- headers['User-Agent'] = 'ArchAngel075/SpessGeimLove2D';
    if(options.TOKEN) then
        headers['Authorization'] = 'Bearer ' .. options.TOKEN;
    elseif(endpoint ~= 'register' and __TOKEN__) then
        headers['Authorization'] = 'Bearer ' .. __TOKEN__;
    end

            
  
    local method = options.method or "GET";
    method = string.upper(method);
    local payload;
    local payload_str;
  
    local _req = {
        url = _ROOT_..endpoint,
        method = method,
        headers = headers,
        -- sink = ltn12.sink.table(response_body),
        -- redirect = true,
    }
  
    if method == "POST" then
        payload = options.payload or {};
        payload_str = json.encode(payload);
        headers['Content-Length'] = #payload_str;
        headers['Content-Type'] = 'application/json';
        _req['body'] = payload_str
    elseif method == "GET" then
        payload = options.payload or false;
        if(payload) then
            payload_str = ""
            local first = true;
            for k,v in pairs(payload) do
                if not first then payload_str = payload_str.. "&" end
                first = false;
                payload_str = payload_str .. tostring(k).."="..tostring(v)
            end
            _req['url'] = _req['url'] .. "?" .. payload_str;
        end
    end
    if(__rate_limiting > 10) then
        -- os.sleep(2*(__rate_limiting-10))
        __rate_limiting = 0;
    end
    http.request(_req)
    __rate_limiting = __rate_limiting + 1;
    --await response: (3s)
    success,response = awaitResponse();
  
    function printError()
        if response.handle then
            print("")
            print("Error: ")
            print("===\nCode: " .. tostring(response.code).."\n===")
            response_headers = response.headers or {"empty"};
            response_body = response.body or {'no-data'};
    
            print("===response-headers===")
            for k,v in pairs(response_headers) do print(k,":",v) end
            print("======================")
            print("")
            print("===response-payload===")
            for k,v in pairs(response_body) do print(k,":",v) end
            print("======================")
            print(response.raw)
            print("-----------------------------------------------")
        else
            print("Internal Request Error - no code")
            print("Error :",response.err);
        end
        print("")
    end
  
    function printSuccess()
        print("")
        print("Response: ")
        print("===Code: " .. tostring(response.code).."===")
        response_headers = response.headers;
        response_body = response.body;
        
        print("===response-headers===")
        for k,v in pairs(response_headers or {"empty"}) do print(k,v) end
        print("")
        print("===response-payload===")
        for k,v in pairs( response_body or {"no-data"} ) do print(k,v) end
        print("======================")
        print(response.raw)
        print("-----------------------------------------------")
        print("")
    end
  
    if success then 
        -- printSuccess(); 
        return success,response 
    end
    if not success then 
        -- printError(); 
        return success,response 
    end
end

function fromCache(path, morph_to)
    assert(morph_to, "Must specify object to morph data to")
    local _handle = fs.open("disk/"..tostring(path)..".json",'r');
    local content = json.decode(_handle.readAll())
    _handle.close();
    local object = morph_to();
    object.attributes = content.attributes;
    object.symbol = content.symbol;
    return object;
end

function toCache(path,object)
    local _handle = fs.open("disk/"..tostring(path)..".json",'w');
    local content = json.encode({attributes=object.attributes,symbol=object.symbol});
    _handle.write(content);
    _handle.flush();
    _handle.close();
end

function inCache(path)
    return fs.exists("disk/"..tostring(path)..".json");
end

local OBJECTS = {}
local files = fs.list('/Objects')

for k,v in pairs(files) do
    local ext_start = string.find(v,"%.")
    local name = string.sub(v,1,ext_start-1);
    print(k,v,name)
    OBJECTS[name] = require('Objects/'..name);
end


print("--")
local UI = {windows = {}}
local files = fs.list('/Windows')

for k,v in pairs(files) do
    local ext_start = string.find(v,"%.")
    local name = string.sub(v,1,ext_start-1);
    print(k,v,name)
    package.loaded['/Windows/'..name] = nil;
    UI.windows[name] = require('Windows/'..name);
end
print("--")

__rate_limiting = 11

local function spin()
    if API.loading then
        term.clear()
        term.setCursorPos(API.spin_x or 51/2,API.spin_y or 19/2)
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
        API.spin_state = API.spin_state + 1
        if API.spin_state == #stateToCharCode then API.spin_state = 1 end
        term.write(string.char(stateToCharCode[API.spin_state]))

        term.setCursorPos(API.spin_x or 51/2,API.spin_y or 19/2 + 2)
        if API.loading_text then
            for k,v in pairs(API.loading_text) do
                term.setCursorPos((API.spin_x or 51/2)-(#v/2),API.spin_y or 19/2 + 1 + k)
                term.write(v)
            end
        end

    end
end

local API = {}


function API.toTimestamp(dateTime)
    local dateTime = dateTime:sub(1,dateTime:find('%.')-1)..'Z'

    local year, month, day, hour, min, sec = dateTime:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)Z")
    return API.toUnix({year=year, month=month, day=day, hour=hour, min=min, sec=sec})
end

function API.toUnix(datetime)
    -- Calculate the number of seconds that have elapsed between the Unix epoch and the specified date and time
    local seconds = (datetime.year - 1970) * 31536000 + (datetime.month - 1) * 2592000 + (datetime.day - 1) * 86400 + datetime.hour * 3600 + datetime.min * 60 + datetime.sec
    
    return seconds
  end

function API.timeDifference(a,b)
    if(type(a) == 'string') then
        a = API.toTimestamp(a)
    end
    if(type(b) == 'string') then
        b = API.toTimestamp(b)
    end
    local diffSeconds = math.abs(a - b)
    local diffMinutes = diffSeconds / 60
    local diffHours = diffMinutes / 60
    local diffDays = diffHours / 24
    return {days=diffDays, hours=diffHours, minutes=diffMinutes, seconds=diffSeconds}
end

function API.periodToRatio(a,b)
    local timeNow = os.epoch("utc")
    local differenceThen = API.timeDifference(a,b)
    local differenceNow = API.timeDifference(a,timeNow)
    return (differenceNow.seconds - differenceThen.seconds)
end



API.request=request
API.TOKEN=__TOKEN__
API.json=json
API.Objects=OBJECTS
API.UI=UI
API.Systems={}
API.fromCache=fromCache
API.toCache = toCache
API.inCache = inCache
API.spin = spin
API.loading = false
API.spin_state = 0



return API