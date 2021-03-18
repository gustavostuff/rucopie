
local constants = require 'constants'
local colors = require 'colors'
local utils = require 'utils'

return {
  draw = function (listToDisplay, isSystemsList)
    if not listToDisplay then return end

    for i = 1, #listToDisplay.items do
      local item = listToDisplay.items[i]

      love.graphics.setColor(colors.white)
      if isSystemsList then
        if item.isDir and not item.isSystem then
          love.graphics.setColor(colors.blue)
        end
      else
        love.graphics.setColor(item.color or colors.white)
      end

      
      utils.pp(constants.systemsLabels[item.label] or item.label,
        math.floor(constants.paddingLeft),
        math.floor(constants.paddingTop + (i - 1) * love.graphics.getFont():getHeight())
      )

      if i == listToDisplay.index then
        love.graphics.setColor(colors.white)
        love.graphics.circle('fill',
          constants.paddingLeft - 10,
          math.floor(constants.paddingTop + (i - 1) * love.graphics.getFont():getHeight()) + 5,
          4
        )
      end
    end
  end
}
