local constants = require 'constants'
local colors = require 'colors'
local utils = require 'utils'
local osBridge = require 'os-bridge'
local themeManager = require 'theme-manager'
local virtualKeyboard = require 'virtual-keyboard'
local translator = require 'translator'

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

local function themesSection()
  local rawList = osBridge.readFrom('ls ' .. constants.THEMES_DIR)
  local label = translator:get('Themes')
  local list, displayList = utils.split(rawList, '\n'), {
    displayLabel = utils.getDisplayLabel(label),
    internalLabel = label,
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
    { 'A', translator:get('Set theme') },
    { 'B', translator:get('Back') },
    { 'Start', translator:get('Systems') }
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
  osBridge.setupWifi('fiber', 'Jikilopolipoloko10') -- testing this
end

optionsTree = {
  items = {
    {
      displayLabel = utils.getDisplayLabel(translator:get('Video')),
      internalLabel = translator:get('Video'),
      items = {
        {
          displayLabel = utils.getDisplayLabel(translator:get('Smooth UI')),
          internalLabel = translator:get('Smooth UI'),
          checkbox = true,
          value = _G.preferences.video.smoothUI,
          action = smoothUIAction
        },
        {
          displayLabel = utils.getDisplayLabel(translator:get('Smooth Games')),
          internalLabel = translator:get('Smooth Games'),
          checkbox = true,
          value = _G.preferences.video.smoothGames,
          action = smoothGamesAction
        },
        {
          displayLabel = utils.getDisplayLabel(translator:get('Stretch Games')),
          internalLabel = translator:get('Stretch Games'),
          checkbox = true,
          value = _G.preferences.video.stretchGames,
          action = stretchGamesAction
        }
      },
      page = utils.initPage(),
      index = 1,
      caption = utils.getCaption({
        { 'A', translator:get('OK') },
        { 'B', translator:get('Back') },
        { 'X', translator:get('Preview') },
        { 'Start', translator:get('Systems') },
      })        
    }, {
      displayLabel = utils.getDisplayLabel(translator:get('Wifi')),
      internalLabel = translator:get('Wifi'),
      items = {
        {
          displayLabel = utils.getDisplayLabel(translator:get('Network Name')),
          internalLabel = translator:get('Network Name'),
          text = true,
          value = '',
          action = openTextGrid
        },
        {
          displayLabel = utils.getDisplayLabel(translator:get('Password')),
          internalLabel = translator:get('Password'),
          text = true,
          type = 'password',
          value = '',
          action = openTextGrid
        },
        {
          displayLabel = utils.getDisplayLabel(translator:get('Apply')),
          internalLabel = translator:get('Apply'),
          action = applyWifiSettings
        },
      },
      page = utils.initPage(),
      index = 1,
    }, {
      displayLabel = utils.getDisplayLabel(translator:get('Refresh Game List')),
      internalLabel = translator:get('Refresh Game List'),
      action = refreshRomsAction,
    },
    themesSection(),
    {
      displayLabel = utils.getDisplayLabel(translator:get('Language')),
      internalLabel = translator:get('Language'),
      index = 1,
      list = { 'EN', 'ES', 'FR' }
    },
    {
      displayLabel = utils.getDisplayLabel(translator:get('Restart')),
      internalLabel = translator:get('Restart'),
      color = colors.yellow,
      action = restartAction
    }, {
      displayLabel = utils.getDisplayLabel(translator:get('Shutdown')),
      internalLabel = translator:get('Shutdown'),
      color = colors.red,
      action = shutdownAction
    }, {
      displayLabel = utils.getDisplayLabel(translator:get('Advanced')),
      internalLabel = translator:get('Advanced'),
      items = {
        {
          displayLabel = utils.getDisplayLabel(translator:get('Show debug info')),
          internalLabel = translator:get('Show debug info'),
          color = colors.orange,
          action = toggleDebug
        }, {
          -- debug
          displayLabel = utils.getDisplayLabel(translator:get('Refresh resolutions')),
          internalLabel = translator:get('Refresh Resolutions'),
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

