local osBridge = require 'os-bridge'
local colors = require 'colors'
local constants = require 'constants'
local utils = require 'utils'

local themeManager = {}

local function initBackgrounds(data, folder)
  local bgs = {}
  if type(data.background) == 'string' then
    data.background = {
      { data.background, 0, 0, 0.5 }
    }
  end

  for i = 1, #data.background do
    local item = data.background[i]
    local img = love.graphics.newImage('assets/themes/'.. folder .. '/img/' .. item[1])
    img:setWrap('repeat', 'repeat')
    --img:setFilter('nearest', 'linear')
    table.insert(bgs, {
      img = img,
      quad = love.graphics.newQuad(0, 0, constants.CANVAS_WIDTH, constants.CANVAS_HEIGHT,
        img:getWidth(), img:getHeight()),
      speedX = item[2] or 0,
      speedY = item[3] or 0,
      dispX = 0,
      dispY = 0
    })
  end
  return bgs
end

function themeManager:update(dt)
  if not self.currentTheme then return end

  dt = love.timer.getDelta()
  for _, bg in ipairs(self.currentTheme.backgrounds) do
    local _, _, w, h = bg.quad:getViewport()
    local xDirection, yDirection = 1, 1

    if bg.speedX < 0 then xDirection = -1 end
    if bg.speedY < 0 then yDirection = -1 end

    bg.dispX = bg.dispX - dt * bg.speedX
    bg.dispY = bg.dispY - dt * bg.speedY

    -- return quad to the equivalent [0, 0] position
    if (math.abs(bg.dispX) >= bg.img:getWidth()) or (math.abs(bg.dispY) >= bg.img:getHeight()) then
      bg.dispX = (bg.img:getWidth()  - math.abs(bg.dispX)) * xDirection
      bg.dispY = (bg.img:getHeight() - math.abs(bg.dispY)) * yDirection
    end

    -- move quad viewport
    bg.quad:setViewport(math.floor(bg.dispX), math.floor(bg.dispY), w, h)
    --bg.quad:setViewport(bg.dispX, bg.dispY, w, h)
  end
end

function themeManager:loadTheme(folder)
  local escapedFolder = folder:gsub(' ', '\\ ')
  local data = osBridge.readFile('ui/assets/themes/' .. escapedFolder .. '/theme.lua')
  local dataFromFile = loadstring(data)()

  local theme = {}
  theme.backgrounds = initBackgrounds(dataFromFile, folder)
  theme.darkness = dataFromFile.darkness or 0.5
  self.currentTheme = theme
end

function themeManager:drawCurrentTheme()
  love.graphics.setColor(colors.white)  

  local bgs = self.currentTheme.backgrounds
  for i = #bgs, 1, -1 do
    love.graphics.draw(bgs[i].img, bgs[i].quad, 0, 0, 0, 1, 1)
  end
  love.graphics.setColor(0, 0, 0, self.currentTheme.darkness)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

themeManager:loadTheme('Super Mario World Scroll') -- default theme

return themeManager
