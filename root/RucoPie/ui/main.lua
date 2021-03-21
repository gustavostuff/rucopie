local colors = require 'colors'
local constants = require 'constants'
local osBridge = require 'os-bridge'
local listManager = require 'list-manager'
local utils = require 'utils'
local joystickManager = require 'joystick-manager'
local themeManager = require 'theme-manager'

local optionsTree = require 'options-tree'

_G.debug = false
_G.screenDebug = true
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
  pageSize = constants.PAGE_SIZE -- for lists
  
  utils.debug('\n', '{' .. utils.tableToString(systemsTree) .. '}')
  
  --font = love.graphics.newFont('assets/fonts/pixelated/pixelated.ttf', 10)
  --font = love.graphics.newFont('assets/fonts/proggy/proggy.ttf', 16)
  font = love.graphics.newFont('assets/fonts/rgbpi/quarlow-normal-number.ttf', 16)
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
  listManager.draw(listToDisplay, currentScreen == screens.systems, pageSize)
  utils.pp(constants.captions[currentScreen],
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

  if _G.screenDebug then
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle('fill', 0, 0, 300, 200)
    love.graphics.setColor(colors.white)

    local n = #listToDisplay.items
    local totalPages = math.ceil(n / pageSize)
    local itemsInPage = pageSize
    if listToDisplay.page.pageNumber == totalPages then
      itemsInPage = pageSize - ((totalPages * pageSize) - n)
    end

    utils.pp(
      'FPS: ' .. love.timer.getFPS() .. '\n' ..
      'Width: ' .. love.graphics.getWidth() .. '\n' ..
      'Height: ' .. love.graphics.getHeight() .. '\n' ..
      'Canvas Width: ' .. constants.CANVAS_WIDTH .. '\n' ..
      'Canvas Height: ' .. constants.CANVAS_HEIGHT .. '\n' ..
      '----------------------------------\n' ..
      'items in list: ' .. n .. '\n' ..
      'current page: ' .. listToDisplay.page.pageNumber .. '\n' ..
      'page size: ' .. pageSize .. '\n' ..
      'total pages: ' .. totalPages .. '\n' ..
      'items at current page: ' .. itemsInPage
    )
  end
end


---------------
-- events
---------------

function handleGoBackAction(value)
  if value == constants.keys.ESCAPE then
  	love.event.quit()
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
  local n = #listToDisplay.items
  local totalPages = math.ceil(n / pageSize)
  -- internal index
  listToDisplay.index = listToDisplay.index + 1
  listToDisplay.page.gameIndex = listToDisplay.page.gameIndex + 1

  if listToDisplay.index > n then
    listToDisplay.index = 1
  end

  -- handle last page
  local itemsInPage = pageSize
  if listToDisplay.page.pageNumber == totalPages then
    itemsInPage = pageSize - ((totalPages * pageSize) - n)
  end

  -- index to display
  if listToDisplay.page.gameIndex > itemsInPage then
    listToDisplay.page.gameIndex = 1
    listToDisplay.page.pageNumber = listToDisplay.page.pageNumber + 1

    -- going beyond the last page
    if listToDisplay.page.pageNumber > totalPages then
      listToDisplay.page.pageNumber = 1
    end
  end
end

function handleGoUpAction()
  local n = #listToDisplay.items
  local totalPages = math.ceil(n / pageSize)
  -- internal index
  listToDisplay.index = listToDisplay.index - 1
  listToDisplay.page.gameIndex = listToDisplay.page.gameIndex - 1

  if listToDisplay.index < 1 then
    listToDisplay.index = n
  end

  -- index to display
  if listToDisplay.page.gameIndex < 1 then
    -- handle first page
    local itemsInPage = pageSize
    if listToDisplay.page.pageNumber == 1 then
      itemsInPage = pageSize - ((totalPages * pageSize) - n)
    end
    
    listToDisplay.page.gameIndex = itemsInPage
    listToDisplay.page.pageNumber = listToDisplay.page.pageNumber - 1

    -- going beyond the last page
    if listToDisplay.page.pageNumber < 1 then
      listToDisplay.page.pageNumber = totalPages
    end
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
