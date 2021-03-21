local constants = require 'constants'
local colors = require 'colors'
local utils = require 'utils'

local function bilinearOptionAction(item)
  item.checkbox = not item.checkbox
  if item.checkbox then
    canvas:setFilter('linear', 'linear')
  else
    canvas:setFilter('nearest', 'nearest')
  end
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
    { label = constants.RESTART_LABEL, color = colors.yellow },
    { label = constants.SHUTDOWN_LABEL, color = colors.red },
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

