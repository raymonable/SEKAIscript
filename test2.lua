-- URRGG
local SHA1 = (function()	
	local hex_to_bits = {
		["0"] = { false, false, false, false },
		["1"] = { false, false, false, true  },
		["2"] = { false, false, true,  false },
		["3"] = { false, false, true,  true  },

		["4"] = { false, true,  false, false },
		["5"] = { false, true,  false, true  },
		["6"] = { false, true,  true,  false },
		["7"] = { false, true,  true,  true  },

		["8"] = { true,  false, false, false },
		["9"] = { true,  false, false, true  },
		["A"] = { true,  false, true,  false },
		["B"] = { true,  false, true,  true  },

		["C"] = { true,  true,  false, false },
		["D"] = { true,  true,  false, true  },
		["E"] = { true,  true,  true,  false },
		["F"] = { true,  true,  true,  true  },

		["a"] = { true,  false, true,  false },
		["b"] = { true,  false, true,  true  },
		["c"] = { true,  true,  false, false },
		["d"] = { true,  true,  false, true  },
		["e"] = { true,  true,  true,  false },
		["f"] = { true,  true,  true,  true  },
	}


	local function ZERO()
		return {
			false, false, false, false,     false, false, false, false, 
			false, false, false, false,     false, false, false, false, 
			false, false, false, false,     false, false, false, false, 
			false, false, false, false,     false, false, false, false, 
		}
	end

	local function from_hex(hex)

		assert(type(hex) == 'string')
		assert(hex:match('^[0123456789abcdefABCDEF]+$'))
		assert(#hex == 8)

		local W32 = { }

		for letter in hex:gmatch('.') do
			local b = hex_to_bits[letter]
			assert(b)
			table.insert(W32, 1, b[1])
			table.insert(W32, 1, b[2])
			table.insert(W32, 1, b[3])
			table.insert(W32, 1, b[4])
		end

		return W32
	end

	local function COPY(old)
		local W32 = { }
		for k,v in pairs(old) do
			W32[k] = v
		end

		return W32
	end

	local function ADD(first, ...)

		local a = COPY(first)

		local C, b, sum

		for v = 1, select('#', ...) do
			b = select(v, ...)
			C = 0

			for i = 1, #a do
				sum = (a[i] and 1 or 0)
					+ (b[i] and 1 or 0)
					+ C

				if sum == 0 then
					a[i] = false
					C    = 0
				elseif sum == 1 then
					a[i] = true
					C    = 0
				elseif sum == 2 then
					a[i] = false
					C    = 1
				else
					a[i] = true
					C    = 1
				end
			end
			-- we drop any ending carry

		end

		return a
	end

	local function XOR(first, ...)

		local a = COPY(first)
		local b
		for v = 1, select('#', ...) do
			b = select(v, ...)
			for i = 1, #a do
				a[i] = a[i] ~= b[i]
			end
		end

		return a

	end

	local function AND(a, b)

		local c = ZERO()

		for i = 1, #a do
			-- only need to set true bits; other bits remain false
			if  a[i] and b[i] then
				c[i] = true
			end
		end

		return c
	end

	local function OR(a, b)

		local c = ZERO()

		for i = 1, #a do
			-- only need to set true bits; other bits remain false
			if  a[i] or b[i] then
				c[i] = true
			end
		end

		return c
	end

	local function OR3(a, b, c)

		local d = ZERO()

		for i = 1, #a do
			-- only need to set true bits; other bits remain false
			if a[i] or b[i] or c[i] then
				d[i] = true
			end
		end

		return d
	end

	local function NOT(a)

		local b = ZERO()

		for i = 1, #a do
			-- only need to set true bits; other bits remain false
			if not a[i] then
				b[i] = true
			end
		end

		return b
	end

	local function ROTATE(bits, a)

		local b = COPY(a)

		while bits > 0 do
			bits = bits - 1
			table.insert(b, 1, table.remove(b))
		end

		return b

	end


	local binary_to_hex = {
		["0000"] = "0",
		["0001"] = "1",
		["0010"] = "2",
		["0011"] = "3",
		["0100"] = "4",
		["0101"] = "5",
		["0110"] = "6",
		["0111"] = "7",
		["1000"] = "8",
		["1001"] = "9",
		["1010"] = "a",
		["1011"] = "b",
		["1100"] = "c",
		["1101"] = "d",
		["1110"] = "e",
		["1111"] = "f",
	}

	function asHEX(a)

		local hex = ""
		local i = 1
		while i < #a do
			local binary = (a[i + 3] and '1' or '0')
				..
				(a[i + 2] and '1' or '0')
				..
				(a[i + 1] and '1' or '0')
				..
				(a[i + 0] and '1' or '0')

			hex = binary_to_hex[binary] .. hex

			i = i + 4
		end

		return hex
	end

	local x67452301 = from_hex("67452301")
	local xEFCDAB89 = from_hex("EFCDAB89")
	local x98BADCFE = from_hex("98BADCFE")
	local x10325476 = from_hex("10325476")
	local xC3D2E1F0 = from_hex("C3D2E1F0")

	local x5A827999 = from_hex("5A827999")
	local x6ED9EBA1 = from_hex("6ED9EBA1")
	local x8F1BBCDC = from_hex("8F1BBCDC")
	local xCA62C1D6 = from_hex("CA62C1D6")

	function sha1(msg)

		assert(type(msg) == 'string')
		assert(#msg < 0x7FFFFFFF) -- have no idea what would happen if it were large

		local H0 = x67452301
		local H1 = xEFCDAB89
		local H2 = x98BADCFE
		local H3 = x10325476
		local H4 = xC3D2E1F0

		local msg_len_in_bits = #msg * 8

		local first_append = string.char(0x80) -- append a '1' bit plus seven '0' bits

		local non_zero_message_bytes = #msg +1 +8 -- the +1 is the appended bit 1, the +8 are for the final appended length
		local current_mod = non_zero_message_bytes % 64
		local second_append = ""
		if current_mod ~= 0 then
			second_append = string.rep(string.char(0), 64 - current_mod)
		end

		-- now to append the length as a 64-bit number.
		local B1, R1 = math.modf(msg_len_in_bits  / 0x01000000)
		local B2, R2 = math.modf( 0x01000000 * R1 / 0x00010000)
		local B3, R3 = math.modf( 0x00010000 * R2 / 0x00000100)
		local B4     =            0x00000100 * R3

		local L64 = string.char( 0) .. string.char( 0) .. string.char( 0) .. string.char( 0) -- high 32 bits
			.. string.char(B1) .. string.char(B2) .. string.char(B3) .. string.char(B4) --  low 32 bits



		msg = msg .. first_append .. second_append .. L64         

		assert(#msg % 64 == 0)

		--local fd = io.open("/tmp/msg", "wb")
		--fd:write(msg)
		--fd:close()

		local chunks = #msg / 64

		local W = { }
		local start, A, B, C, D, E, f, K, TEMP
		local chunk = 0

		while chunk < chunks do
			--
			-- break chunk up into W[0] through W[15]
			--
			start = chunk * 64 + 1
			chunk = chunk + 1

			for t = 0, 15 do
				W[t] = from_hex(string.format("%02x%02x%02x%02x", msg:byte(start, start + 3)))
				start = start + 4
			end

			--
			-- build W[16] through W[79]
			--
			for t = 16, 79 do
				-- For t = 16 to 79 let Wt = S1(Wt-3 XOR Wt-8 XOR Wt-14 XOR Wt-16). 
				W[t] = ROTATE(1, XOR(W[t-3], W[t-8], W[t-14], W[t-16]))
			end

			A = H0
			B = H1
			C = H2
			D = H3
			E = H4

			for t = 0, 79 do
				if t <= 19 then
					-- (B AND C) OR ((NOT B) AND D)
					f = OR(AND(B, C), AND(NOT(B), D))
					K = x5A827999
				elseif t <= 39 then
					-- B XOR C XOR D
					f = XOR(B, C, D)
					K = x6ED9EBA1
				elseif t <= 59 then
					-- (B AND C) OR (B AND D) OR (C AND D
					f = OR3(AND(B, C), AND(B, D), AND(C, D))
					K = x8F1BBCDC
				else
					-- B XOR C XOR D
					f = XOR(B, C, D)
					K = xCA62C1D6
				end

				-- TEMP = S5(A) + ft(B,C,D) + E + Wt + Kt; 
				TEMP = ADD(ROTATE(5, A), f, E, W[t], K)

				--E = D;   D = C;    C = S30(B);   B = A;   A = TEMP;
				E = D
				D = C
				C = ROTATE(30, B)
				B = A
				A = TEMP

				--printf("t = %2d: %s  %s  %s  %s  %s", t, A:HEX(), B:HEX(), C:HEX(), D:HEX(), E:HEX())
			end

			-- Let H0 = H0 + A, H1 = H1 + B, H2 = H2 + C, H3 = H3 + D, H4 = H4 + E. 
			H0 = ADD(H0, A)
			H1 = ADD(H1, B)
			H2 = ADD(H2, C)
			H3 = ADD(H3, D)
			H4 = ADD(H4, E)
		end

		return asHEX(H0) .. asHEX(H1) .. asHEX(H2) .. asHEX(H3) .. asHEX(H4)
	end

	return sha1
end)()

local builtins = {
	-- Lua Functions
	["assert"] = true;["collectgarbage"] = true;["error"] = true;["getfenv"] = true;
	["getmetatable"] = true;["ipairs"] = true;["loadstring"] = true;["newproxy"] = true;
	["next"] = true;["pairs"] = true;["pcall"] = true;["print"] = true;["rawequal"] = true;
	["rawget"] = true;["rawset"] = true;["select"] = true;["setfenv"] = true;["setmetatable"] = true;
	["tonumber"] = true;["tostring"] = true;["type"] = true;["unpack"] = true;["xpcall"] = true;

	-- Lua Tables
	["bit32"] = true;["coroutine"] = true;["debug"] = true;
	["math"] = true;["os"] = true;["string"] = true;
	["table"] = true;["utf8"] = true;

	-- Roblox Functions
	["delay"] = true;["elapsedTime"] = true;["gcinfo"] = true;["require"] = true;
	["settings"] = true;["spawn"] = true;["tick"] = true;["time"] = true;["typeof"] = true;
	["UserSettings"] = true;["wait"] = true;["warn"] = true;["ypcall"] = true;

	-- Roblox Variables
	["Enum"] = true;["game"] = true;["shared"] = true;["script"] = true;
	["workspace"] = true;

	-- Roblox Tables
	["Axes"] = true;["BrickColor"] = true;["CellId"] = true;["CFrame"] = true;["Color3"] = true;
	["ColorSequence"] = true;["ColorSequenceKeypoint"] = true;["DateTime"] = true;
	["DockWidgetPluginGuiInfo"] = true;["Faces"] = true;["Instance"] = true;["NumberRange"] = true;
	["NumberSequence"] = true;["NumberSequenceKeypoint"] = true;["PathWaypoint"] = true;
	["PhysicalProperties"] = true;["PluginDrag"] = true;["Random"] = true;["Ray"] = true;["Rect"] = true;
	["Region3"] = true;["Region3int16"] = true;["TweenInfo"] = true;["UDim"] = true;["UDim2"] = true;
	["Vector2"] = true;["Vector2int16"] = true;["Vector3"] = true;["Vector3int16"] = true;
}

local Environment = (getfenv or function() return _G end)(0) --(getfenv or getenv or os.getenv or os.getfenv)(0)
local Variables = {}
local Addresses = {}
local CurrentLine = 1

function SplitString(inputstr, sep)
    if string.split then
        return string.split(inputstr, sep)
    else
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t 
    end
end

function SplitIntoCharacters(input)
    local Table = {}
    for i = 1, #input do 
        table.insert(Table, string.sub(input, i, i))   
    end
    return Table
end

function HashToAddress(___)
	return (function()
		local Hash = SHA1(___):sub(1, 8)
		if tostring(Hash:sub(1, 1)) == "0" then
			Hash = "f"..Hash:sub(2)
		end
		return Hash:upper()
	end)()
end

for __, _ in pairs(builtins) do
	if Environment[__] then
		local Hash = HashToAddress(__)
		Addresses[Hash] = {
			__ = __,
			___ = Environment[__]
		}
	end
end

function ReverseTable(Table)
	local ReversedTable = {}
	for i = 0, #Table - 1 do
		table.insert(ReversedTable,  Table[(#Table) - i])
	end
	return ReversedTable
end

function RetrieveInstruction(_Address)
	local Address = tostring(_Address:upper())
	if Addresses[Address] then
		-- INSTRUCTION
		return Addresses[Address]["___"]
	else
		if Address:sub(1, 1) == "0" then
			-- NUMBER?!??!!?
			return tonumber(Address)
		elseif Address:sub(1, 1) == "Z" then
			local VariableName = Address:sub(2, 7)
			for ___, ____ in pairs({
				-- GENERAL PURPOSE
				["0"] = function()
					-- RETRIEVE VARIABLE
					return Variables[VariableName]
				end,
				["1"] = function(Argument)
					-- SET VARIABLE
					if tonumber(Argument) then
						Argument = tonumber(Argument)
					end
					Variables[VariableName] = Argument
				end,
				-- NUMBERS AND STUFFS
				["2"] = function(Number)
				    -- ADD
				    if tonumber(Number) ~= Number then
				        return print('Number to operate on must be an int') 
				    end
				    return Variables[VariableName] + Number
				end,
				["3"] = function(Number)
				    -- SUB
				    if tonumber(Number) ~= Number then
				        return print('Number to operate on must be an int') 
				    end
				    return Variables[VariableName] - Number
				end,
				["4"] = function(Number)
				    -- MUL
				    if tonumber(Number) ~= Number then
				        return print('Number to operate on must be an int') 
				    end
				    return Variables[VariableName] * Number
				end,
				["5"] = function(Number)
				    -- DIV
				    if tonumber(Number) ~= Number then
				        return print('Number to operate on must be an int') 
				    end
				    return Variables[VariableName] / Number
				end,
				["6"] = function()
				    -- NEG
				    return -Variables[VariableName]
				end,
				["7"] = function()
				    -- OPP
				    return not Variables[VariableName]
				end,
				-- STRING FUNCTIONS
				["A"] = function(...)
					-- SET NEXT CHAR
					if type(({...})[1]) == "string" then
					    for _, CharacterNumber in pairs({...}) do
					        Variables[VariableName] = Variables[VariableName] .. CharacterNumber 
					    end
					else
					    for _, CharacterNumber in pairs({...}) do--ReverseTable({...})) do
    						if Variables[VariableName] then
    							if tostring(Variables[VariableName]) ~= Variables[VariableName] then
    								print('Can\'t edit a non-string variable!')
    								break
    							end
    						else
    							Variables[VariableName] = ""
    						end
    						if tonumber(CharacterNumber) ~= CharacterNumber then
    							print('Can\'t edit a string variable with '..type(CharacterNumber)..'! Please use a number.')
    							break
    						end
    						Variables[VariableName] = Variables[VariableName] .. string.char(CharacterNumber)
    					end
					end
					
			    end,
			    -- IF STATEMENTS
			    ["B"] = function(...)
			        return Variables[VariableName] == ({...})[1]
			    end,
			    ["C"] = function(...)
			        return Variables[VariableName] > ({...})[1]
			    end,
			    ["D"] = function(...)
			        return Variables[VariableName] < ({...})[1]
			    end,
			    ["E"] = function(...)
			        return Variables[VariableName] >= ({...})[1]
			    end,
			    ["F"] = function(...)
			        return Variables[VariableName] <= ({...})[1]
			    end,
			}) do
				if ___ == Address:sub(8) then
					return ____
				end
			end
		else
			return _Address
		end
	end
end

function EnforceRules(Instruction, DoesntFollowRules)
	local FollowsRules = true
	if #Instruction ~= 8 then
		FollowsRules = false
	end
	if Instruction ~= string.upper(Instruction) then
		FollowsRules = false
	end
	
	if not FollowsRules then
		DoesntFollowRules()
	end
end
function HandleArguments(Instruction, DoesntFollowRules)
	local HandleArgument = function(Argument, Arguments)
		EnforceRules(Argument, function()
			return DoesntFollowRules()
		end)
		local InstructionFunction = RetrieveInstruction(Argument)
		if type(InstructionFunction) == "function" then
			InstructionFunction = InstructionFunction(table.unpack(Arguments or {}))
		end
		return InstructionFunction
	end
	local Arguments = {}
	if #Instruction > 1 then
		-- Run arguments backwards.
		local ReversedArguments = {}
		for _, _Instruction in pairs(ReverseTable(Instruction)) do
		    local PiledArguments = {}
			for e = 0, #ReversedArguments - 1 do
				local _Argument = ReversedArguments[(#ReversedArguments) - e]
				table.insert(PiledArguments, _Argument)
				--print(_Argument)
			end
			table.insert(ReversedArguments, HandleArgument(_Instruction, PiledArguments)) 
		end
		Arguments = ReverseTable(ReversedArguments)
	else
		-- We can just handle the first argument, by itself.
		table.insert(Arguments, HandleArgument(Instruction[1]))
	end
	return Arguments
end

function Interpret(UnparsedScript)
    CurrentLine = 1
	local Script = SplitString(UnparsedScript, '\n')
	local OK = true
	while CurrentLine <= #Script and OK do
		if Script[CurrentLine]:sub(1, 1) == "#" then
			-- It's a comment. Let's ignore it.
		else
			local Instruction = SplitString(Script[CurrentLine], ' ')
			local InstructionFunction = RetrieveInstruction(Instruction[1])
			EnforceRules(Instruction[1], function()
				print('Syntax error')
				OK = false
				return
			end)
			if InstructionFunction then
				if type(InstructionFunction) == "function" then
					table.remove(Instruction, 1)
					local Arguments = HandleArguments(Instruction, function()
						print('Syntax error')
						OK = false
						return
					end)
					InstructionFunction(table.unpack(Arguments))
				else
					print('Not function, skipping~')
				end
			end
		end
		CurrentLine = CurrentLine + 1
	end
end

for __, ___ in pairs({
    -- # GENERAL PURPOSE
	['getindex'] = function(From, ...)
		local Initial = From
		for _, Index in pairs({...}) do
			if Initial[Index] then
				Initial = Initial[Index]
			end
  		end
	    return Initial
	end,
	['setindex'] = function(ToSet, Index, Value)
	    ToSet[Index] = Value
	end,
	['createtable'] = function(...)
	    local InitialTable = {}
	    for _, Argument in pairs({...}) do
	        table.insert(InitialTable) 
	    end
	    return InitialTable
	end,
	['tick'] = function()
	    return game:GetService('RunService').Heartbeat:Wait()
	end,
	-- # JUMPS
	['jump'] = function(Jump, Condition)
	    if type(Jump) == "table" then
	        if Jump.JumpSpot then
	            if Condition ~= nil then
	                if Condition then
	                    CurrentLine = Jump.JumpSpot  
	                end
	            else
	                CurrentLine = Jump.JumpSpot  
	            end
	        end
	    end
	end,
	['createjumpspot'] = function(Line)
	    return {
	        JumpSpot = (Line or CurrentLine)    
	    }
	end
}) do
	local Hash = HashToAddress(__)
	Addresses[Hash] = {
		__ = __,
		___ = ___
	}
end

return {
  init = Interpret,
  hookprint = function()
    local event = Instance.new('BindableEvent')
    print = function()
      event:Fire()
    end
    return event.Event
  end
  instructions = Addresses
}
