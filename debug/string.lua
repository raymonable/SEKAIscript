--[[

This shouldn't be necessary, but here we are.
Note: This was designed for a Lua 5.1 environment, so that's why I don't just use `string.split`.

If you don't wanna open up another Studio SE tab, you can just use https://www.jdoodle.com/execute-lua-online/ to run this.
The values printed from this can be thrown directly into a ZxxxxxxA instruction.

--]]

function SplitIntoCharacters(input)
    local Table = {}
    for i = 1, #input do 
        table.insert(Table, string.sub(input, i, i))   
    end
    return Table
end

function PadZeroes(num)
    local a = tostring(num)
    while #a < 8 do
        a = "0" .. a 
    end
    return a
end

local str = 'Hello world!' -- This is what'll be converted.
local init = ""

for _, char in pairs(SplitIntoCharacters(str)) do
    init = init .. PadZeroes(string.byte(char)) .. " "
end
print(init)
