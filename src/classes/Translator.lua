
---@class Translator
---@field labels {[string] : string}
Translator = {}
Translator.__index = Translator


local labels = {
    fr = {
        ["Triangulation failed"] = "Triangulation échouée",
        ["Ready"] = "Prêt",
        ["Too close"] = "Trop proche",
    },
    de = {
        ["Triangulation failed"] = "Triangulation fehlgeschlagen",
        ["Ready"] = "Bereit",
        ["Too close"] = "Zu nah",
    },
}

function Translator.new()
    local self = setmetatable({}, Translator)

    self.labels = labels[language]

    return self
end

---@param key string
---@return string
function Translator:get(key)
    if self.labels ~= nil and self.labels[key] ~= nil then
        return self.labels[key]
    end
    return key
end