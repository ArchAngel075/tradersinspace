
local class = require("libs.classic.classic");
-- Model class
local Model = class:extend()

-- Constructor
function Model:new()
    self.API = require("Api");
    self.symbol = nil;
    self.outdated = true;
    self.attributes = {};
end

function Model.fromAPI(symbol)
   error("should not be used on base class") 
end

function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function Model:setAttribute(key,value)
    -- if type(value) == "table" then
    self.attributes[key] = value
end

function Model:getAttribute(key)
    return self.attributes[key]
end

--refresh(), cache(), autoupdate(i), destroy(), autocache(i)

return Model