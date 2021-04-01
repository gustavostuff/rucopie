local constants = require 'constants'
local colors = require 'colors'
local utils = require 'utils'
local osBridge = require 'os-bridge'
local themeManager = require 'theme-manager'

local function bilinearOptionAction(item)
  item.checkbox = not item.checkbox
  if item.checkbox then
    canvas:setFilter('linear', 'linear')
  else
    canvas:setFilter('nearest', 'nearest')
  end
end

local function initThemesList()
  local rawList = osBridge.readFrom('ls ' .. constants.THEMES_DIR)
  local list, displayList = utils.split(rawList, '\n'), {
    label = constants.THEMES_LABEL,
    index = 1,
    items = {},
    page = utils.initPage()
  }

  for i = 1, #list do
    table.insert(displayList.items, {
      label = list[i],
      action = function() themeManager:setTheme(list[i]) end
    })
  end

  displayList.caption = {
    colors.green, 'A:',
    colors.white, 'Set theme',
    colors.red, '  B:',
    colors.white, 'Back',
    colors.blue, '  Start:',
    colors.white, 'Systems'
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
      label = constants.VIDEO_OPTIONS_LABEL,
      items = {
        {
          label = constants.BILINEAR_LABEL,
          checkbox = false,
          action = bilinearOptionAction
        }
      },
      page = utils.initPage(),
      index = 1
    },
    { label = constants.REFRESH_ROMS_LABEL, action = refreshRomsAction },
    initThemesList(),
    { label = constants.RESTART_LABEL, color = colors.yellow, action = restartAction },
    { label = constants.SHUTDOWN_LABEL, color = colors.red, action = shutdownAction },
    {
      label = constants.ADVANCED_LABEL,
      items = {
        { label = constants.DEBUG_LABEL, color = colors.orange, action = toggleDebug },
        -- debug
        { label = 'refresh resolutions', action = recalculateCoresResolutionAction }
      },
      page = utils.initPage(),
      index = 1
    }
  },
  page = utils.initPage(),
  index = 1
}

return optionsTree

