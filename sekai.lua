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
	['call'] = function(ToCall, ...)
	    return ToCall(...)
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
    Environment["print"] = function()
      	event:Fire()
    end
    return event.Event
  end,
  instructions = Addresses
}
