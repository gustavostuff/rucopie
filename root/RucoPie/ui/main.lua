love.filesystem.setIdentity('ruco-pie')
love.graphics.setBlendMode('alpha')

local availableCores = {
  'fceumm',
  'gambatte',
  'fbneo',
  'snes9x',
  'stella2014'
}

_G.flux = require "lib/flux"
_G.debug = true
_G.screenDebug = false
_G.font = love.graphics.newFont('assets/fonts/proggy-tiny/ProggyTinySZ.ttf', 16)
_G.debugFont = love.graphics.newFont('assets/fonts/proggy-tiny/ProggyTinySZ.ttf', 32)
-- _G.font = love.graphics.newFont('assets/fonts/quarlow/Quarlow.ttf', 16)
-- _G.debugFont = love.graphics.newFont('assets/fonts/quarlow/Quarlow.ttf', 32)
_G.videoModePreviews = {}

local indexVideoModePreview = 1

local osBridge = require 'os-bridge'
local colors = require 'colors'
local constants = require 'constants'
local utils = require 'utils'
local images = require 'images'
local t = require 'translator'

if osBridge.fileExists(constants.RUCOPIE_DIR .. 'config/custom-preferences.lua') then
  _G.preferences = loadstring(osBridge.readFile('config/custom-preferences.lua'))()
else
  _G.preferences = loadstring(osBridge.readFile('config/default-preferences.lua'))()
end

local themeManager = require 'theme-manager'
local listManager = require 'list-manager'
local joystickManager = require 'joystick-manager'
local resolutionManager = require 'resolution-manager'
local threadManager = require 'thread-manager'
local virtualKeyboard = require 'virtual-keyboard'

local optionsTree = require 'options-tree'

love.mouse.setVisible(false)
love.graphics.setLineStyle('rough')
love.graphics.setLineWidth(1)

local function printDebug()
  love.graphics.setFont(_G.debugFont)
  if _G.screenDebug then
    
    local n = #listManager.currentList.items
    local totalPages = listManager:getTotalPages()
    local itemsInCurrentPage = listManager:getItemsAtCurrentPage()
    local text = 'FPS: ' .. love.timer.getFPS() ..
    '\nWidth: ' .. love.graphics.getWidth() ..
    '\nHeight: ' .. love.graphics.getHeight() ..
    '\nCanvas Width: ' .. constants.CANVAS_WIDTH ..
    '\nCanvas Height: ' .. constants.CANVAS_HEIGHT ..
    '\n----------------------------------' ..
    '\nitems in list: ' .. n ..
    '\ncurrent page: ' .. listManager.currentList.page.pageNumber ..
    '\npage size: ' .. listManager.pageSize ..
    '\ntotal pages: ' .. totalPages ..
    '\ntotal games (all systems): ' .. _G.systemsTree.totalGames ..
    '\nitems at current page: ' .. itemsInCurrentPage ..
    '\n----------------------------------' ..
    '\ncharacter width (monospaced font should be used): ' .. _G.characterW ..
    '\ncharacter height: ' .. _G.font:getHeight()
    
    local bgw = _G.debugFont:getWidth(text)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle('fill', love.graphics.getWidth() - bgw, 0,
      bgw,
      _G.debugFont:getHeight() * 17
    )

    love.graphics.setColor(colors.white)
    local x = love.graphics.getWidth() - _G.debugFont:getWidth(text)
    utils.pp(text, x, 0, { fontColor = colors.white })
  end

  love.graphics.setFont(_G.font)
end

local function initNavigationStacks()
  listsStack = {
    [_G.screens.systems] = { _G.systemsTree },
    [_G.screens.options] = { optionsTree }
  }
  pathStack = {
    [_G.screens.systems] = {},
    [_G.screens.options] = {}
  }
end

local function setRefreshedGameList()
  listsStack[_G.screens.systems] = { _G.systemsTree }
  pathStack[_G.screens.systems] = {}
  listManager:setCurrentList(_G.systemsTree)
  currentScreen = _G.screens.systems
