local socket  = require("socket")
local http  = require("https")
local json = require("libs.json");
local ltn12 = require("ltn12")
local GAME = {};
local tokenHandle,r = io.open('./token','r')
local __TOKEN__ = tokenHandle:read('all');
tokenHandle.close()

function request(endpoint,options)
  local _ROOT_ = 'https://api.spacetraders.io:433/v2/';

  local headers = options.headers or {};
  
  -- headers['User-Agent'] = 'ArchAngel075/SpessGeimLove2D';
  if(options.TOKEN) then
    headers['Authorization'] = 'Bearer ' .. options.TOKEN;
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
    _req['source'] = ltn12.source.string(payload_str)
  end

  local response_body = {}
  local response, code, response_headers, b = http.request(_req, response_body)
  print("////")
  print(response,code,response_headers,b)
  print("////")

  if code == 200 then
    -- The response body is stored in the response_body table
    print("===response===")
    for k,v in pairs(response_body) do print(k,v) end
    print("==============")
    
  else
    print("Error: " .. code)
    print("===response-headers===")
    for k,v in pairs(response_headers or {"empty"}) do print(k,v) end
    print("")
    print("===response-payload===")
    for k,v in pairs(response_body or {"no-data"}) do print(k,v) end
    print("======================")
  end
  
  return code,response_body
end


function love.load()
  love.window.setTitle("Spess Geim")  -- Set the window title
  love.window.setMode(800, 480)  -- Set the window size to 800x480
  print("make agent :")
  local options = {
    method = "POST",
    
    payload = {
      symbol = "abcdarch0",
      faction = "COSMIC"
    }
  }
  local code,response = request('register',options);
  print("code",code)
  print("response",json.encode(response))
end

function love.update(dt)
end

function love.draw()
end