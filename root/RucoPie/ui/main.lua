love.filesystem.setIdentity('ruco-pie')
love.graphics.setBlendMode('alpha')

_G.flux = require "lib/flux"
_G.debug = true
_G.screenDebug = false
_G.font = love.graphics.newFont('assets/fonts/proggy-tiny/ProggyTinySZ.ttf', 16)
_G.debugFont = love.graphics.newFont('assets/fonts/proggy-tiny/ProggyTinySZ.ttf', 32)

local colors = require 'colors'
local constants = require 'constants'
local osBridge = require 'os-bridge'
local utils = require 'utils'

local themeManager = require 'theme-manager'
local listManager = require 'list-manager'
local joystickManager = require 'joystick-manager'
local resolutionManager = require 'resolution-manager'
local threadManager = require 'thread-manager'

local optionsTree = require 'options-tree'

love.mouse.setVisible(false)
love.graphics.setLineStyle('rough')
love.graphics.setLineWidth(1)

local function printDebug()
  love.graphics.setFont(_G.debugFont)
  if _G.screenDebug then
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle('fill', 0, 0,
      love.graphics.getWidth(),
      love.graphics.getHeight()
    )
    love.graphics.setColor(colors.white)

    local n = #listManager.currentList.items
    local totalPages = listManager:getTotalPages()
    local itemsInCurrentPage = listManager:getItemsAtCurrentPage()
    local text = 'FPS: ' .. love.timer.getFPS() .. '\n' ..
      'Width: ' .. love.graphics.getWidth() .. '\n' ..
      'Height: ' .. love.graphics.getHeight() .. '\n' ..
      'Canvas Width: ' .. constants.CANVAS_WIDTH .. '\n' ..
      'Canvas Height: ' .. constants.CANVAS_HEIGHT .. '\n' ..
      '----------------------------------\n' ..
      'items in list: ' .. n .. '\n' ..
      'current page: ' .. listManager.currentList.page.pageNumber .. '\n' ..
      'page size: ' .. listManager.pageSize .. '\n' ..
      'total pages: ' .. totalPages .. '\n' ..
      'total games (all systems): ' .. _G.systemsTree.totalGames .. '\n' ..
      'items at current page: ' .. itemsInCurrentPage .. '\n' ..
      '----------------------------------\n' ..
      'character width (monospaced font should be used): ' .. characterW .. ' '

    utils.pp(text,
      love.graphics.getWidth() - _G.debugFont:getWidth(text), 0,
      { shadowColor = { 1, 1, 1, 0 } }
    )
  end

  love.graphics.setFont(_G.font)
end

local function initNavigationStacks()
  listsStack = {
    [_G.screens.systems] = {_G.systemsTree},
    [_G.screens.options] = {optionsTree}
  }
  pathStack = {
    [_G.screens.systems] = {},
    [_G.screens.options] = {}
  }
end

local function setRefreshedGameList()
  listsStack[_G.screens.systems] = {_G.systemsTree}
  pathStack[_G.screens.systems] = {}
  listManager:setCurrentList(_G.systemsTree)
  currentScreen = _G.screens.systems
end

local function loadGameList()
  if osBridge.fileExists(constants.RUCOPIE_DIR .. 'cache/games-tree.lua') then
    _G.systemsTree = loadstring(osBridge.readFile('cache/games-tree.lua'))()
    setRefreshedGameList()
    utils.debug('Systems tree from cache:\n', '{' .. utils.tableToString(_G.systemsTree) .. '}')
  else
    _G.refreshSystemsTree()
  end
end

local function initCanvas()
  canvas = love.graphics.newCanvas(constants.CANVAS_WIDTH, constants.CANVAS_HEIGHT)
  stencilCanvas = love.graphics.newCanvas(
    constants.CANVAS_WIDTH,
    constants.CANVAS_HEIGHT,
    { format ='stencil8' }
  )
  canvas:setFilter('nearest', 'nearest')
  stencilCanvas:setFilter('nearest', 'nearest')
  scaleX = love.graphics.getWidth() / constants.CANVAS_WIDTH
  scaleY = love.graphics.getHeight() / constants.CANVAS_HEIGHT
end

local function drawListAndCaption()
  love.graphics.setColor(colors.white)
  if listManager.currentList then
    listManager:draw()
    local caption = listManager.currentList.caption or constants.captions[currentScreen]
    utils.pp(caption,
      listManager.listBounds.x,
      listManager.listBounds.x + listManager.listBounds.h
    )
  end
end

local function drawJoystickMapping()
  if joystickManager.isCurrentlyMapping then
    local text = 'Press for ' .. joystickManager:getInputBeingMapped() .. '...'
    utils.pp(text,
      math.floor(constants.CANVAS_WIDTH / 2 - _G.font:getWidth(text) / 2),
      math.floor(constants.CANVAS_HEIGHT / 2 - _G.font:getHeight() / 2)
    )
  end
end

