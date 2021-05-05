local utils = {}
local colors = require 'colors'
local constants = require 'constants'
local t = require 'translator'

local captionColorMap = {
  A = colors.green,
  B = colors.red,
  Start = colors.blue,
  Select = colors.yellow,
  X = colors.orange
}

local shadowCellMap = { -- shadow/cell directions for shadowed text
  {-1, 0}, {1, 0}, {0, -1}, {0, 1}, {-1, -1}, {-1, 1}, {1, -1}, {1, 1}
}

utils = {
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
  local fgText
  if type(text) == 'table' then -- colored text table
    shadowText = ''
    fgText = {unpack(text)}
    for i = 2, #text, 2 do
      fgText[i] = t.get(text[i]) -- translate
      shadowText = shadowText .. (fgText[i] or '')
    end
  else
    -- translate
    fgText = t.get(text)
    shadowText = t.get(text)
  end

  love.graphics.setColor(data.shadowColor or colors.black)

  if data.centered then
    x = constants.CANVAS_WIDTH / 2 - _G.font:getWidth(shadowText) / 2
    y = constants.CANVAS_HEIGHT / 2 - _G.font:getHeight() / 2
  elseif data.centeredX then
    x = constants.CANVAS_WIDTH / 2 - _G.font:getWidth(shadowText) / 2
  elseif data.centeredY then
    y = constants.CANVAS_HEIGHT / 2 - _G.font:getHeight() / 2
  end

  if data.shadow then
    if data.cell then
      for _, d in ipairs(shadowCellMap) do
        love.graphics.print(shadowText, math.floor(x + d[1]), math.floor(y + d[2]))
      end
    else
      --love.graphics.print(shadowText, math.floor(x - 1), math.floor(y + 1))
      love.graphics.print(shadowText,
      math.floor(x + shadowCellMap[6][1]), math.floor(y + shadowCellMap[6][2]))
    end
  end

  love.graphics.setColor(data.fontColor or colors.white)
  --love.graphics.print(fgText, math.floor(x), math.floor(y))
  love.graphics.print(fgText, math.floor(x), math.floor(y))
end

utils.draw = function (drawable, x, y, options)
  x = x or 0
  y = y or 0
  options = options or {}

  local originX, originY = 0, 0
  local scale = options.scale or 1
  if options.centered then
    originX = math.floor(drawable:getWidth() / 2)
    originY = math.floor(drawable:getHeight() / 2)
  elseif options.centeredX then
    originX = math.floor(drawable:getWidth() / 2)
  elseif options.centeredY then
    originY = math.floor(drawable:getHeight() / 2)
  end

  if options.shadow then
    love.graphics.setColor(options.shadowColor or colors.black)
    love.graphics.draw(drawable, math.floor(x - 1), math.floor(y + 1),
      0, scale, scale, originX, originY)
  end

  love.graphics.setColor(optionsTree.fontColor or colors.white)
  love.graphics.draw(drawable,
    math.floor(x),
    math.floor(y),
    0,
    scale,
    scale,
    originX,
    originY
  )
end

utils.getDisplayLabel = function (line)
  for i, ext in ipairs(constants.extensionsToRemove) do
    line = line:gsub('.' .. ext .. '$', '')
  end
  return line
end

utils.getCaption = function (data)
  local caption = {}
  for i, captionItem in ipairs(data) do
    local button = captionItem[1]
    local label = captionItem[2]
    table.insert(caption, captionColorMap[button] or colors.white)
    table.insert(caption, button .. ':')
    table.insert(caption, _G.currentTheme.fontColor or colors.white)
    table.insert(caption, label)
    table.insert(caption, colors.white)
    table.insert(caption, '  ')
  end
  return caption
end

utils.initPage = function ()
  return { pageNumber = 1, indexAtCurrentPage = 1 }
end

return utils
