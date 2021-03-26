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
        table.insert(sb, key .. ' = {\n');
        table.insert(sb, utils.tableToString(value, indent + 2, done))
        table.insert(sb, string.rep (' ', indent)) -- indent it
        table.insert(sb, '},\n');
      elseif "number" == type(key) then
        table.insert(sb, string.format("\'%s\',\n", tostring(value)))
      else
        local valueFotmat = "'%s'"
        if type(value) == 'number' or type(value) == 'boolean' then
          valueFotmat = "%s"
        end
        table.insert(sb, string.format(
            '%s = ' .. valueFotmat .. ',\n', tostring (key), tostring(value)))
      end
    end
    return table.concat(sb)
  else
    return tt .. ',\n'
  end
end

utils.pp = function (text, x, y, shadowColor)
  x, y = x or 0, y or 0
  local bkpColor = {love.graphics.getColor()}
  shadowColor = shadowColor or colors.black
  local shadowText = text
  if type(text) == 'table' then -- colored text table
    shadowText = ''
    for i = 2, #text, 2 do
      shadowText = shadowText .. (text[i] or '')
    end
  end

  love.graphics.setColor(shadowColor)
  love.graphics.print(shadowText, x - 1, y + 1)

  love.graphics.setColor(bkpColor)
  love.graphics.print(text, x, y)
end

utils.initPage = function ()
  return { pageNumber = 1, indexAtCurrentPage = 1 }
end

return utils
