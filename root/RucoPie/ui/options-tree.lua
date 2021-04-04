local constants = require 'constants'
local colors = require 'colors'
local utils = require 'utils'
local osBridge = require 'os-bridge'
local themeManager = require 'theme-manager'

local function bilinearOptionAction(item)
  item.value = not item.value
  if item.value then
    canvas:setFilter('linear', 'linear')
  else
    canvas:setFilter('nearest', 'nearest')
  end
end

local function inGameBilinearAction(item)
  item.value = not item.value
  for _, core in ipairs(constants.cores) do
    osBridge.updateConfig(core, 'soft_filter_enable', item.value)
  end
end

local function initThemesList()
  local rawList = osBridge.readFrom('ls ' .. constants.THEMES_DIR)
  local list, displayList = utils.split(rawList, '\n'), {
    displayLabel = utils.getDisplayLabel('Themes'),
    internalLabel = 'Themes',
    index = 1,
    items = {},
    page = utils.initPage()
  }

  for i = 1, #list do
    local themeItem = {
      internalLabel = list[i],
      displayLabel = utils.getDisplayLabel(list[i])
    }
    themeItem.action = function()
      themeManager:setTheme(themeItem.internalLabel)
    end
    table.insert(displayList.items, themeItem)
  end

  displayList.caption = {
    colors.green, 'A: Set theme',
    colors.red, '  B: Back',
    colors.blue, '  Start: Systems'
  }
  return displayList
end

local function restartAction()
  _G.restarting = true
  osBridge.restart()
end

local function shutdownAction()
  _G.shuttingDown = true
  osBridge.shutdown()
end

local function toggleDebug()
  _G.screenDebug = not _G.screenDebug
end

local function refreshRomsAction()
  _G.refreshSystemsTree()
end

local function recalculateCoresResolutionAction()
  _G.calculateCoresResolution()
end

optionsTree = {
  items = {
    {
      displayLabel = utils.getDisplayLabel('Video'),
      internalLabel = 'Video',
      items = {
        {
          displayLabel = utils.getDisplayLabel('Bilinear UI'),
          internalLabel = 'Bilinear UI',
          checkbox = true,
          value = false,
          action = bilinearOptionAction
        },
        {
          displayLabel = utils.getDisplayLabel('In-Game Bilinear'),
          internalLabel = 'In-Game Bilinear',
          checkbox = true,
          value = false,
          action = inGameBilinearAction
        }
      },
      page = utils.initPage(),
      index = 1
    }, {
      displayLabel = utils.getDisplayLabel('Refresh Game List'),
      internalLabel = 'Refresh Game List',
      action = refreshRomsAction,
    },
    initThemesList(),
    {
      displayLabel = utils.getDisplayLabel('Restart'),
      internalLabel = 'Restart',
      color = colors.yellow,
      action = restartAction
    }, {
      displayLabel = utils.getDisplayLabel('Shutdown'),
      internalLabel = 'Shutdown',
      color = colors.red,
      action = shutdownAction
    }, {
      displayLabel = utils.getDisplayLabel('Advanced'),
      internalLabel = 'Advanced',
      items = {
        {
          displayLabel = utils.getDisplayLabel('Show debug info'),
          internalLabel = 'Show debug info',
          color = colors.orange,
          action = toggleDebug
        }, {
          -- debug
          displayLabel = utils.getDisplayLabel('Refresh resolutions'),
          internalLabel = 'Refresh Resolutions',
          action = recalculateCoresResolutionAction
        }
      },
      page = utils.initPage(),
      index = 1
    }
  },
  page = utils.initPage(),
  index = 1
}

return optionsTree

