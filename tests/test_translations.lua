loadSource("classes/Translator")

--- Source files bundled into the script: the ones src/requires_prod.lua requires, plus init.lua.
local function sourceFiles()
    local files = { "src/init.lua" }
    for path in readFile("src/requires_prod.lua"):gmatch('require%("([^"]+)"%)') do
        files[#files + 1] = "src/" .. path .. ".lua"
    end
    return files
end

--- Every key passed as a literal to a translator's get(), e.g. self.translator:get("Ready").
local function usedKeys()
    local keys = {}
    for _, file in ipairs(sourceFiles()) do
        for key in readFile(file):gmatch(':get%(%s*"([^"]+)"') do
            keys[key] = file
        end
    end
    return keys
end

local function placeholders(text)
    local _, count = text:gsub("%%s", "")
    return count
end

test("every text shown is translated", function()
    local keys = usedKeys()
    assertTrue(next(keys) ~= nil, "no keys found in the sources")
    for lang, labels in pairs(Translator.languages) do
        for key, file in pairs(keys) do
            assertTrue(labels[key] ~= nil, string.format("%s: no translation for %q (%s)", lang, key, file))
        end
    end
end)

test("no translation is left over", function()
    local keys = usedKeys()
    for lang, labels in pairs(Translator.languages) do
        for key in pairs(labels) do
            assertTrue(keys[key] ~= nil, string.format("%s: %q is not used anywhere", lang, key))
        end
    end
end)

test("translations keep the placeholders of their key", function()
    for lang, labels in pairs(Translator.languages) do
        for key, text in pairs(labels) do
            assertEqual(placeholders(text), placeholders(key), string.format("%s: placeholders in %q", lang, key))
        end
    end
end)

test("get() falls back to English and fills placeholders", function()
    assertEqual(Translator.new("en"):get("Ready"), "Ready")
    assertEqual(Translator.new("FR"):get("Ready"), "Prêt")
    assertEqual(Translator.new("de"):get("Version %s", "1.0.0"), "Version 1.0.0")
    assertEqual(Translator.new("xx"):get("Show help: %s", "Alt+9"), "Show help: Alt+9")
end)