end

local function loadGameList()
  if osBridge.fileExists(constants.RUCOPIE_DIR .. 'cache/games-tree.lua') then
    _G.systemsTree = loadstring(osBridge.readFile('cache/games-tree.lua'))()
    setRefreshedGameList()
    -- utils.debug('Systems tree from cache:\n', '{' .. utils.tableToString(_G.systemsTree) .. '}')
  else
    _G.refreshSystemsTree()
  end
end

local function initCanvas()
  _G.canvas = love.graphics.newCanvas(constants.CANVAS_WIDTH, constants.CANVAS_HEIGHT)
  _G.videoModePreviewCanvas = love.graphics.newCanvas(constants.CANVAS_WIDTH, constants.CANVAS_HEIGHT)
  -- stencilCanvas = love.graphics.newCanvas(
  --   constants.CANVAS_WIDTH,
  --   constants.CANVAS_HEIGHT,
  --   { format ='stencil8' }
  -- )
  _G.canvas:setFilter('nearest', 'nearest')
  _G.videoModePreviewCanvas:setFilter('nearest', 'nearest')
  -- stencilCanvas:setFilter('nearest', 'nearest')
  scaleX = love.graphics.getWidth() / constants.CANVAS_WIDTH
  scaleY = love.graphics.getHeight() / constants.CANVAS_HEIGHT
end

_G.updateVideoModePreviews = function ()
  for _, item in pairs(_G.videoModePreviews) do
    if _G.preferences.video.smoothGames then
      item.img:setFilter('linear', 'linear')
    else
      item.img:setFilter('nearest', 'nearest')
    end
  end
end

local function initPreferences()
  themeManager:updateSmoothUI(_G.preferences.video.smoothUI)
  t.set(_G.preferences.lang)
end

local function initVirtualKeyboard()
  virtualKeyboard:setGrid(constants.VIRTUAL_KEYBOARD)
end

local function shouldDrawVideoModePreview()
  return not joystickManager.isCurrentlyMapping and
    _G.currentJoystick and
    _G.currentJoystick:isDown(joystickManager:getButton('X')) and
    listManager.currentList.internalLabel == 'Video'
end

local function drawCurrentList()
  if not listManager.currentList then return end
  
  local title = (
    constants.systemsLabels[listManager.currentList.internalLabel] or
    listManager.currentList.internalLabel or
    listManager.currentList.title
  )
  local x = constants.CANVAS_WIDTH / 2 - _G.font:getWidth(title) / 2
  local y = listManager.listBounds.y - listManager.lineHeight
  local titleData = _G.currentTheme.title
  utils.pp(title, titleData.x or x, titleData.y or y, _G.getPrintingParameters({
    fontColor = titleData.color or _G.currentTheme.fontColor or colors.white
  }))
  love.graphics.setColor(colors.white)
  if listManager.currentList then
    listManager:draw(scaleX, scaleY)
  end
end

local function getGeneralCaption(screen)
  local label = 'Options'
  if screen == screens.options then label = 'Systems' end
  return utils.getCaption({
    { 'A', 'OK' },
    { 'B', 'Back' },
    { 'Start', label }
  })
end

local function drawCurrentCaption()
  if not listManager.currentList then return end

  love.graphics.setColor(colors.white)
  local caption = (virtualKeyboard.active and virtualKeyboard.getCaption()) or
    (listManager.currentList.getCaption and listManager.currentList.getCaption()) or
    getGeneralCaption(currentScreen)
  local x = _G.currentTheme.caption.x or listManager.listBounds.x
  local y = _G.currentTheme.caption.y or (listManager.listBounds.y + listManager.listBounds.h)

  utils.pp(caption, x, y, _G.getPrintingParameters({ fontColor = colors.white }))
end

