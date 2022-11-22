local HttpService = game:GetService('HttpService')

local Imports = {
    "hash/sha1.lua",
    "lib/builtins.lua",
    "squid.lua"
}
local ImportBase = ""
for _, Import in pairs(Imports) do
    print('Downloading '..Import)
    local ImportSrc = HttpService:GetAsync(string.format('https://cdn.jsdelivr.net/gh/raymonable/squid@latest/%s', Import))
    if ImportSrc then
        ImportBase = ImportBase .. "\
".. ImportSrc
    end
end
print('Importing... This may take a moment')
local Squid
local Success, Error = pcall(function()
    Squid = loadstring(ImportBase)()
end)

if Success then
    Squid.init([[
# Your code goes here!!!]])
else
    print(Error)
end
