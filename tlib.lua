-- ========================{HEADER}========================|
-- AUTHOR: wellyton 'welly' <welly.tohn@gmail.com> 
-- DESCRIPTION: stdlib for tortoise development
-- LIBNAME: Tlib 
-- LICENSE: MIT
-- ========================{ END }========================|
local tlib = {}

function tlib.import(full_path)
   local path, modname
   
   if full_path:match("^%./") then
      path, modname = full_path:match("^(.*/)([^/]+)$")
      path = path or "./"
   else
      path, modname = full_path:match("^(.-)/([^/]+)$")
   end
   
   if not modname then
      error("Invalid path. Make shure that has a valid module name.")
   end
   
   package.path = package.path .. string.format(";./%s/?.lua", path)

   return require(modname), package.path, path, modname
end

local debug_info = debug.getinfo(1, "S")
tlib.__dirname = debug_info.source:gsub("@", ""):match("(.*/)")
tlib.__filename = debug_info.source:gsub("@", ""):match("([^/]+)$")

function tlib.fmt(msg, ...)
   return string.format(msg, ...)
end

function tlib.printf(msg, ...)
    io.write(string.format(msg, ...))
end

function tlib.println(msg, ...)
    tlib.printf(msg .. "\n", ...)
end

function tlib.exit(code)
    os.exit(code)
end


function tlib.parse_args(...)
   local args = {...}
   local cmd = table.concat(args, " ")
   return cmd
end

function tlib.exec(...)
   local cmd = tlib.parse_args(...)
   return os.execute(cmd)
end

function tlib.run(...)
   local cmd = tlib.parse_args(...)
   local out = io.popen(cmd .. " 2>&1")
   if not out then
      return nil, "Failed to run command: " .. cmd
   end
   local result = out:read("*a")
   local success, exit_code = out:close()
   if success == nil then
      success = false
   end
   return result, success, exit_code, cmd
end

function tlib.write_file(filename, access, content)
   local file = io.open(filename, access)
   if not file then
      error("Failed to open file: " .. filename)
   end
   file:write(content)
   file:close()
end

function tlib.read_file(filename)
   local file = io.open(filename)
   if not file then
      error("Failed to open file: " .. filename)
   end
   local content = file:read("*a")
   file:close()
   return content
end

function tlib.mkdir(dir)
   tlib.run("mkdir " .. dir)
end

function tlib.ls(dir)
   tlib.run("ls " .. dir)
end

function tlib.rmdir(dir)
   local ok, err = os.remove(dir)
   if not ok then
      error("Failed to remove directory: " .. dir .. " - " .. (err or "unknown error"))
   end
end

function tlib.mkfile(filename)
   local file = io.open(filename, "w")
   if not file then
      error("Failed to create file: " .. filename)
   end
   file:write("")
   file:close()
end

function tlib.file_exist(filename)
   local file = io.open(filename)
   if file then
      return true
   else
      return false
   end
end

function tlib.check_args(argi, expected, func)
   for _, v in ipairs(expected) do
      if argi == v then
         func()
         break
      end
   end
end

function tlib.verify_args(argi, expected)
   for ai, _ in ipairs(argi) do
      for ei, ev in ipairs(expected) do
	      if argi[ai] == ev then
	         return true
	      end
      end
   end
   return false
end

function tlib.get_arg(argi, index)
   return argi[index]
end

function tlib.check_lib(lib_table)
   for k, v in pairs(lib_table) do
      print(k, v)
   end
end

return tlib