local function drawJoystickMapping()
  local text = {
    colors.white, 'Press for',
    colors.white, ': ',
    colors.green, joystickManager:getInputBeingMapped(),
    colors.white, '...'
  }
  utils.pp(text, 0, 0, _G.getPrintingParameters({centered = true }))
end

local function drawMessagesForAsyncTaks()
  if loadingGames then
    utils.pp({
      colors.white, 'Loading games',
      colors.white, '...'
    }, 0, 0, _G.getPrintingParameters({centered = true }))
  end

  if _G.shuttingDown then
    utils.pp({
      colors.white, 'Shutting down',
      colors.white, '...'
    }, 0, 0, _G.getPrintingParameters({ centered = true }))
  end

  if _G.restarting then
    utils.pp({
      colors.white, 'Restarting',
      colors.white, '...'
    }, 0, 0, _G.getPrintingParameters({ centered = true }))
  end
end

local function drawGameScreenPreview(item)
  love.graphics.setColor(colors.white)

  if _G.preferences.video.stretchGames then
    love.graphics.draw(item.img, 0, 0, 0,
      love.graphics.getWidth() / item.img:getWidth(),
      love.graphics.getHeight() / item.img:getHeight()
    )
  else
    utils.draw(item.img,
      love.graphics.getWidth() / 2,
      love.graphics.getHeight() / 2, 
      { scale = item.scale, centered = true }
    )
  end
end

local function drawGamePreviewBanner()
  love.graphics.clear(0, 0, 0, 0)
  love.graphics.setColor(colors:withOpacity('black', 0.75))
  love.graphics.rectangle('fill',
    0,
    constants.CANVAS_HEIGHT / 2 - 20,
    constants.CANVAS_WIDTH,
    40
  )

  local core = constants.cores[indexVideoModePreview]
  local label = constants.coreAssociations[core]
  utils.pp('< ' .. label .. ' >', 0, 0, _G.getPrintingParameters({ centered = true }))
end

local function drawVideoModePreviews()
  if shouldDrawVideoModePreview() then
    local item = _G.videoModePreviews[constants.cores[indexVideoModePreview]]
    love.graphics.setColor(colors.black)
    love.graphics.rectangle('fill',
      0, 0, love.graphics.getWidth(), love.graphics.getHeight()
    )
    drawGameScreenPreview(item)

    love.graphics.setCanvas({_G.videoModePreviewCanvas, stencil = true })
    drawGamePreviewBanner()
    love.graphics.setCanvas()
  
    love.graphics.draw(_G.videoModePreviewCanvas, 0, 0, 0, scaleX, scaleY)
  end
end

local function initFontsAndStuff()
  _G.font:setFilter('nearest', 'nearest')
  _G.characterW = _G.font:getWidth('A') -- monospaced font
  love.graphics.setFont(_G.font)
  love.graphics.setBackgroundColor(colors.purple)
end

local function needsToUpdateScales()
  local w = love.graphics.getWidth()
  local h = love.graphics.getHeight()
  local file = constants.RUCOPIE_DIR .. 'cache/' .. w .. 'x' .. h .. '.lock'
  return not osBridge.fileExists(file)
end

---------------------------------------------
---------------------------------------------
-- Global functions:
---------------------------------------------
---------------------------------------------
_G.getPrintingParameters = function (extra)
  extra = extra or {}
  local params = {
    fontColor = _G.currentTheme.fontColor,
    shadow = _G.currentTheme.shadow,
    shadowColor = _G.currentTheme.shadowColor,
    fontOpacity = _G.currentTheme.fontOpacity,
    shadowOpacity = _G.currentTheme.shadowOpacity,
  }

  for k, v in pairs(extra) do
    params[k] = v
  end
  return params
end


