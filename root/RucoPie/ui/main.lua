local colors = require 'colors'
local constants = require 'constants'
local osBridge = require 'os-bridge'
local listManager = require 'list-manager'
local utils = require 'utils'
local joystickManager = require 'joystick-manager'
local themeManager = require 'theme-manager'

local optionsTree = require 'options-tree'

_G.debug = false
_G.screenDebug = false
love.mouse.setVisible(false)

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
        isSystem = level == 1
      }
      createSystemsTree(path .. item .. '/', childList, level + 1)
      table.insert(parentList.items, childList)
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

local function isSubOptionsScreen(item)
  return item.label == constants.VIDEO_OPTIONS_LABEL or
         item.label == constants.ADVANCED_LABEL
end

function love.load()
  systemsTree = createSystemsTree()
  screens = {
    systems = 1,
    options = 2
  }
  listsStack = {
    [screens.systems] = {systemsTree},
    [screens.options] = {optionsTree}
  }
  pathStack = {
    [screens.systems] = {},
    [screens.options] = {}
  }
  currentScreen = screens.systems
  
  utils.debug('\n', '{' .. utils.tableToString(systemsTree) .. '}')
  
  --font = love.graphics.newFont('assets/fonts/pixelated/pixelated.ttf', 10)
  font = love.graphics.newFont('assets/fonts/proggy/proggy.ttf', 16)
  font:setFilter('nearest', 'nearest')
  love.graphics.setFont(font)
  love.graphics.setBackgroundColor(colors.purple)
  
  listToDisplay = systemsTree
  
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
  listManager.draw(listToDisplay, currentScreen == screens.systems)
  utils.pp(constants.captions[currentScreen],
    constants.paddingLeft,
    constants.CANVAS_HEIGHT - constants.paddingBottom - font:getHeight()
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

  if _G.screenDebug then
    love.graphics.setColor(colors.white)
    utils.pp(
      'FPS: ' .. love.timer.getFPS() .. '\n' ..
      'Width: ' .. love.graphics.getWidth() .. '\n' ..
      'Height: ' .. love.graphics.getHeight() .. '\n' ..
      'Canvas Width: ' .. constants.CANVAS_WIDTH .. '\n' ..
      'Canvas Height: ' .. constants.CANVAS_HEIGHT
    )
  end
end


---------------
-- events
---------------

function handleGoBackAction(value)
  if value == constants.keys.ESCAPE then
  	quit()
  end
  local currentListsStack = listsStack[currentScreen]
  local currentPathStack = pathStack[currentScreen]

  if #currentListsStack > 1 then
    table.remove(currentListsStack)
    table.remove(currentPathStack)
    listToDisplay = currentListsStack[#currentListsStack]
    if currentListsStack == listsStack[screens.systems] and #currentListsStack == 1 then
      _G.systemSelected = nil
    end
  end
end

function handleGoDownAction()
  listToDisplay.index = listToDisplay.index + 1
  if listToDisplay.index > #listToDisplay.items then
    listToDisplay.index = 1
  end
end

function handleGoUpAction()
  listToDisplay.index = listToDisplay.index - 1
  if listToDisplay.index < 1 then
    listToDisplay.index = #listToDisplay.items
  end
end

function handleForwardAction()
  local item = utils.getSelectedItem()
  local currentListsStack = listsStack[currentScreen]
  local currentPathStack = pathStack[currentScreen]

  if currentScreen == screens.systems then
    if item.isDir then
      table.insert(currentListsStack, item)
      table.insert(currentPathStack, item.label)
      if item.isSystem then -- set selected system (gb, nes, etc.)
        _G.systemSelected = item.label
      end
      listToDisplay = item
    else 
      local romPath = utils.join('/', pathStack[screens.systems]) .. '/' .. item.label
      osBridge.runGame(_G.systemSelected, constants.ROMS_DIR .. romPath)
    end
  elseif currentScreen == screens.options then
    if item.action then
      item.action(item)
    else
      if item.label == constants.RESTART_LABEL then osBridge.restart() end
      if item.label == constants.SHUTDOWN_LABEL then osBridge.shutdown() end
      if isSubOptionsScreen(item) then
        table.insert(currentListsStack, item)
        table.insert(currentPathStack, item.label)
        listToDisplay = item
      end
    end
  end
end

function handleUserInput(data)
  local value = data.value
  
  if value == constants.keys.ESCAPE or value == joystickManager:getButton('B') then
    handleGoBackAction(value)
  elseif value == constants.keys.F1 or value == joystickManager:getButton('Start') then
    switchScreen()
  elseif value == constants.keys.DOWN or value == joystickManager:getHat('Down') then
    handleGoDownAction()
  elseif value == constants.keys.UP or value == joystickManager:getHat('Up') then
    handleGoUpAction()
  elseif value == constants.keys.ENTER  or value == joystickManager:getButton('A') then
    handleForwardAction()
  end
end

function switchScreen()
  if currentScreen == screens.systems then
    currentScreen = screens.options
    local list = listsStack[screens.options]
    listToDisplay = list[#list]
  elseif currentScreen == screens.options then
    currentScreen = screens.systems
    local list = listsStack[screens.systems]
    listToDisplay = list[#list]
  end
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

function quit()
  love.event.quit()
end
