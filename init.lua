local HttpService = game:GetService('HttpService')

local Imports = {
    "hash/sha1.lua",
    "lib/builtins.lua",
    "sekai.lua"
}
local ImportBase = ""
for _, Import in pairs(Imports) do
    print('Downloading '..Import)
    local ImportSrc = HttpService:GetAsync(string.format('https://cdn.jsdelivr.net/gh/raymonable/SEKAIscript@latest/%s', Import))
    if ImportSrc then
        ImportBase = ImportBase .. "\
".. ImportSrc
    end
end
print('Importing... This may take a moment')
local SekaiScript
local Success, Error = pcall(function()
    SekaiScript = loadstring(ImportBase)()
end)

if Success then
    SekaiScript.init([[
# Your code goes here!!!]])
else
    print(Error)
end