_G.calculateResolutionsAndVideoModePreviews = function (forceUpdate)
  local coresToUpdate = {}
  for _, core in ipairs(constants.cores) do
    local scale, w, h = resolutionManager.calculate(core)
    coresToUpdate[core] = {
      w = w,
      h = h
    }
    _G.videoModePreviews[core] = {}
    local item = _G.videoModePreviews[core]
    item.scale = scale
    item.img = images.videoModePreviews[core .. '.png']
  end

  if needsToUpdateScales() or forceUpdate then -- it enters just 1 time to this if, it should not
    for core, data in pairs(coresToUpdate) do
      local result = resolutionManager.saveScaleForCore(core, data.w, data.h)
    end
  end
  _G.updateVideoModePreviews()
end

_G.refreshSystemsTree = function ()
  loadingGames = true
  threadManager:run('refresh-systems', function(data)
    _G.systemsTree = loadstring(data.stringTree)()
    setRefreshedGameList()
    loadingGames = false
  end, {
    characterW = _G.characterW,
    maxLineWidth = listManager.listBounds.w
  })
end

---------------------------------------------
---------------------------------------------
--  3 main callbacks:
---------------------------------------------
---------------------------------------------

function love.load()
  initFontsAndStuff()
  _G.screens = {
    systems = 1,
    options = 2
  }
  currentScreen = _G.screens.systems
  initNavigationStacks()
  loadGameList() -- this may be async
  initCanvas()
  initPreferences()
  initVirtualKeyboard()
  _G.calculateResolutionsAndVideoModePreviews()
end

function love.update(dt)
  threadManager:update(dt) -- running all the time even when retroarch is opened
  if _G.onHold then return end

  themeManager:update(dt)
  listManager:update(dt)
end

function love.draw()
  if _G.onHold then return end

  love.graphics.setCanvas({ _G.canvas, stencil = true })
  love.graphics.clear(colors.purple)
 
  love.graphics.setColor(colors.purple) -- backgroundest background
  love.graphics.rectangle('fill', 0, 0, constants.CANVAS_WIDTH, constants.CANVAS_HEIGHT)

  themeManager:drawCurrentTheme()
  if virtualKeyboard.active then
    virtualKeyboard:draw()
    drawCurrentCaption()
  elseif joystickManager.isCurrentlyMapping then
    drawJoystickMapping()
  else
    drawCurrentList()
    drawMessagesForAsyncTaks()
    drawCurrentCaption()
  end

  utils.pp(_G.connected or '', 0, 0, _G.getPrintingParameters({ centered = true }))

  love.graphics.setCanvas()
  love.graphics.setColor(colors.white)
  love.graphics.draw(_G.canvas, 0, 0, 0, scaleX, scaleY)

  love.graphics.setColor(colors.white)
  drawVideoModePreviews()
  printDebug()
end

---------------------------------------------
---------------------------------------------
--  user events
---------------------------------------------
---------------------------------------------

function handleBack()
  if virtualKeyboard.active then
    virtualKeyboard:remove()
  else
    listManager:back(value, listsStack, pathStack, currentScreen)
  end
end

function handleSelect()
  if virtualKeyboard.active then
    virtualKeyboard:cancel()
  end
end

function handleStart()
  if virtualKeyboard.active then
    virtualKeyboard:confirm()
  else
    switchScreen()
  end
end

function handleLeft()
  if shouldDrawVideoModePreview() then
    indexVideoModePreview = indexVideoModePreview - 1
    if indexVideoModePreview < 1 then
      indexVideoModePreview = #constants.cores
    end
  elseif virtualKeyboard.active then
    virtualKeyboard:left()
  else
    listManager:left()
  end
end

function handleRight()
  if shouldDrawVideoModePreview() then
    indexVideoModePreview = indexVideoModePreview + 1
    if indexVideoModePreview > #constants.cores then
      indexVideoModePreview = 1
    end
  elseif virtualKeyboard.active then
    virtualKeyboard:right()
  else
    listManager:right()
  end
end

function handleUp()
  if virtualKeyboard.active then
    virtualKeyboard:up()
  else
    listManager:up()
  end
end