local function drawMessagesForAsyncTaks()
  if loadingGames then
    utils.pp('Loading games...')
  end

  if _G.shuttingDown then
    utils.pp('Shutting down...')
  end

  if _G.restarting then
    utils.pp('Restarting...')
  end
end

local function initFontsAndStuff()
  _G.font:setFilter('nearest', 'nearest')
  love.graphics.setFont(_G.font)
  love.graphics.setBackgroundColor(colors.purple)
  characterW = _G.font:getWidth('A') -- monospaced font
end

---------------------------------------------
---------------------------------------------
-- Global functions:
---------------------------------------------
---------------------------------------------

_G.calculateCoresResolution = function ()
  for _, core in ipairs(constants.cores) do
    resolutionManager.calculate(core)
  end
end

_G.refreshSystemsTree = function ()
  loadingGames = true
  threadManager:run('refresh-systems', function(data)
    _G.systemsTree = loadstring(data.stringTree)()
    setRefreshedGameList()
    loadingGames = false
  end, {
    characterW = characterW,
    maxLineWidth = listManager.listBounds.w
  })
end

---------------------------------------------
---------------------------------------------
--  Three main callbacks:
---------------------------------------------
---------------------------------------------

function love.load()
  utils.debug('Renderer info:')
  utils.debug('  ', love.graphics.getRendererInfo())
  utils.debug('Canvas formats:')
  for k,v in pairs(love.graphics.getCanvasFormats()) do
    if tostring(v) == 'true' then
      utils.debug('  Supported: ' .. k)
    else
      utils.debug('  NOT Supported: ' .. k)
    end
  end

  initFontsAndStuff()
  _G.screens = {
    systems = 1,
    options = 2
  }
  currentScreen = _G.screens.systems
  initNavigationStacks()
  loadGameList()
  _G.calculateCoresResolution()
  initCanvas()
end

function love.update(dt)
  themeManager:update(dt)
  threadManager:update(dt)
  listManager:update(dt)
end

function love.draw()
  love.graphics.setCanvas({
    canvas,
    depthstencil = stencilCanvas
  })
  love.graphics.clear()
 
  love.graphics.setColor(colors.purple)
  love.graphics.rectangle('fill', 0, 0, constants.CANVAS_WIDTH, constants.CANVAS_HEIGHT)

  themeManager:drawCurrentTheme()
  drawListAndCaption()
  drawJoystickMapping()
  drawMessagesForAsyncTaks()

  love.graphics.setCanvas()
  love.graphics.setColor(colors.white)
  love.graphics.draw(canvas, 0, 0, 0, scaleX, scaleY)

  printDebug()
end

---------------
-- events
---------------

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
  
  local item = listManager:getSelectedItem()
  if not item then return end

  if value == constants.keys.ESCAPE or value == joystickManager:getButton('B') then
    listManager:back(value, listsStack, pathStack, currentScreen)
  elseif value == constants.keys.F1 or value == joystickManager:getButton('Start') then
    switchScreen()
  elseif value == constants.keys.LEFT or value == joystickManager:getHat('Left') then
    listManager:left()
  elseif value == constants.keys.RIGHT or value == joystickManager:getHat('Right') then
    listManager:right()
  elseif value == constants.keys.UP or value == joystickManager:getHat('Up') then
    listManager:up()
  elseif value == constants.keys.DOWN or value == joystickManager:getHat('Down') then
    listManager:down()
  elseif value == constants.keys.ENTER  or value == joystickManager:getButton('A') then
    listManager:performAction(listsStack, pathStack, item.action or function()
      local romPath = utils.join('/', pathStack[_G.screens.systems]) .. '/' .. item.internalLabel
      osBridge.runGame(_G.systemSelected, constants.ROMS_DIR .. romPath)
    end)
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
end

function love.keypressed(k)
  handleUserInput({ value = k })
end

function love.joystickadded(joystick)
  if osBridge.fileExists(constants.RUCOPIE_DIR .. constants.JOYSTICK_CONFIG_PATH) then
    -- todo: save config per joystick (using name or id)
    utils.debug('Joystick config file found.')
    joystickManager.generalMapping = loadstring(osBridge.readFile(constants.JOYSTICK_CONFIG_PATH))()
    osBridge.configLoaded = true
  else
    _G.currentJoystick = joystick
    joystickManager.isCurrentlyMapping = true
  end
end

function love.joystickpressed(joystick, button)
  if joystickManager.isCurrentlyMapping then
    if not joystickManager.buttonMappingDone then
     joystickManager:mapRequestedInput(button)
    end
  elseif joystickManager:allSet() then
    handleUserInput({ value = button })
  end
end

function love.joystickhat(joystick, hat, direction)
  if direction == 'c' then return end -- ignored when idle

  if joystickManager.isCurrentlyMapping then
    if not joystickManager.hatMappingDone then
     joystickManager:mapRequestedInput(direction)
    end
  elseif joystickManager:allSet() then
    handleUserInput({ value = direction })
  end
end
