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
  osBridge.restart()
end

local function shutdownAction()
  osBridge.shutdown()
end

local function toggleDebug()
  _G.screenDebug = not _G.screenDebug
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
    initThemesList(),
    { label = constants.RESTART_LABEL, color = colors.yellow, action = restartAction },
    { label = constants.SHUTDOWN_LABEL, color = colors.red, action = shutdownAction },
    {
      label = constants.ADVANCED_LABEL,
      items = {
        { label = constants.DEBUG_LABEL, color = colors.orange, action = toggleDebug }
      },
      page = utils.initPage(),
      index = 1
    }
  },
  page = utils.initPage(),
  index = 1
}

return optionsTree

