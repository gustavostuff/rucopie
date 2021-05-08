local osBridge = require 'os-bridge'
local colors = require 'colors'
local constants = require 'constants'
local utils = require 'utils'
local k = require 'lib/katsudo'
local images = require 'images'
local lfs = require 'lfs'

local themeManager = {}

local function initBackgrounds(data, folder)
  local bgs = {}
  if type(data.background) == 'string' then
    data.background = {
      { data.background, speedX = 0, speedY = 0 }
    }
  end

  for i = 1, #data.background do
    local item = data.background[i]
    local img = love.graphics.newImage('assets/themes/'.. folder .. '/img/backgrounds/' .. item[1])
    local layerAnimInfo = item.animation or {}
    img:setWrap('repeat', 'repeat')
    -- help needed, when using this filter, there's some ugly tearing effects:
    img:setFilter('nearest', 'nearest')
    local animation = k.new(img,
      layerAnimInfo.w or img:getWidth(),
      layerAnimInfo.h or img:getHeight(),
      layerAnimInfo.total or 1,
      layerAnimInfo.delay or 1
    )
    animation.x = layerAnimInfo.x
    animation.y = layerAnimInfo.y
    table.insert(bgs, {
      animation = animation,
      isAnimated = layerAnimInfo.total,
      quad = love.graphics.newQuad(0, 0, constants.CANVAS_WIDTH, constants.CANVAS_HEIGHT,
        animation.w, animation.h),
      speedX = item.speedX or 0,
      speedY = item.speedY or 0,
      dispX = 0,
      dispY = 0
    })
  end
  return bgs
end

local function initImages(theme, dataFromFile, themeFolder)
  local path = constants.THEMES_DIR .. '/' .. themeFolder .. '/img/'
  local images = {}
  for file in lfs.dir(path) do
    if file ~= "." and file ~= ".." and file:find('.png$') then
      images[file] = love.graphics.newImage('assets/themes/' .. themeFolder .. '/img/' .. file)
      images[file]:setFilter('nearest', 'nearest')
    end
  end

  return images
end

function themeManager:update(dt)
  if not _G.currentTheme then return end

  k.update(dt)

  dt = love.timer.getDelta()
  for _, bg in ipairs(_G.currentTheme.backgrounds) do
    local _, _, w, h = bg.quad:getViewport()
    local xDirection, yDirection = 1, 1

    if bg.speedX < 0 then xDirection = -1 end
    if bg.speedY < 0 then yDirection = -1 end

    bg.dispX = bg.dispX - dt * bg.speedX
    bg.dispY = bg.dispY - dt * bg.speedY

    -- return quad to the equivalent [0, 0] position
    if (math.abs(bg.dispX) >= bg.animation.w) or (math.abs(bg.dispY) >= bg.animation.h) then
      bg.dispX = (bg.animation.w  - math.abs(bg.dispX)) * xDirection
      bg.dispY = (bg.animation.h - math.abs(bg.dispY)) * yDirection
    end

    -- move quad viewport
    -- help needed, when setting using floor, layers movement becomes non-smooth after changing themes
    --bg.quad:setViewport(math.floor(bg.dispX), math.floor(bg.dispY), w, h)
    
    -- this is a workaround but it's not correct (will show perfect pixels with aliasing)
    bg.quad:setViewport(bg.dispX, bg.dispY, w, h)
  end
end

function themeManager:setTheme(folder)
  local path = 'ui/assets/themes/' .. folder .. '/'
  local data = osBridge.readFile(path .. 'theme.lua')
  local dataFromFile = loadstring(data)()

  local theme = {}
  theme.backgrounds = initBackgrounds(dataFromFile, folder)
  theme.opacity = dataFromFile.opacity or 0.5
  theme.shadow = dataFromFile.shadow
  theme.shadowColor = dataFromFile.shadowColor or colors.black
  theme.fontColor = dataFromFile.fontColor or colors.white
  theme.selectionColor = dataFromFile.selectionColor
  theme.cursorBehind = dataFromFile.cursorBehind
  theme.title = dataFromFile.title or {} -- coords
  theme.listBounds = dataFromFile.listBounds or constants.DEFAULT_LIST_BOUNDS
  theme.caption = dataFromFile.caption or {}
  theme.palette = dataFromFile.palette or {}
  theme.images = initImages(theme, dataFromFile, folder)

  theme.name = folder
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
    local bg = bgs[i]
    if bg.isAnimated then
      bg.animation:draw(bg.animation.x or 0, bg.animation.y or 0)
    else
      love.graphics.draw(bg.animation.img, bg.quad, 0, 0, 0, 1, 1)
    end
  end
  love.graphics.setColor(0, 0, 0, _G.currentTheme.opacity)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

themeManager:setTheme(_G.preferences.theme)

return themeManager
