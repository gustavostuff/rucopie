local colors = require 'colors'
local constants = require 'constants'
local osBridge = require 'os-bridge'
local utils = require 'utils'

local themeManager = require 'theme-manager'
local listManager = require 'list-manager'
local joystickManager = require 'joystick-manager'
local resolutionManager = require 'resolution-manager'

local optionsTree = require 'options-tree'

_G.debug = false
_G.screenDebug = false
love.mouse.setVisible(false)

local function drawDebug()
  if _G.screenDebug then
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle('fill', 0, 0, 300, 200)
    love.graphics.setColor(colors.white)

    local n = #listManager.currentList.items
    local totalPages = listManager:getTotalPages()
    local itemsInCurrentPage = listManager:getItemsAtCurrentPage()

    utils.pp(
      'FPS: ' .. love.timer.getFPS() .. '\n' ..
      'Width: ' .. love.graphics.getWidth() .. '\n' ..
      'Height: ' .. love.graphics.getHeight() .. '\n' ..
      'Canvas Width: ' .. constants.CANVAS_WIDTH .. '\n' ..
      'Canvas Height: ' .. constants.CANVAS_HEIGHT .. '\n' ..
      '----------------------------------\n' ..
      'items in list: ' .. n .. '\n' ..
      'current page: ' .. listManager.currentList.page.pageNumber .. '\n' ..
      'page size: ' .. listManager.pageSize .. '\n' ..
      'total pages: ' .. totalPages .. '\n' ..
      'items at current page: ' .. itemsInCurrentPage
    )
  end
end

-- this is recursive, be careful
local function createSystemsTree(path, parentList, level)
  level = level or 1
  path = path or constants.ROMS_DIR
  local rawList = osBridge.readFrom('ls "' .. path .. '"')
  local list, parentList = utils.split(rawList, '\n'), parentList or { index = 1, items = {} }
  if level == 1 then parentList.isRoot = true end
  
  for i = 1, #list do
    local item = list[i]
    
    if osBridge.isDirectory(path .. item) then
      utils.debug('Is a directory: ' .. path .. item)
      local childList = {
        label = item,
        items = {},
        index = 1,
        isDir = true,
        isSystem = level == 1,
        page = utils.initPage()
      }
      createSystemsTree(path .. item .. '/', childList, level + 1)
      table.insert(parentList.items, childList)
      parentList.page = utils.initPage()
    else
      utils.debug('Is a file: ' .. path .. item)
      table.insert(parentList.items, { label = item })
    end
  end
  
  return parentList
end

local function isAnyHatDirectionPressed()
  if not _G.currentJoystick then return end
  
  return (
    _G.currentJoystick:getHat(1) ~= 'c' -- any non 'idle' state
  )
end

function love.load()
  systemsTree = createSystemsTree()
  _G.screens = {
    systems = 1,
    options = 2
  }
  listsStack = {
    [_G.screens.systems] = {systemsTree},
    [_G.screens.options] = {optionsTree}
  }
  pathStack = {
    [_G.screens.systems] = {},
    [_G.screens.options] = {}
  }
  currentScreen = _G.screens.systems
  
  utils.debug('\n', '{' .. utils.tableToString(systemsTree) .. '}')

  for _, core in ipairs(constants.cores) do
    local result = resolutionManager.calculate(core)
    print('core resolution info >>', result)
  end
  
  --font = love.graphics.newFont('assets/fonts/pixelated/pixelated.ttf', 10)
  --font = love.graphics.newFont('assets/fonts/proggy/proggy.ttf', 16)
  --font = love.graphics.newFont('assets/fonts/rgbpi/quarlow-normal-number.ttf', 16)
  font = love.graphics.newFont('assets/fonts/proggy-tiny/ProggyTinySZ.ttf', 16)
  font:setFilter('nearest', 'nearest')
  love.graphics.setFont(font)
  love.graphics.setBackgroundColor(colors.purple)
  
  listManager:setCurrentList(systemsTree)
  
  canvas = love.graphics.newCanvas(constants.CANVAS_WIDTH, constants.CANVAS_HEIGHT)
  canvas:setFilter('nearest', 'nearest')
  scaleX = love.graphics.getWidth() / constants.CANVAS_WIDTH
  scaleY = love.graphics.getHeight() / constants.CANVAS_HEIGHT
end

function love.update(dt)
  themeManager:update(dt)
end

function love.draw()
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
 
  love.graphics.setColor(colors.purple)
  love.graphics.rectangle('fill', 0, 0, constants.CANVAS_WIDTH, constants.CANVAS_HEIGHT)

  themeManager:drawCurrentTheme()
  
  love.graphics.setColor(colors.white)
  listManager:draw(currentScreen == _G.screens.systems)
  local caption = listManager.currentList.caption or constants.captions[currentScreen]
  utils.pp(caption,
    constants.PADDING_LEFT,
    constants.CANVAS_HEIGHT - constants.PADDING_BOTTOM - font:getHeight()
  )

  if joystickManager.isCurrentlyMapping then
    local text = 'Press for ' .. joystickManager:getInputBeingMapped() .. '...'
    utils.pp(text,
      math.floor(constants.CANVAS_WIDTH / 2 - font:getWidth(text) / 2),
      math.floor(constants.CANVAS_HEIGHT / 2 - font:getHeight() / 2)
    )
  end

  love.graphics.setCanvas()
  love.graphics.setColor(colors.white)
  love.graphics.draw(canvas, 0, 0, 0, scaleX, scaleY)

  drawDebug()
end

---------------
-- events
---------------

function handleUserInput(data)
  local value = data.value
  local item = listManager:getSelectedItem()

  -- debug
  if value == joystickManager:getButton('Hotkey') then love.event.quit() end
  
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
      local romPath = utils.join('/', pathStack[_G.screens.systems]) .. '/' .. item.label
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
