local constants = require 'constants'
local colors = require 'colors'
local utils = require 'utils'
local osBridge = require 'os-bridge'
local themeManager = require 'theme-manager'
local virtualKeyboard = require 'virtual-keyboard'

local function smoothUIAction(item)
  item.value = not item.value
  _G.preferences.video.smoothUI = item.value
  osBridge.saveCustomPreferences(_G.preferences)
  themeManager:updateSmoothUI(item.value)
end

local function smoothGamesAction(item)
  item.value = not item.value
  osBridge.updateConfigsForAllCores({ video_smooth = item.value })
  _G.preferences.video.smoothGames = item.value
  osBridge.saveCustomPreferences(_G.preferences)
  _G.updateVideoModePreviews()
end

local function stretchGamesAction(item)
  item.value = not item.value
  _G.preferences.video.stretchGames = item.value
  if item.value then
    osBridge.updateConfigsForAllCores({
      video_scale_integer = false,
      custom_viewport_width = love.graphics.getWidth(),
      custom_viewport_height = love.graphics.getHeight(),
    })
  else
    osBridge.updateConfigsForAllCores({ video_scale_integer = true })
    _G.calculateResolutionsAndVideoModePreviews(true)
  end
  osBridge.saveCustomPreferences(_G.preferences)
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
      _G.preferences.theme = themeItem.internalLabel
      osBridge.saveCustomPreferences(_G.preferences)
    end
    table.insert(displayList.items, themeItem)
  end

  displayList.caption = utils.getCaption({
    { 'A', 'Set theme' },
    { 'B', 'Back' },
    { 'Start', 'Systems' }
  })
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

local function recalculateResolutionsAndVideoModePreviewsAction()
  _G.calculateResolutionsAndVideoModePreviews()
end

local function openTextGrid(item)
  virtualKeyboard:openFor(item)
end

local function applyWifiSettings(item)
  osBridge.setupWifi('fiber', 'Jikilopolipoloko10')
end

optionsTree = {
  items = {
    {
      displayLabel = utils.getDisplayLabel('Video'),
      internalLabel = 'Video',
      items = {
        {
          displayLabel = utils.getDisplayLabel('Smooth UI'),
          internalLabel = 'Smooth UI',
          checkbox = true,
          value = _G.preferences.video.smoothUI,
          action = smoothUIAction
        },
        {
          displayLabel = utils.getDisplayLabel('Smooth Games'),
          internalLabel = 'Smooth Games',
          checkbox = true,
          value = _G.preferences.video.smoothGames,
          action = smoothGamesAction
        },
        {
          displayLabel = utils.getDisplayLabel('Stretch Games'),
          internalLabel = 'Stretch Games',
          checkbox = true,
          value = _G.preferences.video.stretchGames,
          action = stretchGamesAction
        }
      },
      page = utils.initPage(),
      index = 1,
      caption = utils.getCaption({
        { 'A', 'Select' },
        { 'B', 'Back' },
        { 'X', 'Preview' },
        { 'Start', 'Systems' },
      })        
    }, {
      displayLabel = utils.getDisplayLabel('Wifi'),
      internalLabel = 'Wifi',
      items = {
        {
          displayLabel = utils.getDisplayLabel('Network Name'),
          internalLabel = 'Network Name',
          text = true,
          value = '',
          action = openTextGrid
        },
        {
          displayLabel = utils.getDisplayLabel('Password'),
          internalLabel = 'Password',
          text = true,
          type = 'password',
          value = '',
          action = openTextGrid
        },
        {
          displayLabel = utils.getDisplayLabel('Apply'),
          internalLabel = 'Apply',
          action = applyWifiSettings
        },
      },
      page = utils.initPage(),
      index = 1,
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
          action = recalculateResolutionsAndVideoModePreviewsAction
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

