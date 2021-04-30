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
    -- help needed, when using this filter, there's some ugly tearing effects:
    --img:setFilter('nearest', 'nearest')
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
  if not _G.currentTheme then return end

  dt = love.timer.getDelta()
  for _, bg in ipairs(_G.currentTheme.backgrounds) do
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
    -- help needed, when setting using floor, layers movement becomes non-smooth after changing themes
    bg.quad:setViewport(math.floor(bg.dispX), math.floor(bg.dispY), w, h)
    
    -- this is a workaround but it's not correct (will show perfect pixels with aliasing)
    -- bg.quad:setViewport(bg.dispX, bg.dispY, w, h)
  end
end

function themeManager:setTheme(folder)
  local data = osBridge.readFile('ui/assets/themes/' .. folder .. '/theme.lua')
  local dataFromFile = loadstring(data)()

  local theme = {}
  theme.backgrounds = initBackgrounds(dataFromFile, folder)
  theme.opacity = dataFromFile.opacity or 0.5

  self.currentThemeName = folder
  _G.currentTheme = theme
end

function themeManager:updateSmoothUI(value)
  if value then
    _G.canvas:setFilter('linear', 'linear')
    _G.videoModePreviewCanvas:setFilter('linear', 'linear')
  else
    _G.canvas:setFilter('nearest', 'nearest')
    _G.videoModePreviewCanvas:setFilter('nearest', 'nearest')
  end
end

function themeManager:drawCurrentTheme()
  love.graphics.setColor(colors.white)  

  local bgs = _G.currentTheme.backgrounds
  for i = #bgs, 1, -1 do
    love.graphics.draw(bgs[i].img, bgs[i].quad, 0, 0, 0, 1, 1)
  end
  love.graphics.setColor(0, 0, 0, _G.currentTheme.opacity)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

themeManager:setTheme(_G.preferences.theme)

return themeManager
