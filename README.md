<h1 align="center">
  SEKAIscript
</h1>

The sh\*tty scripting language you didn't ask for, but you got anyways.

## Note from Author

guys im so sorry i did not know what the fuck a hexadecimal was until like a month ago</br>
give me a break :sob: i can make a better version of this in the future

## (Intentional) Limitations
 - Instructions must be split by whitespaces, and new lines.
 - Instructions can only contain A-F, Y-Z, 0-9 (not enforced just yet because idk how to use regex lol)
 - Tabs currently break the code, this will be fixed very soon :3
 - Spaces left over will likely break the script.
 - Returned functions will automatically be called. This is easier to understand after looking at an example.
 
And keep in mind that arguments start from the back of the list, to the front of the list.
 
## Instructions

`call (function) (arguments)`
Calls a Lua / Luau function.
***
`getindex (from) (index or indexes)`
Returns index (or indexes) of an object.
***
`setindex (toset) (index) (value)`
Set specified index of a value.
***
`createtable (optional values)`
Returns a new table, with optional values preset.
***
`tick`
Waits until the next Heartbeat.
***
`createjumpspot (optional number, line)`
Returns a JUMPSPOT. This should be used while setting a variable.
***
`jump (variable) (optional condition)`
Jumps to the line the variable supplied is set to, and if an optional boolean is set, it'll check that first.

## Additionally,

Here's even more things you should know about!

### Examples

It is ***highly*** recommended you check out [the examples supplied](/examples).<br>
~~It will make understanding this hellish scripting language so much easier.~~<br>
It really won't make it any easier to understand but rather convince you to not do it

### Variables

Variables are pretty simple, and have a very little learning curve.<br>
Here we go!

Variables are always defined like this: `Zxxxxxx?` (`x`'s can be anything (this is the name for the variable), `?` is where you'd place the instruction).<br>
So, here's the full list of variable-only instructions.

#### GENERAL PURPOSE
`0` - Retrieves / Returns the variable.
***
`1 (value)` - Sets the variable to the supplied value, or nil if there isn't a supplied value (I think)
#### OPERATIONS
`2 (number)` - Returns the variable added with the number argument
***
`3 (number)` - Returns the variable subtracted by the number argument
***
`4 (number)` - Returns the variable multiplied with the number argument
***
`5 (number)` - Returns the variable divided by the number argument
***
`6 (number)` - Returns the variable, negatively
***
`7 (number)` - Returns the variable, oppositely
#### STRINGS
`A (string or numbers)` - Appends the string or characters supplied (in character codes)
#### IF STATEMENTS
`B (any)` - Returns if the supplied argument is equal to the variable
***
`C (number)` - Returns if the supplied argument is less than the variable
***
`D (number)` - Returns if the supplied argument is greater than the variable
***
`E (number)` - Returns if the supplied argument is less than or equal to the variable
***
`F (number)` - Returns if the supplied argument is greater than or equal to the variable

### Strings

Strings are unique in SEKAIscript.<br>
They work by appending singular characters, by their character codes.<br>
**If you have a more efficient way to do this, please send in an Issue so we can talk this out. Thank you!**

And no, it is *not* efficient, or a good use of space.

Here's an example of a string:
```
# Set variable 123456 to "Hi"
Z123456A 00000072 00000105
```
It's a bit confusing, but I'll explain it so you understand how to use it better.

`ZxxxxxxA` is an **append** function, like mentioned in *Variables*, for strings and strings ONLY.<br>
Every character is defined by it's character code.

And that's pretty much it (about strings)! Have fun, I guess.

*Oh,* **OH!** One last thing...<br>
In [the debug folder](/debug), there's a `string.lua` file. Use that to help with converting the strings into character codes.

### Anything else?
 
If you have any more questions or found an issue with SEKAIscript or it's docs, you can create a Github Issue.<br>
Thank you for reading!
 
### Instruction Lookup (SHA1)
```
64A68346 | NumberSequence
74D7279A | rawset
BE835E7B | tostring
12AA5485 | rawequal
59E472EA | ipairs
714EEA0F | time
C30AFEAE | Vector2int16
579233B2 | owner
AA3900D2 | pcall
3CC1D5A4 | settings
CDA051C9 | game
5EB702C6 | elapsedTime
5E0327F3 | pairs
9025095A | Vector3int16
5FD7BA90 | TweenInfo
ECB25204 | string
6D0D5876 | print
20588AE8 | Enum
DAAAD336 | wait
D75F36F8 | Axes
2DCEFF1F | newproxy
3781580E | UDim
EDEE9402 | next
81F0C4AB | utf8
AB464F02 | delay
871EA5A9 | UDim2
8663E544 | Color3
3F73B4B6 | PathWaypoint
42243507 | NumberSequenceKeypoint
11F9578D | error
9CF00858 | coroutine
88863BBF | getfenv
D0C524A2 | collectgarbage
999A3419 | os
7A488390 | math
FCDC5B67 | NumberRange
6227120A | spawn
81448FE2 | select
7CF14E71 | setfenv
38321681 | tick
E97BCFAF | Region3
284F65E8 | xpcall
A279FE91 | workspace
F1E5BAF5 | DateTime
E3B144A8 | bit32
62B69FE2 | DockWidgetPluginGuiInfo
D29A653D | Rect
64B5DAAD | assert
EB23EFBB | Ray
C476FD00 | Vector2
2FDF8528 | PluginDrag
1B16A5CB | PhysicalProperties
5F97F877 | Instance
DCD5CCD5 | getmetatable
6C6B1890 | loadstring
C3EE137D | table
FDBB8FEF | Faces
58D888C0 | Random
C794E409 | ColorSequenceKeypoint
69835E2B | ColorSequence
4C8EA476 | warn
32FAAECA | debug
F8E186AC | BrickColor
CB5346A0 | script
9A106745 | unpack
696654EA | ypcall
E469D035 | CFrame
F34223F4 | tonumber
37029A35 | Region3int16
623E76C3 | require
B950BDB9 | gcinfo
FD1AB5B3 | CellId
F042FBB3 | UserSettings
F0DB3ECC | setmetatable
7CFE65A1 | Vector3
D18AAC96 | shared
D0A3E7F8 | type
777B6542 | rawget
F8D09C40 | getindex
BC0778C3 | setindex
271E9A56 | jump
FC8353F8 | createjumpspot
68918072 | createtable
38321681 | tick
BC8D8647 | call
```
