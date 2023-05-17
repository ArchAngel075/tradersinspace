
local class = require("Objects.Model");
-- Page class
local Page = class:extend()

-- Constructor
function Page:new(endpoint,page)
    Page.super.new(self)
    --retrieve from external API this object
    self.meta = {};
    self.content = {};
    self.morph_to = false;
    self.endpoint = endpoint;
    self.page = page;
    self.completed = false;
end

function Page:fetch()
    -- print("Page:fetch()")

    local options = {
        method = "GET",
        TOKEN = __TOKEN__,
        payload = {
            limit=20,
            page=self.page
        }
    }
    local success,response = API.request(self.endpoint,options);

    if success then
        self.meta = response.meta;
        self.content = response.body;
        -- os.sleep(0.1);
    end
    if #self.content == 0 then self.completed = true end
    if not success then self.compelted = true end
    return self;
end

function Page:as(morph_to_object)
    self.morph_to = morph_to_object;
    return self
end

function Page:getCollection(morph_to_object)
    if self.completed then return false end
    local morph_to = morph_to_object or self.morph_to;
    assert(morph_to, "must specify an object to morph data to.")
    local objects = {}
    for _,objectData in pairs(self.content) do
        local object = morph_to()
        for field,value in pairs(objectData) do
            object:setAttribute(field,value)
        end
        object.symbol = objectData.symbol;
        table.insert(objects,object)
    end
    return objects;
end

return Page