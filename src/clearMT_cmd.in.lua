#!@path_to_lua@/lua
-- -*- lua -*-

--------------------------------------------------------------------------
-- Lmod License
--------------------------------------------------------------------------
--
--  Lmod is licensed under the terms of the MIT license reproduced below.
--  This means that Lua is free software and can be used for both academic
--  and commercial purposes at absolutely no cost.
--
--  ----------------------------------------------------------------------
--
--  Copyright (C) 2008-2013 Robert McLay
--
--  Permission is hereby granted, free of charge, to any person obtaining
--  a copy of this software and associated documentation files (the
--  "Software"), to deal in the Software without restriction, including
--  without limitation the rights to use, copy, modify, merge, publish,
--  distribute, sublicense, and/or sell copies of the Software, and to
--  permit persons to whom the Software is furnished to do so, subject
--  to the following conditions:
--
--  The above copyright notice and this permission notice shall be
--  included in all copies or substantial portions of the Software.
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
--  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
--  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
--  NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
--  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
--  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
--  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
--  THE SOFTWARE.
--
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- getmt:  prints to screen what the value of the ModuleTable is.
--         optionly it writes the state of the ModuleTable is to a
--         dated file.


local cmd = arg[0]
local i,j = cmd:find(".*/")
local cmd_dir = "./"
if (i) then
   cmd_dir = cmd:sub(1,j)
end
package.path = cmd_dir .. "../tools/?.lua;" ..
               cmd_dir .. "?.lua;"       .. package.path

require("strict")
require("fileOps")

local concatTbl    = table.concat
local format       = string.format
local getenv       = os.getenv
local huge         = math.huge

function cmdDir()
   return cmd_dir
end
function bash_export(name, value)
   local a = {}
   if (value == "") then
      a[#a+1] = "unset "
      a[#a+1] = name
      a[#a+1] = ";\n"
   else
      a[#a+1] = name
      a[#a+1] = "=\""
      a[#a+1] = value
      a[#a+1] = "\"; export "
      a[#a+1] = name
      a[#a+1] = ";\n"
   end
   io.stdout:write(concatTbl(a,""))
end

function csh_setenv(name, value)
   local a = {}
   if (value == "") then
      a[#a+1] = "unsetenv "
      a[#a+1] = name
      a[#a+1] = ";\n"
   else
      a[#a+1] = "setenv "
      a[#a+1] = name
      a[#a+1] = " \""
      a[#a+1] = value
      a[#a+1] = "\";\n"
   end
   io.stdout:write(concatTbl(a,""))
end



function main()
   local setenv = bash_export
   if ( arg[1] == "csh" ) then
      setenv = csh_setenv
   end

   for i = 1, huge do
      local name = format("_ModuleTable%03d_",i)
      local v = getenv(name)
      if (v == nil) then break end
      setenv(name,"")
   end
   local mpath = getenv("LMOD_DEFAULT_MODULEPATH") or ""
   setenv("MODULEPATH",              mpath)
   setenv("_ModuleTable_Sz_",        "")
   setenv("LMOD_DEFAULT_MODULEPATH", "")
end

main()