function handleDown()
  if virtualKeyboard.active then
    virtualKeyboard:down()
  else
    listManager:down()
  end
end

function handleAction(item)
  if virtualKeyboard.active then
    virtualKeyboard:add(virtualKeyboard:getSelectedItem())
  else
    listManager:performAction(listsStack, pathStack, item.action or function()
      local romPath = utils.join('/', pathStack[_G.screens.systems]) .. '/' .. item.internalLabel
      osBridge.runGame(_G.systemSelected, constants.ROMS_DIR .. romPath)
    end, currentScreen)
    if listManager.currentList.internalLabel == 'Themes' then
      listManager:setBounds(_G.currentTheme.listBounds)
    end
  end
end

function handleUserInput(data)
  -- debug
  local value = data.value
  if value == joystickManager:getButton('Hotkey') or value == constants.keys.ESCAPE then
    love.event.quit()
  end
  if value == joystickManager:getButton('R1') then
    love.graphics.captureScreenshot('screenshot_' .. tostring(os.time()) .. '.png')
  end
  --end of debug

  if loadingGames then return end
  
  -- actions that are independent of a selected item:
  if value == constants.keys.ESCAPE or value == joystickManager:getButton('B') then
    handleBack()
  elseif value == constants.keys.F1 or value == joystickManager:getButton('Select') then
    handleSelect()
  elseif value == constants.keys.F1 or value == joystickManager:getButton('Start') then
    handleStart()
  end

  local item = listManager:getSelectedItem()
  if not item then return end

  -- the ones that depend on the current selected item:
  if value == constants.keys.LEFT or value == joystickManager:getHat('Left') then
    handleLeft()
  elseif value == constants.keys.RIGHT or value == joystickManager:getHat('Right') then
    handleRight()
  elseif value == constants.keys.UP or value == joystickManager:getHat('Up') then
    handleUp()
  elseif value == constants.keys.DOWN or value == joystickManager:getHat('Down') then
    handleDown()
  elseif value == constants.keys.ENTER  or value == joystickManager:getButton('A') then
    handleAction(item)
  end
end

function switchScreen()
  local list
  if currentScreen == _G.screens.systems then
    currentScreen = _G.screens.options
    list = listsStack[_G.screens.options]
  elseif currentScreen == _G.screens.options then
    currentScreen = _G.screens.systems
    list = listsStack[_G.screens.systems]
  end
  listManager.currentList = list[#list]
  listManager:resetClippedLine()
end

---------------------------------------------
---------------------------------------------
--  LOVE event callbacks
---------------------------------------------
---------------------------------------------

function love.keypressed(k)
  if _G.onHold then return end

  handleUserInput({ value = k })
end

function love.joystickadded(joystick)
  if _G.onHold then return end

  if osBridge.fileExists(constants.RUCOPIE_DIR .. constants.JOYSTICK_CONFIG_PATH) then
    -- todo: save config per joystick (using name or id)
    utils.debug('Joystick config file found.')
    joystickManager.generalMapping = loadstring(osBridge.readFile(constants.JOYSTICK_CONFIG_PATH))()
    osBridge.configLoaded = true
    _G.currentJoystick = joystick
  else
    _G.currentJoystick = joystick
    joystickManager.isCurrentlyMapping = true
  end
end

function love.joystickpressed(joystick, button)
  if _G.onHold then return end

  if joystickManager.isCurrentlyMapping then
    if not joystickManager.buttonMappingDone then
     joystickManager:mapRequestedInput(button)
    end
  elseif joystickManager:allSet() then
    handleUserInput({ value = button })
  end
end

function love.joystickhat(joystick, hat, direction)
  if _G.onHold then return end
  
  if direction == 'c' then return end -- ignored when idle

  if joystickManager.isCurrentlyMapping then
    if not joystickManager.hatMappingDone then
     joystickManager:mapRequestedInput(direction)
    end
  elseif joystickManager:allSet() then
    handleUserInput({ value = direction })
  end
end
