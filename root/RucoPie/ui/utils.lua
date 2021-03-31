local colors = require 'colors'
local constants = require 'constants'

local utils = {
  split = function (str, sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
  end,

  join = function (delimiter, list)
    local len = #list
    if len == 0 then return '' end
    local str = list[1]
    for i = 2, len do 
       str = str .. delimiter .. list[i] 
    end
    return str
  end,

  debug = function (...)
    if _G.debug then
      print(...)
    end
  end
}

local function escapeValue(value)
  if 'string' == type(value) then value = value:gsub("'", "\\'") end
  return value
end

local function formatKey(key)
  if type(key) == 'number' or
     type(key) == 'boolean' then
      key = '[' .. key .. ']'
  else -- string or others
    key = '[\'' .. key .. '\']'
  end

  return key
end

-- based on http://lua-users.org/wiki/TableSerialization
-- caution, this won't work on any arbitrary table
utils.tableToString = function (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == 'table' then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (' ', indent)) -- indent it
      if type (value) == 'table' and not done [value] then
        done [value] = true
        table.insert(sb, formatKey(key) .. ' = {\n');
        table.insert(sb, utils.tableToString(value, indent + 2, done))
        table.insert(sb, string.rep (' ', indent)) -- indent it
        table.insert(sb, '},\n');
      elseif "number" == type(key) then
        table.insert(sb, string.format("\'%s\',\n", tostring(escapeValue(value))))
      else
        local valueFotmat = "'%s'"
        if type(value) == 'number' or type(value) == 'boolean' then
          valueFotmat = "%s"
        end
      
        local v = tostring(escapeValue(value))
        table.insert(sb, string.format(
            '%s = ' .. valueFotmat .. ',\n', tostring (formatKey(key)), v))
      end
    end
    return table.concat(sb)
  else
    return tt .. ',\n'
  end
end

utils.pp = function (text, x, y, data)
  x, y = x or 0, y or 0
  data = data or {}
  local shadowText = text
  if type(text) == 'table' then -- colored text table
    shadowText = ''
    for i = 2, #text, 2 do
      shadowText = shadowText .. (text[i] or '')
    end
  end

  love.graphics.setColor(data.shadowColor or colors.black)
  love.graphics.print(shadowText, math.floor(x - 1), math.floor(y + 1))

  love.graphics.setColor(data.fgColor or colors.white)
  love.graphics.print(text, math.floor(x), math.floor(y))
end

utils.drawWithShadow = function (img, x, y, data)
  x = x or 0
  y = y or 0
  data = data or {}

  love.graphics.setColor(data.shadowColor or colors.black)
  love.graphics.draw(img, math.floor(x - 1), math.floor(y + 1))

  love.graphics.setColor(data.fgColor or colors.white)
  love.graphics.draw(img, math.floor(x), math.floor(y))
end

utils.initPage = function ()
  return { pageNumber = 1, indexAtCurrentPage = 1 }
end

return utils
